from pathlib import Path
import json,re,struct,hashlib,gzip,datetime
from PIL import Image
B=Path('/workspace/work/glyph-execution');O=Path('/workspace/work/glyph-acceptance'); checks=[];details={}
def ck(ok,label):
 checks.append({'passed':bool(ok),'assertion':label})
 if not ok:raise AssertionError(label)
def load(p):return json.loads(Path(p).read_text())
def sha(p):return hashlib.sha256(Path(p).read_bytes()).hexdigest()
def profile(p):return dict(line.split('=',1) for line in Path(p).read_text().splitlines() if '=' in line)
def cells(p):
 b=p.read_bytes();ck(len(b)==80*25*4,'Actual 80x25 vcsu cells '+str(p.relative_to(B)))
 return ''.join(chr(c[0]) for c in struct.iter_unpack('<I',b))
def rowdata(raw):return [(int(n),re.sub('\x1b\\[[0-9;]*m','',r)) for n,r in re.findall('\x1b\\[(\\d+);1H([^\x1b]*(?:\x1b\\[[0-9;]*m[^\x1b]*)*)',raw.decode())]
def trace_events(p):
 out=bytearray();ins=bytearray();pending={};fences=[];unknown=[];writes=0
 for line in p.read_text().splitlines():
  m=re.match(r'\s*(\d+)\s+(.*)',line);pid,body=m.groups() if m else ('single',line)
  m=re.match(r'(write\(1|read\(0), "((?:\\x[0-9a-f]{2})*)"',body)
  if m:
   kind='write' if m[1].startswith('write') else 'read'; data=bytes.fromhex(m[2].replace('\\x',''))
   if '<unfinished ...>' in body:pending[(pid,kind)]=data;continue
  else:
   m=re.match(r'<\.\.\. (write|read) resumed>',body)
   if not m or (pid,m[1]) not in pending:
    if body.startswith(('write(1, ','read(0, ')) and 'EAGAIN' not in body:unknown.append(line)
    continue
   kind=m[1];data=pending.pop((pid,kind))
  rc=re.search(r'= (-?\d+)(?:\s|$)',body)
  if not rc:unknown.append(line);continue
  n=int(rc[1])
  if n>0:
   ck(n<=len(data),'Trace contains full successful syscall payload')
   if kind=='write':out.extend(data[:n]);writes+=1
   else:
    ins.extend(data[:n])
    for c in data[:n]:
     if c==ord('p'):fences.append(bytes(out))
 ck(not pending and not unknown,'No unmatched fd0/fd1 trace calls '+str(p.relative_to(B)))
 return bytes(out),bytes(ins),fences,writes
def cpio(p):
 b=gzip.decompress(p.read_bytes());i=0;out={}
 while True:
  ck(b[i:i+6]==b'070701','newc archive record header')
  fields=[int(b[i+6+n*8:i+14+n*8],16) for n in range(13)];mode,size,namesize=fields[1],fields[6],fields[11]
  name=b[i+110:i+110+namesize-1].decode();i=(i+110+namesize+3)&~3;data=b[i:i+size];i=(i+size+3)&~3
  if name=='TRAILER!!!':break
  out[name]={'mode':mode,'data':data}
 return out
original='é e\u0301 中文 😀 ✈\ufe0f 👩‍💻 …';conservative='é e\u0301 中文 😀 ?? ?? …';mapped='é ? ???? ?? ?? ?? ?';asciirow='? ? ???? ?? ?? ?? ?'
try:
 # Actual guest archive content, including the old root-only archive, not current directory assumptions.
 archives={sha(p):p for p in (B/'packages').glob('*.cpio.gz')}; guestsets={};guestdetail=[]
 for name in ['vt-before-permission-fix.cpio.gz','vt-final-product.cpio.gz']:
  p=B/'packages'/name;g=cpio(p);guestsets[name]=g
  for role,target in [('glyph','host-consumer/target/release/bin/main'),('session','source/tests/session_extensions/target/release/bin/main')]:
   ck(g['apps/'+role]['data']==(B/target).read_bytes(),name+' actual app bytes '+role)
  init=g['init']['data'].decode();ck(not any(x in init for x in ['setfont','unicode_start','unicode_stop','ESC%','printf']),name+' init has no font/codec setup')
  guestdetail.append({'archive':str(p),'sha256':sha(p),'members':len(g),'appHashes':{n:hashlib.sha256(g['apps/'+n]['data']).hexdigest() for n in ['glyph','session']}})
 old,new=guestsets.values();ck(set(old)==set(new),'Permission deployment archive membership unchanged')
 ck(all(old[k]['data']==new[k]['data'] for k in old),'Permission deployment archive all file contents unchanged')
 details['guestArchives']=guestdetail;details['permissionChanges']=[k for k in old if old[k]['mode']!=new[k]['mode']]
 # Read actual native output and compare policy results; no ANSI width emulator used as physical oracle.
 vt=[]
 for scene in sorted(p for p in (B/'raw/vt').iterdir() if p.is_dir()):
  name=scene.name;r=load(scene/'result.json');serial=(scene/'vt-serial.log').read_text();ev=scene/'evidence';tracepath=next(ev.glob('*.strace'));trace=tracepath.read_text()
  ck(r['initrdSha256'] in archives,name+' run archive exists by actual hash')
  ck(r['qemuExit']==0 and 'PRODUCT_EXIT=0 raw_status=0' in serial and 'termios_equal=1' in serial,name+' exit/termios')
  ck('stdout_tty=/dev/tty1' in serial and 'dev=4:1' in serial and 'GRID=80x25' in serial and 'KERNEL Linux 6.12.107+deb13-amd64' in serial,name+' genuine concrete kernel VT metadata')
  ck(('PRODUCT_ID uid=1000 euid=1000 gid=1000' if 'uid1000' in name else 'PRODUCT_ID uid=0 euid=0 gid=0') in serial,name+' actual execution UID')
  raw,inputs,fences,writes=trace_events(tracepath);ck(raw==(scene/'stdout-raw.ansi').read_bytes(),name+' all traced stdout equals sealed raw')
  ck(b'\x1b%' not in raw and not any(x in trace for x in ['PIO_UNIMAP','PIO_FONT','KDFONTOP','KDSETMODE']),name+' no product codec/font mutation')
  opened=re.findall(r'openat\([^\n]+',trace)
  decoded=[''.join(bytes.fromhex(x.replace('\\x','')).decode(errors='replace') for x in re.findall(r'"((?:\\x[0-9a-f]{2})*)"',s)) for s in opened]
  ck(not any('/dev/vcs' in x or '/dev/tty' in x for x in decoded),name+' no product screen observer/extra VT open')
  ck((ev/'vt-default-utf8.txt').read_text().strip() in ['Y','1'] and 'vt.default_utf8=' not in (ev/'boot-cmdline.txt').read_text(),name+' recorded UTF8 boot default; not current-console query')
  mapbytes=(ev/'unimap-0.bin').read_bytes();ck(mapbytes==(ev/'unimap-1000.bin').read_bytes() and len(mapbytes)==1212,name+' independent same root/user303 pair map')
  mappings=dict(struct.iter_unpack('<HH',mapbytes));ck(mappings[0xe9]==130 and 0x2026 not in mappings and 0x4e2d not in mappings,name+' actual sampled map')
  native=cells(scene/'1-RUNNING-vcsu1.bin');end=cells(next(scene.glob('*-EXIT-vcsu1.bin')))
  if name.startswith('glyph'):
   cap=profile(ev/'profile.txt');denied='deny' in name
   ck(cap['nativeVt']=='true' and cap['mapKnown']==str(not denied).lower() and cap['entryCount']==('0' if denied else '303'),name+' native capability values')
   ck(trace.count('ioctl(1, GIO_UNIMAP')==1 and 'ioctl(1, VT_GETMODE' in trace and 'ioctl(1, KDGETMODE' in trace,name+' one actual fd1 probe')
   if denied:ck('SECCOMP_MODE_FILTER' in trace and 'EACCES' in trace and cap['nativeError']=='13' and cap['reason']=='map-query-failed',name+' controlled seccomp failure, not natural permissions')
   else:ck(cap['source']=='linux-vt-unimap' and cap['nativeError']=='0',name+' successful actual map diagnostic')
   expected=original if 'unicode' in name else asciirow if ('ascii' in name or denied) else mapped
   ck(next(row for n,row in rowdata(raw) if n==2)==expected+' '*61,name+' hand golden full row2 output')
   if 'unicode' not in name:ck(native[80:160]==expected+' '*61 and 'BOX' in native,name+' actual kernel cell row2 and BOX')
   else:ck(all(c in native for c in ['é','中','文']),name+' actual decoded native Unicode scalars support empirical UTF8 chain')
   ck(original in (ev/'profile.txt.snapshot').read_text(),name+' independent offline snapshot preserves original')
   if name=='glyph-root-auto':
    ck(len(fences)==8,'Actual VT eight input p fences')
    ck(fences[0]==fences[1]==fences[2]==fences[3],'Actual VT 中→文→??→ZWJ projection-equal no writes')
    for s in r['stages']:
     screen=cells(scene/f"{s['gridSeq']}-RUNNING-vcsu1.bin");ck('BOX' in screen,'VT stable BOX '+s['name'])
     if s['name']=='narrow':ck(screen[:80]=='A'+' '*79,'Actual VT narrow clears first physical row')
  else:
   ck('CJTUI_SESSION_READY' in end and set(end.replace('CJTUI_SESSION_READY',''))<=set(' '),name+' exact final kernel native screen, no OSC payload leak')
   ck((ev/'all-wire.bin').read_bytes() in raw,name+' optional wire present in actual fd1 stream')
  vt.append({'scene':name,'actualSourceBinaryArchive':r['initrdSha256'],'inputHex':inputs.hex(),'writes':writes,'fences':len(fences),'mapSha256':hashlib.sha256(mapbytes).hexdigest(),'termiosRestored':True,'qemuExit':r['qemuExit']})
 details['vt']=vt
 gui=[]
 for host in ['xterm','vte']:
  p=B/'raw/gui'/host;stages=load(p/'stages.json');after=load(p/'terminal-after.json');raw,inputs,fences,writes=trace_events(p/'product.strace')
  ck(raw==(p/'stdout-raw.ansi').read_bytes(),'Actual GUI stdout '+host);ck(len(fences)==9,host+' nine actual p input fences')
  ck(after['exit']==0 and after['before']==after['after'] and after['grid']=='25 80',host+' process exit/termios/viewport')
  capkeys=['nativeVt','mapKnown','entryCount','source','reason','nativeError'];basecap=None
  for i,s in enumerate(stages):
   through=(p/(s['name']+'-stdout-through.raw')).read_bytes();delta=(p/(s['name']+'-stdout.delta')).read_bytes()
   ck(through==fences[i],host+s['name']+' stage output corresponds to actual p read fence')
   if i:ck(delta==through[len(fences[i-1]):],host+s['name']+' delta exact between real input fences')
   cap=profile(p/(s['name']+'-profile.txt'));facts={k:cap[k] for k in capkeys}
   if basecap is None:basecap=facts
   ck(facts==basecap and cap['nativeVt']=='false' and cap['mapKnown']=='false' and cap['source']=='unknown' and cap['reason']=='not-concrete-linux-vt',host+s['name']+' override facts unchanged')
   native=(p/f"native-{i}-range.txt").read_text() if host=='vte' else (p/(s['name']+'-native.ansi')).read_text()
   ck('BOX' in native,host+s['name']+' physical native BOX remains')
   if s['name'] in ['vs16','literal']:ck(not delta,host+s['name']+' actual zero bytes')
   if s['name']=='unicode':ck(original in through,host+' explicit Unicode raw preserved')
   if s['name'] in ['auto','auto-return']:ck(conservative in delta,host+' Auto returns conservative row')
   if s['name']=='ascii':ck(asciirow in delta,host+' explicit ASCII row')
  ck('GIO_UNIMAP' not in (p/'product.strace').read_text(),host+' unknown PTY never reads unimap')
  gui.append({'host':host,'inputHex':inputs.hex(),'writes':writes,'fences':len(fences),'exit':after['exit'],'physicalEvidence':'XTerm print' if host=='xterm' else 'VTE actual GTK terminal text; not complete cell attrs'})
 details['gui']=gui
 logical=(B/'raw/logical-files/logical.txt').read_bytes(); ansi=(B/'raw/logical-files/logical.ansi').read_bytes()
 ck(logical==(original+' '*11).encode(),'Actual offline plain file complete hand golden')
 ck(original.encode() in ansi and b'\x1b[1;1H' in ansi,'Actual offline ANSI file Unicode independent frame')
 for p,item in load(B/'raw/font-observer-inputs.json').items():ck(sha(p)==item['sha256'],'Exact font/observer input '+p)
 result={'utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'checks':checks,'details':details,'failed':0,'product_executed':False}
except Exception as e:
 result={'checks':checks,'details':details,'error':repr(e),'product_executed':False};(O/'raw/host-verification.json').write_text(json.dumps(result,ensure_ascii=False,indent=2));raise
(O/'raw/host-verification.json').write_text(json.dumps(result,ensure_ascii=False,indent=2))
print(json.dumps({'checks':len(checks),'failed':0,'kernelRuns':len(vt),'guiRuns':len(gui),'permissionOnlyChanges':len(details['permissionChanges'])}))

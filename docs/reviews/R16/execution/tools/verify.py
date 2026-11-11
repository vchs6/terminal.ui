from pathlib import Path
import json,re,struct,hashlib,subprocess,sys
from trace_bytes import extract
B=Path('/workspace/work/glyph-execution');checks=[]
def ck(ok,what):
 checks.append({'passed':bool(ok),'assertion':what})
 if not ok:raise AssertionError(what)
def prof(p):return dict(x.split('=',1) for x in p.read_text().splitlines() if '=' in x)
def rows(raw):
 return [(int(a),re.sub(r'\x1b\[[0-9;]*m','',b)) for a,b in re.findall(r'\x1b\[(\d+);1H([^\x1b]*(?:\x1b\[[0-9;]*m[^\x1b]*)*)',raw.decode())]
original='é e\u0301 中文 😀 ✈\ufe0f 👩‍💻 …';conservative='é e\u0301 中文 😀 ?? ?? …';mapped='é ? ???? ?? ?? ?? ?';ascii='? ? ???? ?? ?? ?? ?'
try:
 for name in ['root-build','glyph-api','glyph-public','glyph-negative','glyph-internal','glyph-rich','glyph-session','native-session','bundle','host-consumer-build','session-consumer-build','clean-build','clean-api-build-run']:
  ck(json.loads((B/'raw'/name/'meta.json').read_text())['exit']==0,f'{name} actualexit0')
 text=(B/'raw/glyph-negative/stdout.log').read_text();ck('PASS public capabilities snapshot is immutable' in text,'readonly six-field suite reached PASS after normal positive build')
 for field in ['nativeVt','mapKnown','entryCount','source','reason','nativeError']:ck(f"variable '{field}' is immutable" in text,f'readonly diagnostic {field}')
 dirs=[p for p in (B/'raw/glyph-session').iterdir() if p.is_dir() and (p/'result.json').exists()];ck(len(dirs)==25,'25 formal actualPTY/synthetic-native cases')
 for p in dirs:
  ck(json.loads((p/'result.json').read_text())['code']==0,p.name+' glyphsuiteexit0');ck((p/'before').read_bytes()==(p/'after').read_bytes(),p.name+' exacttermios');ck((p/'stdout.raw').read_bytes()==(p/'stdout-write.raw').read_bytes(),p.name+' actualPTYequalswritecapture')
 for p in (B/'raw/vt').iterdir():
  if not p.is_dir():continue
  scene=p.name;result=json.loads((p/'result.json').read_text());ck(result['qemuExit']==0,scene+' qemuExit0')
  text=(p/'vt-serial.log').read_text();ck('PRODUCT_EXIT=0 raw_status=0' in text and 'termios_equal=1' in text,scene+' actualproductexit0/exacttermios')
  evidence=p/'evidence';rootmap=(evidence/'unimap-0.bin').read_bytes();usermap=(evidence/'unimap-1000.bin').read_bytes();ck(rootmap==usermap and len(rootmap)==1212,scene+' actualroot/ttyowner1000 same303 map pairs');d=dict(struct.iter_unpack('<HH',rootmap));ck(d.get(0xe9)==130 and 0x2026 not in d and 0x4e2d not in d,scene+' actualmap sampled coverage')
  trace=next(evidence.glob('*.strace')).read_text();raw,stats=extract(trace);ck(not stats['pending'] and not stats['unparsedTarget'],scene+' complete actualstdout extraction');(p/'stdout-raw.ansi').write_bytes(raw);(p/'stdin-raw.bin').write_bytes(extract(trace,0,'read')[0]);(p/'stdout-parser.json').write_text(json.dumps(stats,indent=2))
  ck('vt.default_utf8=' not in (evidence/'boot-cmdline.txt').read_text(),scene+' no boot override defaultUTF8');ck((evidence/'vt-default-utf8.txt').read_text().strip() in ['Y','1'],scene+' recordedbootdefaultUTF8 (empirical chain, notcurrentquery)')
  if scene.startswith('glyph'):
   q=prof(evidence/'profile.txt');ck(q['nativeVt']=='true',scene+' product actualstdout concrete textVT');ck('ioctl(1, VT_GETMODE' in trace and 'ioctl(1, KDGETMODE' in trace,scene+' productVT/KD ioctls fd1');ck(trace.count('ioctl(1, GIO_UNIMAP')==1,scene+' once/run map query evenoverride')
   deny='deny'in scene;ck(q['mapKnown']==str(not deny).lower() and q['entryCount']==('0' if deny else '303'),scene+' caps mapfacts unchangedbyoverride')
   if deny:ck(q['source']=='linux-vt-unavailable' and q['reason']=='map-query-failed' and q['nativeError']=='13',scene+' controlledseccompEACCES classification')
   else:ck(q['source']=='linux-vt-unimap' and q['nativeError']=='0',scene+' real map success')
   expected=original if 'unicode'in scene else ascii if 'ascii'in scene or deny else mapped
   ck(any(n==2 and row==expected+' '*61 for n,row in rows(raw)),scene+' actual full80column row2 correctpolicy')
   ck('openat' in trace and not re.search(r'openat\([^\n]*(?:\\x76\\x63\\x73|/dev/vcs)',trace),scene+' no product VCS opens')
   ck((evidence/'profile.txt.snapshot').read_text().find(original)>=0,scene+' retained offline businessUnicode')
   if 'uid1000'in scene:ck('PRODUCT_ID uid=1000 euid=1000 gid=1000' in text,scene+' actualnonroot normal app')
   if scene=='glyph-root-unicode':
    stage=json.loads((p/'result.json').read_text())['stages'][0];blob=(p/f"{stage['gridSeq']}-RUNNING-vcsu1.bin").read_bytes();cells=struct.unpack('<'+'I'*(len(blob)//4),blob);ck(0xe9 in cells and 0x4e2d in cells and 0x6587 in cells,scene+' actualknownUTF8 Unicode cells complementoriginalPNG/defaultchain')
   if scene=='glyph-root-auto':
    stages=result['stages'];
    for st in stages:
     blob=(p/f"{st['gridSeq']}-RUNNING-vcsu1.bin").read_bytes();cells=struct.unpack('<'+'I'*(len(blob)//4),blob);native=''.join(chr(x) for x in cells);(p/(st['name']+'-native.txt')).write_text('\n'.join(native[i*80:(i+1)*80] for i in range(25)))
    ck((p/'initial-native.txt').read_text().splitlines()[1].startswith(mapped),'VT actualAuto native row2 correctfallback')
    ck((p/'narrow-native.txt').read_text().splitlines()[0]=='A'+' '*79,'VT wide→narrow clears actualnative residual')
  else:
   results=(evidence/'results.tsv').read_text();ck('completed\tyes' in results,scene+' formal148 completed');ck('Applied' not in results and 'RestoreConfirmed' not in results,scene+' nofalseconfirmation')
   blob=(p/'1-RUNNING-vcsu1.bin').read_bytes();cells=struct.unpack('<'+'I'*(len(blob)//4),blob);native=''.join(chr(x) for x in cells);ck('CJTUI_SESSION_READY' in native,scene+' core app present native cells')
   # final post-operation grid comes from supervisor EXIT, inspect for payload leakage.
   exitbins=list(p.glob('*-EXIT-vcsu1.bin'));ck(bool(exitbins),scene+' final native screen')
   final=''.join(chr(x[0]) for x in struct.iter_unpack('<I',exitbins[0].read_bytes()));ck(not any(token in final for token in ['Zg==','Zm8=','Zm9v',';c;','中','CJTUI_HOST_']),scene+' noOSCpayloadleak in actualnative grid')
 for host in ['xterm','vte']:
  p=B/'raw/gui'/host;meta=json.loads((p/'terminal-after.json').read_text());ck(meta['exit']==0 and meta['before']==meta['after'],host+' actualexit0/exacttermios');stages=json.loads((p/'stages.json').read_text());ck(len(stages)==9,host+' actualnine stages')
  for st in stages:
   q=prof(p/(st['name']+'-profile.txt'));ck(q['nativeVt']=='false' and q['source']=='unknown' and q['reason']=='not-concrete-linux-vt',host+st['name']+' honestunknown facts')
  for name in ['vs16','literal']:ck((p/(name+'-stdout.delta')).stat().st_size==0,host+' projected-equivalent '+name+' zero actualwrites')
  ck('??' in (p/'zwj-stdout.delta').read_text(),host+' G012ZWJ fallbackbytes');ck(original in (p/'unicode-stdout-through.raw').read_text(),host+' explicitUnicode originalraw');ck(conservative in (p/'auto-stdout.delta').read_text(),host+' Auto restoresconservative');ck(ascii in (p/'ascii-stdout.delta').read_text(),host+' explicitAscii')
  trace=(p/'product.strace').read_text();raw,stats=extract(trace);ck(not stats['pending'] and not stats['unparsedTarget'],host+' completestdouttrace');ck('GIO_UNIMAP' not in trace,host+' unknownnevermapreads')
  for st in stages:
   native=(p/f"native-{st['index']}-range.txt").read_text() if host=='vte' else re.sub(r'\x1b\[[0-9;]*[A-Za-z]','',(p/(st['name']+'-native.ansi')).read_text())
   ck('BOX' in native,host+st['name']+' actualnative BOX anchor remains')
   if st['name'] in ['initial','auto','auto-return']:ck('?? ??' in native,host+st['name']+' actualnative safe sourcefallback')
 print('PASS',len(checks),'independent evidence checks')
except BaseException as err:
 (B/'raw/verification.json').write_text(json.dumps({'checks':checks,'error':repr(err)},indent=2));raise
(B/'raw/verification.json').write_text(json.dumps({'checks':checks,'failed':0},indent=2))

from pathlib import Path
import json,re,hashlib,subprocess,datetime,tomllib
from PIL import Image
B=Path('/workspace/work/theme-execution');O=Path('/workspace/work/theme-acceptance');R=Path('/workspace/work/terminal.ui');P='8d75233c664fd61be08d441f74d464cbcdff2d9c';checks=[];details={}
def ck(v,label):
 checks.append({'passed':bool(v),'assertion':label})
 if not v:raise AssertionError(label)
def data(p):
 p=Path(p);assert 'theme-implementation' not in p.parts and 'glyph-implementation' not in p.parts;return p.read_bytes()
def h(p):return hashlib.sha256(data(p)).hexdigest()
def load(p):return json.loads(data(p))
def git(path,commit=P):return subprocess.check_output(['git','-C',str(R),'show',commit+':'+path])
def fields(p):return dict(x.split('=',1) for x in data(p).decode().splitlines() if '=' in x)
def rows(blob):return [(int(n),re.sub(r'\x1b\[[0-9;]*m','',s)) for n,s in re.findall(r'\x1b\[(\d+);1H([^\x1b]*(?:\x1b\[[0-9;]*m[^\x1b]*)*)',blob.decode())]
def writes(trace):
 out=bytearray();pending={};count=0
 for line in trace.splitlines():
  m=re.match(r'\s*(\d+)\s+(.*)',line);pid,body=m.groups() if m else ('single',line)
  if body.startswith('write(1, '):
   m=re.match(r'write\(1, "((?:\\x[0-9a-f]{2})*)"',body);ck(bool(m),'Trace full hex write');blob=bytes.fromhex(m[1].replace('\\x',''))
   if '<unfinished ...>' in body:pending[pid]=blob;continue
  elif body.startswith('<... write resumed>') and pid in pending:blob=pending.pop(pid)
  else:continue
  m=re.search(r'= (-?\d+)(?:\s|$)',body);ck(bool(m),'Trace returned bytes');n=int(m[1]);ck(n<=len(blob),'Trace not truncated')
  if n>0:out.extend(blob[:n]);count+=1
 ck(not pending,'No incomplete trace writes');return bytes(out),count
try:
 oracle=git('tests/themes/glyph-pty.mjs');ck(oracle==data(B/'product/tests/themes/glyph-pty.mjs'),'Frozen formal Glyph oracle bytes')
 details['formal_oracle_sha256']=hashlib.sha256(oracle).hexdigest()
 unicode=['     ','…    ','A…   ','AB…  ','ABC… ','ABC…q','éBC… ','👩‍💻   ']
 ascii=['     ','.    ','..   ','...  ','A... ','A...q','?... ','??   ']
 missing=['     ','.    ','..   ','...  ','A... ','A...q','é... ','??   ']
 present=['     ','…    ','A…   ','AB…  ','ABC… ','ABC…q','éBC… ','??   ']
 cases=[('unknown-auto','real','Auto',present,False),('unknown-unicode','real','Unicode',unicode,False),('unknown-ascii','real','Ascii',ascii,False),('mapped-present','mapped','Auto',present,True),('mapped-missing','no-ellipsis','Auto',missing,True),('mapped-unicode','no-ellipsis','Unicode',unicode,True),('mapped-ascii','no-ellipsis','Ascii',ascii,True)]
 control=[('control-unknown','real','Auto','é …  ',False),('control-mapped','mapped','Auto','é …  ',True),('control-missing','no-ellipsis','Auto','é ?  ',True)]
 results=[]
 for group,items in [('control-pty',control),('theme-pty',cases)]:
  for name,scenario,mode,expected,known in items:
   p=B/'raw/glyph-all/detail'/group/name;record=load(p/'result.json');ck(record['code']==0 and record['signal'] is None and record['scenario']==scenario and record['mode']==mode and record['expected']==expected,'Actual controlled result '+name)
   blob=data(p/'writes.raw');ck(blob==data(p/'stdout.raw'),'Actual PTY output equals capture '+name);actual=rows(blob)
   ck(actual[0][1]==expected if group=='control-pty' else [x[1] for x in actual[:8]]==expected,'Frozen row goldens '+name)
   ck(data(p/'before').strip()==data(p/'after').strip(),'PTY termios '+name)
   f=fields(p/'report.txt');ck(f['mapKnown']==str(known).lower() and f['nativeVt']==str(known).lower() and f['entryCount']==('104' if known else '0') and f['source']==('linux-vt-unimap' if known else 'unknown') and f['nativeError']=='0','PTY final facts '+name)
   trace=data(p/'syscalls.txt').decode() if (p/'syscalls.txt').exists() else '';ck(trace.count('unimap capacity=')==(1 if known else 0),'One map query '+name)
   if scenario=='no-ellipsis':ck('theme-filter ellipsis-removed=1 pairs=104\n' in trace,'Controlled missing marker '+name)
   if group=='theme-pty':
    for suffix,golden in [('default',unicode),('auto',unicode),('ascii',['     ','.    ','..   ','...  ','A... ','A...q','é... ','👩‍💻   '])]:ck(data(p/('report.txt.'+suffix)).decode()=='\n'.join(golden),'Logical offline separation '+name+'/'+suffix)
   if name=='mapped-missing':ck([s for n,s in actual if n==5]==['A... ','ABC… ','A... '],'Actual setter roundtrip and same-value silence')
   results.append({'name':name,'passed':True,'synthetic_map':known})
 details['controlled_originals']=results
 commands=[json.loads(x) for x in data(B/'raw/glyph-all/detail/commands.jsonl').decode().splitlines()];ck(all(x['exit']==0 and x['sha']==P for x in commands),'Full Glyph runner direct command results');details['glyph_commands']=len(commands)
 ck(data(B/'observation-glyph/src/main.cj')==git('tests/themes/glyph-session/src/main.cj'),'Genuine GUI Glyph consumer exact formal source no wrapper')
 ck(b'Column { Text("x"); Text("y").styles([StyleUse.Named("accent")]) }' in data(B/'observation/src/main.cj'),'Genuine fourpreset scene equals formal hand golden')
 guis=[]
 for family in ['gui','gui-glyph']:
  for p in sorted((B/'raw'/family).iterdir()):
   if not p.is_dir():continue
   before=load(p/'terminal-before.json');after=load(p/'terminal-after.json');launch=load(p/'launch.json');capture=load(p/'capture.json')
   ck(after['exit']==0 and before['before']==after['before']==after['after'] and before['grid']=='25 80','Actual GUI size/exit/termios '+p.name)
   ck(launch['utc']<capture['utc']<after['utcEnd'],'Screenshot before completed normal exit '+p.name)
   binary=B/('observation' if family=='gui' else 'observation-glyph')/'target/release/bin/main';ck(h(binary)==launch['binarySha256'],'Actual GUI binary '+p.name)
   written,count=writes(data(p/'product.strace').decode());ck(written==data(p/'stdout.raw'),'Independent write trace equals stdout '+p.name)
   f=fields(p/'profile.txt');ck(f['nativeVt']=='false' and f['mapKnown']=='false' and f['source']=='unknown','Real GUI is unknown-map '+p.name)
   if p.name.startswith('vte-'):
    native=data(p/'native-0-range.txt').decode();meta=load(p/'native-0-meta.json');ck(meta['rows']==25 and meta['cols']==80 and not meta['errorPresent'],'Actual VTE widget metadata')
   else:native=re.sub(r'\x1b(?:\[[0-?]*[ -/]*[@-~]|#[0-9])','',data(p/'native-grid.ansi').decode())
   expected=['x','y'] if family=='gui' else (['','.','..','...','A...'] if p.name.endswith('Ascii') else ['','…','A…','AB…','ABC…'])
   ck([s.rstrip(' ') for s in native.splitlines()[:len(expected)]]==expected,'Actual native viewport golden '+p.name)
   rawrows=rows(written);ck([s.rstrip(' ') for n,s in rawrows[:len(expected)]]==expected,'Actual encoded row golden '+p.name)
   with Image.open(p/'preset.png') as im:ck(im.format=='PNG' and im.width>500 and im.height>300,'Original PNG dimensions '+p.name);size=list(im.size)
   guis.append({'family':family,'host':p.name,'native_rows':expected,'writes':count,'png_sha256':h(p/'preset.png'),'png_size':size,'binary_sha256':h(binary),'exit':0,'termios_equal':True,'utc_end':after['utcEnd']})
 ck(len(guis)==12,'12 genuine GUI records');details['guis']=guis
 stdx=load(B/'raw/stdx-hashes.json')
 for p,s in stdx.items():ck(h(B/'stdx-env/linux_x86_64_llvm'/p)==s,'Official stdx '+p)
 details['stdx_files']=len(stdx)
 prior=load(B/'raw/reuse/r16-physical-facts.json')
 for p in prior['selected_unchanged']:ck(git(p)==git(p,'b3b24f896672336797cec009cfe0cd830a955aa7'),'Prior unchanged backend/test '+p)
 for r in prior['png_inventory']:ck(h(r['path'])==r['sha256'],'Prior immutable PNG reference')
 details['prior_reuse']={'unchanged_selected':len(prior['selected_unchanged']),'png_refs':len(prior['png_inventory']),'scope':'backend/kernel/font facts only, no current Theme proof'}
 clean=Path(data(B/'raw/package/library-path.txt').decode().strip());paths=[x['git_path'] for x in load(B/'raw/package/member-inventory.json')]
 allowed=re.compile(r'^(?:src/|examples/|benchmarks/|themes/|docs/product/|native/.*\.(?:sh|c|h|S|cj)$|third_party/licenses/|build\.cj$|cjpm\.toml$|README(?:_zh)?\.md$|LICENSE$|NOTICE$|CHANGELOG\.md$)')
 for p in paths:
  ck(bool(allowed.match(p)) and not re.search(r'\.(a|o|so|cjo|cjp|zip|tar|gz)$',p) and not any(x.startswith('.') or x in ['target','node_modules','cache','build-script-cache'] for x in Path(p).parts),'Package product-only boundary with required themes '+p)
  if p.endswith('cjpm.toml'):
   d=tomllib.loads(data(clean/p).decode())
   for name,dep in d.get('dependencies',{}).items():
    ck('git' not in dep,'Normal dependency '+p+'/'+name)
    if p=='cjpm.toml':ck('path' not in dep,'Central root dependency '+name)
    if 'path' in dep:ck(not Path(dep['path']).is_absolute() and (clean/p).parent.joinpath(dep['path']).resolve().is_relative_to(clean.resolve()),'Internal package path '+p)
 details['boundary']={'all175_product_files':True,'themes_required_by':'T010','whole_checker_exit_retained':1,'checker_repair_scope':'complete-linux-integration tasks023.a–d'}
except Exception:
 (O/'raw/observations.json').write_text(json.dumps({'utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'failed':1,'checks':checks,'details':details},ensure_ascii=False,indent=2)+'\n');raise
(O/'raw/observations.json').write_text(json.dumps({'utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'failed':0,'checks':checks,'details':details,'product_executed':False},ensure_ascii=False,indent=2)+'\n')
print(json.dumps({'failed':0,'checks':len(checks),'controlled':len(results),'genuine_gui':len(guis),'stdx':len(stdx),'prior':details['prior_reuse']},ensure_ascii=False))

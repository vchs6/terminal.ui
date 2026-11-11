from pathlib import Path
import json,hashlib,subprocess,tarfile,re,datetime
from PIL import Image

B=Path('/workspace/work/glyph-execution'); O=Path('/workspace/work/glyph-acceptance'); R=Path('/workspace/work/terminal.ui')
product='1f67e27358254e9daef637b5c2f5a93707ee7cef'; root='b3b24f896672336797cec009cfe0cd830a955aa7'
checks=[]; details={}
def ck(ok,label):
 checks.append({'check':label,'passed':bool(ok)})
 if not ok:raise AssertionError(label)
def digest(b):return hashlib.sha256(b).hexdigest()
def read(p):
 p=Path(p);ck('/glyph-implementation/' not in str(p),'Allowed input: '+str(p))
 return p.read_bytes()
def h(p):return digest(read(p))
def pairs(items):
 d={}
 for k,v in items:
  if k in d:raise ValueError('duplicate JSON key '+k)
  d[k]=v
 return d
def load(p):return json.loads(read(p),object_pairs_hook=pairs,parse_constant=lambda v: (_ for _ in ()).throw(ValueError(v)))
def git(commit,p):return subprocess.check_output(['git','-C',str(R),'show',commit+':'+p])
try:
 top=load(B/'manifest.json'); C=Path(top['curated']); m=load(C/'manifest.json')
 ck(h(B/'artifacts.sha256')=='9e08fce5eccbb44c4a035a175c828667911cc19ecb157da2824e9920229eab43','Root-fixed096 artifacts index')
 ck(h(C/'manifest.json')=='a1f9ff4cb1c7804d4e04c8e78c3060c7b1041e06cb9c2eefbb09cf0c3807f597','Root-fixed096 curated manifest')
 names=set()
 for item in m['sourceToCurated']:
  source=Path(item['source']); dest=C/item['curated']; a=read(source); b=read(dest)
  ck(a==b and len(a)==item['size'] and digest(a)==item['sha256'],'Original/curated/hash '+item['curated']);names.add(item['curated'])
 ck(len(names)==1389,'1389 unique source-copy entries')
 index={}
 for line in read(B/'artifacts.sha256').decode().splitlines():
  expected,name=line.split(None,1);name=name.lstrip('*');ck(name not in index,'Unique index '+name); index[name]=expected
  ck(h(C/name)==expected,'Index bytes '+name)
 ck(set(index)==names|{'manifest.json'},'1390 index entries exact, manifest included')
 actual={str(p.relative_to(C)) for p in C.rglob('*') if p.is_file()}
 ck(actual==names|{'manifest.json','artifacts.sha256'},'Curated exact inventory, no extra payload')
 ck(read(C/'artifacts.sha256')==read(B/'artifacts.sha256'),'Original and curated index bytes same')
 for item in m['omitted']:ck(h(item['source'])==item['sha256'],'Omitted external hash '+item['source'])
 jsons=[p for p in C.rglob('*.json') if p.is_file()]
 for p in jsons:load(p)
 details['archive']={'sourceCopies':len(names),'checksumEntries':len(index),'actualFiles':len(actual),'strictJSONFiles':len(jsons),'omittedInputs':len(m['omitted']),'curatedUtc':m['curatedUtc']}
 # Independently match every listed execution source against actual bytes and git.
 sources=load(B/'raw/source-inventory.json')
 for p,expected in sources.items():
  b=read(B/'source'/p);ck(digest(b)==expected and b==git(root,p),'Execution tracked source '+p)
 details['executionSourceFiles']=len(sources)
 fixed=load(B/'raw/fixed-inputs-and-binaries.json')
 for p,item in fixed['files'].items():ck(h(p)==item['sha256'] and Path(p).stat().st_size==item['size'],'Actual external input '+p)
 for p,expected in fixed['dependencySourceFiles'].items():ck(h(B/p)==expected,'Dependency '+p)
 details['externalInputs']=len(fixed['files']);details['dependencyFiles']=len(fixed['dependencySourceFiles'])
 ck(read(B/'host-consumer/src/main.cj')==git(root,'tests/glyphs/session/src/main.cj'),'Unwrapped host consumer source matches official093')
 ck(read(B/'clean-api/src/main.cj')==git(root,'tests/glyphs/api/src/main.cj'),'Clean consumer source matches official093')
 # Read tar members directly; do not execute binaries or modify execution tree.
 pkg=load(B/'raw/package-members.json');ck(h(pkg['archive'])==pkg['sha256'],'Actual CJP hash')
 actualmembers=[]
 with tarfile.open(pkg['archive'],'r:*') as t:
  for item in t.getmembers():
   if not item.isfile():continue
   p=item.name
   if p.startswith('cjtui-0.0.0/'):p=p[len('cjtui-0.0.0/'):]
   b=t.extractfile(item).read();ck(b==git(product,p),'All CJP member bytes '+p)
   ck(read(B/'clean-extract/cjtui-0.0.0'/p)==b,'Post-build clean source '+p)
   actualmembers.append({'path':p,'sha256':digest(b),'size':len(b)})
 ck(len(actualmembers)==143,'143 actual CJP regular members')
 ck(sorted(actualmembers,key=lambda x:x['path'])==sorted(pkg['members'],key=lambda x:x['path']),'Whole member metadata exact')
 details['package']={'path':pkg['archive'],'sha256':pkg['sha256'],'members':actualmembers}
 # Only 096 copied raw, never dereference original author paths.
 reuse=load(B/'raw/reuse-verified-manifest.json'); review=load(Path('/workspace/work/glyph-review/reviewed-hashes.json'))
 for item in reuse['files']:
  ck(h(B/item['ownCopy'])==item['sha256'],'096 reused exact copy '+item['ownCopy'])
  rel=item['original'].split('/glyph-implementation/',1)[-1]
  if rel in review['raw']:ck(review['raw'][rel]==item['sha256'],'095 independent prior raw hash '+rel)
 details['reusedRawFiles']=len(reuse['files'])
 # Process completion/seal times; full host file hashes; lossless actual QMP pixels.
 hosts=load(B/'raw/host-artifacts-after-exit.json')
 for p,item in hosts['postExitFiles'].items():ck(h(B/p)==item['sha256'],'Final host original '+p)
 for item in hosts['ppmPng']:
  a=Image.open(B/item['ppm']).convert('RGB'); b=Image.open(B/item['png']).convert('RGB')
  ck(a.size==(720,400) and a.size==b.size and a.tobytes()==b.tobytes(),'QMP PPM/PNG decoded pixels '+item['png'])
 finaltimes=[]
 for p in (B/'raw/vt').glob('*/result.json'):
  x=load(p);ck(x['qemuExit']==0,'QEMU exit '+x['scene']);ck(x['utcEnd']<m['curatedUtc'],'Seal after QEMU exit '+x['scene']);finaltimes.append(x['utcEnd'])
 gui=load(B/'raw/gui/summary.json');ck(gui['xorgExit']==0 and gui['utcEnd']<m['curatedUtc'],'Seal after Xorg exit');finaltimes.append(gui['utcEnd'])
 details['actualImages']={'png':sum(p.endswith('.png') for p in hosts['postExitFiles']),'losslessQmpPairs':len(hosts['ppmPng']),'hostFileHashes':len(hosts['postExitFiles']),'lastHostExit':max(finaltimes)}
 # Actual command metadata and unsuppressed bundle diagnostics.
 commands=[]
 for name in ['environment','root-build','glyph-api','glyph-public','glyph-negative','glyph-internal','glyph-rich','glyph-session','native-session','bundle','host-consumer-build','session-consumer-build','clean-build','clean-api-build-run','whole-bundle-check']:
  x=load(B/'raw'/name/'meta.json');ck(x['exit']==(1 if name=='whole-bundle-check' else 0),'Actual exit '+name);commands.append({'label':name,**x})
 details['commands']=commands
 bundle=read(B/'raw/bundle/stdout.log')+read(B/'raw/bundle/stderr.log')
 plain_bundle=re.sub(rb'\x1b\[[0-9;]*m',b'',bundle)
 ck(len(re.findall(rb'warning:',plain_bundle))==353,'353 normal bundle warnings independently counted after SGR removal')
 ck(b'examples/composition/cjpm.toml' in read(B/'raw/whole-bundle-check/stdout.log')+read(B/'raw/whole-bundle-check/stderr.log'),'Whole checker missing composition retained')
 ck(not any(x['path'].startswith('benchmarks/') for x in actualmembers),'Benchmark absent, full release not claimed')
 details['warnings']=353
 result={'utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'checks':checks,'details':details,'failed':0,'product_executed':False}
except Exception as e:
 result={'utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'checks':checks,'details':details,'error':repr(e),'product_executed':False}
 (O/'raw/integrity.json').write_text(json.dumps(result,ensure_ascii=False,indent=2));raise
(O/'raw/integrity.json').write_text(json.dumps(result,ensure_ascii=False,indent=2))
print(json.dumps({'checks':len(checks),'failed':0,'archive':details['archive'],'sourceFiles':details['executionSourceFiles'],'dependencies':details['dependencyFiles'],'packageFiles':len(actualmembers),'images':details['actualImages']},ensure_ascii=False))

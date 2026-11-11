from pathlib import Path
import json,hashlib,subprocess,datetime,re,ast,tarfile
B=Path('/workspace/work/theme-load-execution');O=Path('/workspace/work/theme-load-acceptance');R=Path('/workspace/work/terminal.ui');P='fa6a46ec339ea0f098dea521c814226a7a373c7e';checks=[];detail={};consumed={}
(O/'raw').mkdir(exist_ok=True)
def ck(v,label):
 checks.append((bool(v),label))
 if not v:raise AssertionError(label)
def data(p):
 p=Path(p);assert not any(x in p.parts for x in ['theme-implementation','theme-load-implementation','glyph-implementation']);b=p.read_bytes();consumed[str(p)]=hashlib.sha256(b).hexdigest();return b
def h(p):return hashlib.sha256(data(p)).hexdigest()
def digest(b):return hashlib.sha256(b).hexdigest()
def load(p):
 def pairs(xs):
  d={}
  for k,v in xs:
   if k in d:raise ValueError('duplicate '+k)
   d[k]=v
  return d
 return json.loads(data(p),object_pairs_hook=pairs,parse_constant=lambda x:(_ for _ in ()).throw(ValueError(x)))
def git(p,c=P):return subprocess.check_output(['git','-C',str(R),'show',c+':'+p])
try:
 source=load(B/'raw/async-all/pre-source.json');ck(len(source)==274,'274 fixed input hashes')
 for p,s in source.items():ck(h(B/'product'/p)==s==digest(git(p)),'Fixed Git/product '+p)
 commands=[];envseen={}
 for f in sorted((B/'raw').glob('*/command.json')):
  c=load(f);name=f.parent.name;ck(c['head']==P and c['utc']<=c['end_utc'],'Exact command identity/UTC '+name)
  ck(c['exit']==(1 if name=='device-build' else 0),'Actual command exit '+name)
  ck(load(f.parent/'pre-source.json')==source==load(f.parent/'post-source.json'),'Pre/post source '+name)
  env=load(f.parent/'pre-environment.json')
  for p,s in env['hashes'].items():
   if p not in envseen:ck(h(p)==s,'Actual environment '+p);envseen[p]=s
   else:ck(envseen[p]==s,'Unchanged recorded environment '+p)
  commands.append(c|{'group':name})
 detail['commands']=commands;detail['environment_files']=len(envseen)
 # Only Python literal CASES from the fixed official runner; no runner execution.
 runner=git('tests/theme-loading/run.py').decode();tree=ast.parse(runner);case_node=next(x.value for x in tree.body if isinstance(x,ast.Assign) and any(isinstance(t,ast.Name) and t.id=='CASES' for t in x.targets));cases={}
 for k,v in zip(case_node.keys,case_node.values):cases[ast.literal_eval(k)]=set() if isinstance(v,ast.Call) and isinstance(v.func,ast.Name) and v.func.id=='set' and not v.args else ast.literal_eval(v)
 detail['formal_runner_sha256']=digest(runner.encode());case_records=[]
 for group,wanted in [('async-all',set(cases)-{'infrastructure'}),('clean-async',{'latest-success','atomic-caches'})]:
  d=B/'raw'/group/'detail';cmd=[json.loads(x) for x in data(d/'commands.jsonl').decode().splitlines()];recorded=set()
  for c in cmd:
   ck(c['exit']==0 and c['sha']==P,'Formal actual exit/source '+group+'/'+c['name'])
   if c['name'] not in cases:continue
   name=c['name'];ck(c['controller_error'] is None,'No controller error '+name)
   ck('PASS CASE '+name in data(d/(name+'.stdout')).decode(),'Actual case completion '+name)
   events=load(d/(name+'.events.json'));entered=set();active=set();released=set();release_commands=set();maxactive=0
   for e in events:
    if e['kind']=='io-enter':
     key=(e['file'],e['sequence']);ck(key in cases[name] and key not in entered,'Only expected once actual IO '+name)
     ck(name=='multi-application' or not active,'One active gated read '+name);entered.add(key);active.add(key);maxactive=max(maxactive,len(active))
    elif e['kind']=='io-released':
     key=(e['file'],e['sequence']);ck(key in active and key in release_commands,'Release after actual gate command '+name);active.remove(key);released.add(key)
    elif e['kind']=='barrier':
     parts=e['command'].split(':')
     if parts[0] in ['entered','release']:
      key=(parts[1],int(parts[2]));ck(key in entered,'Barrier follows actual IO '+name)
      if parts[0]=='release':ck(key not in release_commands,'One release '+name);release_commands.add(key)
   ck(entered==released==cases[name] and not active,'All required real IO gates completed '+name)
   if name=='multi-application':ck(maxactive==2,'Two applications concurrently entered independent reads')
   stderr=data(d/(name+'.stderr')).decode();observed={(a,int(b)) for a,b in re.findall(r'THEME_GATE ENTER (\S+) (\d+)',stderr)};ck(observed==entered,'Actual native stderr matches event metadata '+name)
   recorded.add(name);case_records.append({'group':group,'case':name,'exit':0,'real_gates':sorted(entered),'maximum_observed_gated_reads':maxactive})
  ck(wanted<=recorded and (group!='async-all' or recorded==wanted|{'infrastructure'}),'Full requested case set '+group)
 detail['case_records']=case_records
 atomic=data(B/'raw/async-all/detail/atomic-caches.stdout').decode()
 ck('OBSERVED after mounted subtree: failed:InvalidCandidate info=SubtreeBase' in atomic and 'OBSERVED candidate minima: error=[], result=failed:InvalidCandidate' in atomic,'Both actual fixed root/subtree rejection observations')
 for p,n in [('raw/async-all/detail/source-hashes.json','async')]:
  hashes=load(B/p);formal=set(subprocess.check_output(['git','-C',str(R),'ls-tree','-r','--name-only',P,'tests/theme-loading']).decode().splitlines());tracked=0;extras=[]
  for path,s in hashes.items():
   rel='tests/theme-loading/'+path
   if rel in formal:ck(digest(git(rel))==s,'Official async source '+path);tracked+=1
   else:ck('build-script-cache' in Path(path).parts,'Generated source-inventory extra '+path);extras.append(path)
  detail['test_inventory']={'tracked':tracked,'generated_cache_extras':len(extras)}
 pkg=B/'product/target/cjtui-0.0.0.cjp';meta=load(B/'raw/package/package.json');ck(h(pkg)==meta['archive_sha256']=='83620d95e01870b0eab6966c0d1bde8ece13a7c5de9b07654d252eb545d0c2bc','Actual final CJP hash')
 members={x['member']:x for x in load(B/'raw/package/member-inventory.json')};clean=Path(data(B/'raw/package/library-path.txt').decode().strip());seen=[]
 with tarfile.open(pkg,'r:gz') as t:
  for e in t.getmembers():
   ck(e.isfile() or e.isdir(),'Only regular/directories in CJP');ck(not e.name.startswith('/') and '..' not in Path(e.name).parts,'Safe archive path')
   if not e.isfile():continue
   rec=members[e.name];p=rec['git_path'];b=t.extractfile(e).read();ck(b==git(p)==data(clean/p) and digest(b)==rec['sha256'],'Actual CJP/Git/clean bytes '+p);seen.append(p)
 ck(len(seen)==len(members)==184,'All184 package members')
 for x in load(B/'raw/package/clean-consumer-source-identity.json')['files']:
  p=x['path'];original=git(p);current=data(B/'clean-consumer'/p)
  if p.endswith('cjpm.toml'):ck(current==original.replace(b'path = "../../.."',b'path = "../../../package/cjtui-0.0.0"'),'Only clean dependency path changed')
  else:ck(current==original,'Clean full formal consumer '+p)
  ck(digest(original)==x['fixed_source_sha256'] and digest(current)==x['copied_sha256'],'Clean source metadata '+p)
 detail['package']={'sha256':h(pkg),'members':184,'clean_library_and_full_consumer_sources_equal':True,'clean_cases':['latest-success','atomic-caches']}
 # Original regular-file gate and linked fault fixture are input mechanisms, not fake Theme results.
 native=git('tests/session_extensions/native/session_fault.c');ck(native==data(B/'device-observation/native/session_fault.c'),'Existing formal session fault fixture exact bytes')
 driver=load(B/'raw/device-pty-bound/pre-driver-binary.json');ck(driver==load(B/'raw/device-pty-bound/post-driver-binary.json'),'Actual PTY driver pre/post binding')
 for p,s in driver.items():ck(h(B/p)==s,'Exact device driver/source/binary '+p)
 d=B/'raw/device-pty-bound/detail';events=[x.split('\t') for x in data(d/'native.tsv').decode().splitlines()]
 ck(events[:6]==[['open','0','0'],['arm','1','4'],['sequence','1','0'],['write','1','4'],['fault','1','4'],['sequence-result','-1','4']],'Actual4 bytes then EIO in real writer')
 ck(events[6:]==[['signal-restored','28','1'],['signal-restored','2','1'],['signal-restored','15','1'],['close','0','0']],'No subsequent sequence/poll; handlers and close restored')
 raw=data(d/'stdout.raw');partial=data(d/'armed-write.raw');ck(len(partial)==4 and raw.endswith(partial) and b'TASK091_BASE' in raw[:-4],'Real first frame plus recorded partial write')
 ck(data(d/'before').strip()==data(d/'after').strip() and data(d/'exit').strip()==b'0' and data(d/'grid').strip()==b'3 20','PTY termios grid and actualexit')
 info=dict(line.split('=',1) for line in data(d/'after.txt').decode().splitlines());ck('terminal write failed' in info['failure'] and 'ParserUnsynchronized' in info['failure'] and 'visual state not restored' in info['failure'],'Failure status honestly retained')
 ck(info['name']=='Accepted' and info['revision']==info['applied']=='1' and info['id']==info['requestId']=='1','Applied/ThemeInfo survives device failure')
 ck(all(info[k]=='0' for k in ['mounted','bindings','subscriptions','posts']),'Runtime resources cleaned')
 detail['device']={'actual_partial_bytes':4,'partial_hex':partial.hex(),'reported_state':info,'termios_restored':True,'handlers_restored':[28,2,15],'visual_state_restored':False,'mode':'Real PTY / controlled linked write syscall EIO, not a natural kernel failure or callback exception','driver_hashes':driver}
 lint=re.sub(r'\x1b\[[0-9;]*m','',(data(B/'raw/bundle/stdout')+data(B/'raw/bundle/stderr')).decode());ck(len(re.findall(r'\bwarning:',lint))==508,'508 actual mandatory-lint diagnostics');detail['lint_warnings']=508
 reuse=load(B/'raw/reuse/normal-dependency-reuse.json');ck(h(reuse['dependency_source_baseline'])==reuse['baseline_sha256'],'Fixed accepted dependency index')
 for x in load(reuse['dependency_source_baseline']):ck(h(B/'cache'/x['path'])==x['sha256'],'Same ordinary dependency '+x['path'])
 ck(h(reuse['official_stdx_baseline'])==reuse['stdx_baseline_sha256'],'Fixed stdx index')
 for p,s in load(reuse['official_stdx_baseline']).items():ck(h(Path('/workspace/work/linux-build-recon/stdx-env/linux_x86_64_llvm')/p)==s,'Official stdx '+p)
 detail['dependency_reuse']={'dependency_source_files':375,'official_stdx_files':371}
 for p,r in load(B/'raw/identity/binary-runtime-hashes.json').items():
  ck(h(p)==r['binary_sha256'],'Actual binary '+p)
  for path,s in r['runtime_files'].items():ck(h(path)==s,'Actual linked runtime '+path)
except Exception:
 put={'utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'failed':1,'failed_assertions':[label for ok,label in checks if not ok],'check_count':len(checks),'detail':detail,'consumed_hashes':consumed,'acceptance_verdict':'NOT_ASSESSED'}
 (O/'raw/verification.json').write_text(json.dumps(put,ensure_ascii=False,indent=2)+'\n');raise
put={'utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'failed':0,'check_count':len(checks),'detail':detail,'consumed_hashes':consumed,'acceptance_verdict':'NOT_ASSESSED','pending':'Final091 report/manifest handoff and independent whole matrix judgment','product_executed':False}
(O/'raw/verification.json').write_text(json.dumps(put,ensure_ascii=False,indent=2)+'\n')
print(json.dumps({'raw_verification_failed':0,'checks':len(checks),'cases':len(case_records),'package_members':184,'acceptance_verdict':'NOT_ASSESSED'},ensure_ascii=False))

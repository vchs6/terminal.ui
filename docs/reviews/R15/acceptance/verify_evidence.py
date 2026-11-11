from pathlib import Path
import json,hashlib,subprocess,tarfile,re,datetime,itertools
B=Path('/workspace/work/theme-execution');C=B/'artifacts';O=Path('/workspace/work/theme-acceptance');R=Path('/workspace/work/terminal.ui');P='8d75233c664fd61be08d441f74d464cbcdff2d9c'
checks=[];details={};(O/'raw').mkdir(exist_ok=True)
def ck(v,label):
 checks.append({'passed':bool(v),'assertion':label})
 if not v:raise AssertionError(label)
def safe(p):
 p=Path(p);ck('theme-implementation' not in p.parts and 'glyph-implementation' not in p.parts,'Allowed evidence path');return p
def data(p):return safe(p).read_bytes()
def h(p):return hashlib.sha256(data(p)).hexdigest()
def digest(b):return hashlib.sha256(b).hexdigest()
def load(p):
 def pairs(xs):
  d={}
  for k,v in xs:
   if k in d:raise ValueError('duplicate key '+k)
   d[k]=v
  return d
 return json.loads(data(p),object_pairs_hook=pairs,parse_constant=lambda x:(_ for _ in ()).throw(ValueError(x)))
def git(path,commit=P):return subprocess.check_output(['git','-C',str(R),'show',commit+':'+path])
try:
 m=load(C/'manifest.json');ck(m['source']==P,'Manifest fixed product')
 ck(data(B/'manifest.json')==data(C/'manifest.json'),'Manifest original matches copy')
 seen=set()
 for f in m['files']:
  name=f['path'];ck(name not in seen and not Path(name).is_absolute() and '..' not in Path(name).parts,'Manifest unique safe paths');seen.add(name)
  ck(data(B/name)==data(C/name) and h(C/name)==f['sha256'] and len(data(C/name))==f['bytes'],'Original/curated '+name)
 index={}
 for line in (C/'artifacts.sha256').read_text().splitlines():
  expected,name=line.split(None,1);name=name.strip();ck(name not in index,'Index unique');index[name]=expected;ck(h(C/name)==expected,'Index '+name)
 actual={str(p.relative_to(C)) for p in C.rglob('*') if p.is_file()};ck(actual==seen|{'manifest.json','artifacts.sha256'},'Exact archive membership')
 ck(set(index)==seen|{'manifest.json'},'Exact checksum coverage')
 strict=0
 for p in C.rglob('*.json'):load(p);strict+=1
 details['archive']={'original_copies':len(seen),'index_entries':len(index),'actual_files':len(actual),'strict_json':strict,'manifest_sha256':h(C/'manifest.json'),'index_sha256':h(C/'artifacts.sha256')}
 source=load(C/'raw/root-build/pre-source.json');ck(len(source)==338,'338 source/test inventory')
 for p,s in source.items():ck(h(B/'product'/p)==s==digest(git(p)),'Source Git bytes '+p)
 commands=[]
 for f in sorted((C/'raw').glob('*/command.json')):
  d=load(f);pre=f.parent/'pre-source.json';post=f.parent/'post-source.json'
  if pre.exists():ck(load(pre)==source==load(post),'Pre/post fixed '+f.parent.name)
  expected=1 if f.parent.name=='whole-bundle-check' else 0;ck(d['exit']==expected and d['head']==P,'Command exit/source '+f.parent.name)
  ck(d['utc']<=d['end_utc']<m['utc'],'Command ended before seal '+f.parent.name)
  commands.append({'name':f.parent.name,'exit':d['exit'],'utc':d['utc'],'argv':d['argv']})
 details['commands']=commands
 for name in ['foundation-values','foundation-integration']:
  lines=[json.loads(x) for x in data(C/'raw'/name/'detail/commands.jsonl').decode().splitlines()];ck(len(lines)==2 and all(x['exit']==0 for x in lines),'Actual build/direct '+name)
  ck('target/release/bin/main' in lines[-1]['command'][0],'Direct binary '+name)
  formal=set(subprocess.check_output(['git','-C',str(R),'ls-tree','-r','--name-only',P,'tests/themes']).decode().splitlines())
  recorded=load(C/'raw'/name/'detail/source-hashes.json');generated=[]
  for p,s in recorded.items():
   if 'tests/themes/'+p in formal:ck(digest(git('tests/themes/'+p))==s,'Formal source '+p)
   else:ck('build-script-cache' in Path(p).parts,'Runner extra is build cache metadata '+p);generated.append(p)
  ck(all(p.removeprefix('tests/themes/') in recorded for p in formal),'All formal test files recorded')
  details[name+'_extra_build_cache_records']=len(generated)
  result=data(C/'raw'/name/'detail'/('values-run.stdout' if name.endswith('values') else 'integration-run.stdout')).decode();ck('PASS TASK085' in result and 'CASE FAIL' not in result,'Full formal final stdout '+name)
 deps=load(C/'raw/dependency-source-hashes.json')
 for d in deps:ck(h(B/'cache'/d['path'])==d['sha256'],'Dependency '+d['path'])
 env=load(C/'raw/environment-artifact-hashes.json')
 for p,s in env.items():
  if h(p)==s:ck(True,'External environment '+p);continue
  ck(p==str(B/'product/cjpm.lock'),'Only external drift is known lock order')
  lines=data(p).decode().splitlines(keepends=True);ck(len(lines[3:])==5,'Five dependency entries')
  candidates=[''.join(lines[:3])+''.join(order) for order in itertools.permutations(lines[3:])]
  matches=[x for x in candidates if digest(x.encode())==s];ck(len(matches)==1,'Old lock hash differs only by dependency record order')
  ck(h(p)==load(C/'raw/fixed-source-status.json')['dependency_lock_sha256'],'Final-source lock record matches current')
  details['external_metadata_drift']={'path':p,'early_hash':s,'final_current_hash':h(p),'semantic_identity':'Unique SHA match among120 permutations of the same five exact version records','limitation':'Reconstructed order-equivalence proof; not an original historical lock snapshot or retroactive pre-run proof.'}
 details['dependency_files']=len(deps);details['environment_files']=len(env)
 pkg=B/'product/target/cjtui-0.0.0.cjp';ck(h(pkg)=='29ce7c64d16425c2a0f8350cb72d852a3e2a858fd423379bc0aad9fccd108fad','Actual CJP hash')
 records={x['member']:x for x in load(C/'raw/package/member-inventory.json')};clean=Path(data(C/'raw/package/library-path.txt').decode().strip());members=[]
 with tarfile.open(pkg,'r:gz') as t:
  for ent in t.getmembers():
   ck(ent.isdir() or ent.isfile(),'CJP regular/directory only')
   ck(not ent.name.startswith('/') and '..' not in Path(ent.name).parts,'CJP safe path')
   if not ent.isfile():continue
   blob=t.extractfile(ent).read();rec=records[ent.name];path=rec['git_path']
   ck(blob==git(path)==data(clean/path) and digest(blob)==rec['sha256'] and len(blob)==rec['bytes'],'CJP/git/clean bytes '+path);members.append(path)
 ck(len(members)==len(records)==175,'All175 actual CJP members')
 for preset in ['dark','light','high-contrast','classic']:
  ck(data(clean/'themes'/f'{preset}.toml')==git('openspec/changes/implement-theme-styles/fixtures/themes/'+preset+'.toml')==git('tests/themes/fixtures/'+preset+'.toml'),'Shipped canonical preset '+preset)
 for rec in load(C/'raw/package/clean-consumer-source-identity.json')['source_files']:
  p=rec['path'];original=git(p);got=data(B/'clean-consumer'/p)
  expected=original.replace(b'path = "../../.."',b'path = "../../../package/cjtui-0.0.0"') if p.endswith('cjpm.toml') else original
  ck(got==expected and digest(original)==rec['original_sha256'] and digest(got)==rec['copied_sha256'],'Clean exact formal consumer '+p)
 details['package']={'sha256':h(pkg),'members':len(members),'all_git_clean_bytes_equal':True,'absent_future':['examples/composition/cjpm.toml','benchmarks/rendering/cjpm.toml']}
 ck(all(p not in members for p in details['package']['absent_future']),'Future missing members honest')
 plain=re.sub(r'\x1b\[[0-9;]*m','',(data(C/'raw/final-bundle/stdout')+data(C/'raw/final-bundle/stderr')).decode())
 warnings=len(re.findall(r'\bwarning:',plain));ck(warnings==491,'491 actual lint warnings');details['lint_warnings']=warnings
 ck('Development/unexpected file in bundle: themes/light.toml' in data(C/'raw/whole-bundle-check/stderr').decode(),'Actual whole checker first failure')
 omitted=load(C/'raw/omitted-generated-artifacts.json')['files']
 for rec in omitted:ck(h(B/rec['path'])==rec['sha256'],'Omitted artifact '+rec['path'])
 details['omitted_artifacts_checked']=len(omitted)
 negative=load(C/'raw/reuse/negative-identity.json');ck(len(negative['negative_records'])==16,'16 reused negatives')
 negout=[]
 for n in negative['negative_records']:
  p=C/'raw/reuse/negative-raw'/(n['name']+'.stderr');s=re.sub(r'\x1b\[[0-9;]*m','',data(p).decode())
  ck(n['exit']==1 and h(p)==n['stderr_sha256'] and 'error:' in s,'Actual negative diagnostic '+n['name'])
  ck(not any(x in s for x in ['can not find the following dependencies','failed to update','command not found','expected a member name','unclosed delimiter']),'Not environmental negative '+n['name'])
  ck(git('tests/themes/negative/'+n['name']+'.cj.txt')==git('tests/themes/negative/'+n['name']+'.cj.txt','2b16ce9'),'Frozen negative source '+n['name'])
  negout.append({'name':n['name'],'diagnostic':next(x for x in s.splitlines() if 'error:' in x),'exit':1})
 details['negatives']=negout;details['negative_reuse_limit']=negative['temporal_limit']
 reg=load(C/'raw/reuse/round1-pre-source-inventory.json');differences=[]
 for path,s in reg['files'].items():
  ck(digest(git(path,'95c1186a8ec5b184d5d2f15af0cac2e81499ce68'))==s,'Regression pre-source95 '+path)
  if digest(git(path))!=s:differences.append(path)
 ck(len(reg['files'])==201 and differences==['src/theme/theme_decoder.cj'],'Only deleted helper differs from201 pre-source')
 regression_commands=[json.loads(x) for x in data(C/'raw/reuse/regression-commands.jsonl').decode().splitlines()]
 for d in regression_commands:
  ck(d['exit']==0 and reg['utc']<d['utc'],'Regression after pre-source '+d['name'])
  ck(len(data(C/'raw/reuse'/('regression-'+d['name']+'.stdout')))>0,'Regression actual stdout '+d['name'])
 details['regressions']={'pre_source_entries':201,'current_differences':differences,'commands':regression_commands}
 # Author path strings in retained metadata are not dereferenced.
 details['product_executed']=False
except Exception:
 result={'utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'checks':checks,'details':details,'failed':1};(O/'raw/integrity.json').write_text(json.dumps(result,ensure_ascii=False,indent=2)+'\n');raise
result={'utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'checks':checks,'details':details,'failed':0};(O/'raw/integrity.json').write_text(json.dumps(result,ensure_ascii=False,indent=2)+'\n')
print(json.dumps({'failed':0,'checks':len(checks),'archive':details['archive'],'commands':len(commands),'package_members':len(members),'lint_warnings':warnings,'omitted':len(omitted)},ensure_ascii=False))

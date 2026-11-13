from pathlib import Path
import hashlib,json,subprocess,tomllib,datetime
b=Path(__file__).resolve().parent.parent;r=b/'replay';s=b/'source';raw=b/'raw'
h=lambda data:hashlib.sha256(data).hexdigest();git=lambda cwd,*args:subprocess.check_output(['git',*args],cwd=cwd)
j=json.loads((raw/'prehash.json').read_text());post={'utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'inputs_sha256':{},'external_dependencies_sdk_sha256':{}}
assert git(r,'rev-parse','HEAD').decode().strip()==j['fixed_product']
assert git(s,'rev-parse','HEAD').decode().strip()==j['test_base']
for p,w in j['inputs_sha256'].items():
 post['inputs_sha256'][p]=h((r/p).read_bytes())
 if p!='tests/interaction_c/cjpm.lock':assert post['inputs_sha256'][p]==w,p
assert tomllib.loads((raw/'prebuild-cjpm.lock').read_text())==tomllib.loads((r/'tests/interaction_c/cjpm.lock').read_text())
for p,w in j['external_dependencies_sdk_sha256'].items():
 post['external_dependencies_sdk_sha256'][p]=h(Path(p).read_bytes());assert post['external_dependencies_sdk_sha256'][p]==w,p
tracked=set(git(r,'ls-tree','-r','--name-only',j['fixed_product']).decode().splitlines());product=[p for p in j['inputs_sha256'] if not p.startswith('tests/') and p in tracked]
for p in product:assert h(git(r,'show',j['fixed_product']+':'+p))==j['inputs_sha256'][p],p
new='tests/interaction_c/src/round2_review_regressions.cj';tests=git(s,'ls-files','tests/interaction_c').decode().splitlines()+[new]
for p in tests:assert (s/p).read_bytes()==(r/p).read_bytes(),p
old_paths=git(s,'ls-tree','-r','--name-only',j['test_base'],'tests/interaction_c').decode().splitlines();docs={'tests/interaction_c/README.md','tests/interaction_c/case-matrix.md','tests/interaction_c/golden.md'};main='tests/interaction_c/src/main.cj'
for p in old_paths:
 baseline=git(s,'show',j['test_base']+':'+p);current=(s/p).read_bytes()
 if p in docs:assert current.startswith(baseline),p
 elif p==main:
  text=current.decode().replace('    if(let Some(name)<-getVariable("CJTUI_OVERLAY_REVIEW_R2")){return round2ReviewRegression(name)}\n','',1).replace('    round2ModalOwnerRestoration();round2ExplicitRootBounds()\n','',1);assert text.encode()==baseline
 else:assert current==baseline,p
binary=r/'tests/interaction_c/target/release/bin/main';current=h(binary.read_bytes());binary_ids={}
for name in ['R1-I01','R1-I02']:
 before=json.loads((raw/(name+'.bin-pre.json')).read_text());after=json.loads((raw/(name+'.bin-post.json')).read_text());assert before['sha256']==after['sha256']==current;binary_ids[name]={'pre':before,'post':after}
 assert int((raw/(name+'.exit')).read_text())==1
 assert 'Exception: FAIL '+name in (raw/(name+'.stderr')).read_text()
post['binary_pre_post']=binary_ids;post['binary_sha256']=current;(raw/'posthash.json').write_text(json.dumps(post,indent=2)+'\n')
subprocess.run(['git','diff','--check'],cwd=s,check=True)
print(f'PASS pre/post repository {len(j["inputs_sha256"])} inputs; exact dependency/SDK {len(j["external_dependencies_sdk_sha256"])} files; parsed lock unchanged')
print(f'PASS fixed product {len(product)} tracked inputs; source/replay {len(tests)} tests identical; all old tests/selector bodies/oracles unchanged')
print('PASS one normal build; two independent expected assertion RED actual1; real binary captured immediately before and after each run')
print('BINARY_SHA256 '+current)

from pathlib import Path
import subprocess,json,hashlib,datetime,re
r=Path(__file__).resolve().parent;repo=Path('/workspace/work/terminal.ui');raw=Path('/workspace/work/theme-implementation/fix-round1-raw')
base='97df09638e2912cbee3313c23c4254e0a1708a5e';head='95c1186a8ec5b184d5d2f15af0cac2e81499ce68'
def git(*args):return subprocess.check_output(['git','-C',str(repo),*args])
def digest(b):return hashlib.sha256(b).hexdigest()
def blob(ref,p):return git('show',ref+':'+p)
pre=json.loads((raw/'pre-source-tests.json').read_text());checks=[]
for p,expected in pre['files'].items():
 actual=digest(blob(head,p));checks.append(dict(path=p,expected=expected,actual=actual,equal=actual==expected))
assert len(checks)==201 and all(x['equal'] for x in checks)
changes=git('diff','--name-only',base,head).decode().splitlines()
changed=[dict(path=p,sha256=digest(blob(head,p)),blob=git('rev-parse',head+':'+p).decode().strip()) for p in changes]
tests=git('diff-tree','--no-commit-id','--name-only','-r','61e531').decode().splitlines()
overlay=[dict(path=p,equal=blob('61e531',p)==blob('a4d339c',p)==blob(head,p)) for p in tests];assert all(x['equal'] for x in overlay)
# Compare all ordinary bundle member records to fixed git source, classifying generated manifest.
m=json.loads((raw/'bundle/member-hashes.json').read_text());members=[]
for p,expected in m['files'].items():
 try:
  actual=digest(blob(head,p));members.append(dict(path=p,recorded=expected,git_sha256=actual,equal=actual==expected))
 except subprocess.CalledProcessError:
  members.append(dict(path=p,recorded=expected,equal=None,reason='not a source git member'))
commands=[];inventory=[]
for group in ['focused','values','integration','bundle']:
 for line in (raw/group/'commands.jsonl').read_text().splitlines():
  x=json.loads(line);x['group']=group;commands.append(x)
 for p in sorted((raw/group).glob('*')):
  if p.is_file():inventory.append(dict(path=str(p),sha256=digest(p.read_bytes()),bytes=p.stat().st_size))
for name in ['pre-source-tests.json','pre-environment.json','post-commit-identity.json']:
 p=raw/name;inventory.append(dict(path=str(p),sha256=digest(p.read_bytes()),bytes=p.stat().st_size))
assert all(x['exit']==0 for x in commands)
assert all(x['utc']>pre['utc'] for x in commands)
# Test raw identities and assertion outcomes, without re-running anything.
focused=json.loads((raw/'focused/source-hashes.json').read_text())
focusmatch=[]
for p,expected in focused.items():
 actual=digest(blob(head,'tests/themes/'+p));focusmatch.append(dict(path=p,equal=actual==expected));assert actual==expected
outcomes={name:(raw/'focused'/name).read_text() for name in ['values-priority.stdout','values-variable-order.stdout','integration-binding.stdout']}
assert '0 failed' in outcomes['values-priority.stdout'] and '0 failed' in outcomes['values-variable-order.stdout']
assert 'CASE PASS rejected padding overload false' in outcomes['integration-binding.stdout'] and 'CASE PASS rejected padding overload true' in outcomes['integration-binding.stdout']
env=json.loads((raw/'pre-environment.json').read_text());envcheck=[]
for p,expected in env.items():
 # Only environment files; never read author implementation or reports.
 actual=digest(Path(p).read_bytes());envcheck.append(dict(path=p,expected=expected,actual=actual,equal=actual==expected))
assert all(x['equal'] for x in envcheck)
contract=repo/'openspec/changes/implement-theme-styles/design.md';assert digest(contract.read_bytes())=='084b1623937055426e0e7c57c2cc5b9cfa2e474a787ce7e81fee3cea286c30a4'
result=dict(checked_utc=datetime.datetime.now(datetime.timezone.utc).isoformat(),base=base,head=head,contract_sha256=digest(contract.read_bytes()),diff_package_sha256=digest((repo/'.superpowers/sdd/tasks-implement-theme-styles/review-97df096..95c1186.diff').read_bytes()),changed_files=changed,pre_source_utc=pre['utc'],pre_source_checks=checks,test_overlay_checks=overlay,commands=commands,raw_inventory=inventory,focused_test_hash_checks=focusmatch,environment_checks=envcheck,bundle_members=members,bundle_manifest_metadata={k:v for k,v in m.items() if k!='files'},reviewer_runtime_reruns=0)
(r/'reviewed-hashes.json').write_text(json.dumps(result,ensure_ascii=False,indent=2)+'\n')
print(json.dumps(dict(changed=len(changed),prechecked=len(checks),commands=len(commands),all_exit0=True,test_overlay_files=len(overlay),focused_sources=len(focusmatch),members=len(members),matched=sum(x['equal'] is True for x in members),member_exceptions=[x for x in members if x['equal'] is not True],env_checked=len(envcheck)),indent=2))

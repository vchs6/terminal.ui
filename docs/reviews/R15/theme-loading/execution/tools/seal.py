from pathlib import Path
import hashlib,json,subprocess,shutil,datetime
B=Path('/workspace/work/theme-load-execution');R=B/'product';O=B/'raw';h=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
checks=[]
for p in sorted(O.glob('*/command.json')):
 d=json.loads(p.read_text());pre=json.loads((p.parent/'pre-source.json').read_text());post=json.loads((p.parent/'post-source.json').read_text());assert pre==post,p
 assert d['head']=='fa6a46ec339ea0f098dea521c814226a7a373c7e';assert d['exit']==(1 if p.parent.name=='device-build' else 0),(p,d['exit'])
 checks.append({'group':p.parent.name,'exit':d['exit'],'pre_post_source_equal':True,'source_entries':len(pre),'utc':d['utc']})
assert subprocess.check_output(['git','status','--short'],cwd=R,text=True)==''
assert len(json.loads((O/'package/member-inventory.json').read_text()))==184
assert json.loads((O/'identity/case-summary.json').read_text())['case_count']==22
assert (B/'device-observation/native/session_fault.c').read_bytes()==(R/'tests/session_extensions/native/session_fault.c').read_bytes()
(O/'identity/execution-record-check.json').write_text(json.dumps(checks,indent=2)+'\n')
(O/'identity/device-fixture-equality.json').write_text(json.dumps({'original':'tests/session_extensions/native/session_fault.c','source_commit':'fa6a46ec339ea0f098dea521c814226a7a373c7e','copied_bytes_equal':True,'sha256':h(B/'device-observation/native/session_fault.c')},indent=2)+'\n')
omitted=[]
for root in [R,B/'clean-consumer',B/'device-observation']:
 for p in root.rglob('*'):
  if not p.is_file() or p.is_symlink() or '.git' in p.parts:continue
  if any(x in p.parts for x in ['target','build-script-cache','.cjtui-build']) or p.suffix in ['.a','.o','.so','.cjo','.bc','.cjp']:
   omitted.append({'path':str(p.relative_to(B)),'bytes':p.stat().st_size,'sha256':h(p),'reason':'own generated build/native artifact; not part of curated pure raw/source evidence'})
for p in O.rglob('*.so'):omitted.append({'path':str(p.relative_to(B)),'bytes':p.stat().st_size,'sha256':h(p),'reason':'formal test-only real-file gate interposer; source fixedgit/hash; binary omitted'})
(O/'omitted-generated-artifacts.json').write_text(json.dumps({'files':omitted,'other_omissions':['whole fixed checkout replaced by git/source hash identity','SDK/compiler/runtime files replaced by hashes','normal cache375 source and officialstdx inventory reused by exact hash reference','per-case work input trees replaced by fixed generator identity and initial-input hashes; no fixture snapshots duplicated']},indent=2)+'\n')
A=B/'artifacts';assert not A.exists();A.mkdir()
for name in ['report.md','findings.json','scope.json']:shutil.copyfile(B/name,A/name)
for p in O.rglob('*'):
 if not p.is_file():continue
 rel=p.relative_to(O)
 if any(s.startswith('work-') for s in rel.parts) or p.suffix in ['.so','.a','.o','.cjo','.cjp','.bc']:continue
 q=A/'raw'/rel;q.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(p,q)
for root in ['device-observation','tools']:
 for p in (B/root).rglob('*'):
  if not p.is_file() or any(x in p.parts for x in ['target','build-script-cache','__pycache__']):continue
  if p.name=='cangjie-repo.toml' or p.suffix not in ['.cj','.c','.py','.toml']:continue
  q=A/root/p.relative_to(B/root);q.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(p,q)
q=A/'preparation/input-hashes.json';q.parent.mkdir(exist_ok=True);shutil.copyfile(B/'preparation/input-hashes.json',q)
files=[{'path':str(p.relative_to(A)),'bytes':p.stat().st_size,'sha256':h(p)} for p in sorted(A.rglob('*')) if p.is_file()]
m={'source':'fa6a46ec339ea0f098dea521c814226a7a373c7e','utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'result':'PASSED_REQUIRED_EXECUTION_SCOPE','no092_or_release_acceptance_claim':True,'curation':'complete read-only minimal pure evidence; generated inputs/binaries/whole checkouts excluded','files':files}
for p in [B/'manifest.json',A/'manifest.json']:p.write_text(json.dumps(m,indent=2)+'\n')
lines=''.join(h(p)+'  '+str(p.relative_to(A))+'\n' for p in sorted(A.rglob('*')) if p.is_file())
for p in [B/'artifacts.sha256',A/'artifacts.sha256']:p.write_text(lines)
for p in A.rglob('*'):p.chmod(0o555 if p.is_dir() else 0o444)
A.chmod(0o555)
print('Verified',len(checks),'recorded groups; sealed',len(files),'content files;',len(omitted),'omitted generated hashes')

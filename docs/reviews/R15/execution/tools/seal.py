from pathlib import Path
import hashlib,json,shutil,subprocess,os,stat,datetime
B=Path('/workspace/work/theme-execution');R=B/'product';O=B/'raw';h=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
# Fresh verification of actual recorded exits and unchanged source before sealing.
commands=[]
for p in sorted(O.glob('*/command.json')):
 d=json.loads(p.read_text());pre=json.loads((p.parent/'pre-source.json').read_text());post=json.loads((p.parent/'post-source.json').read_text());assert pre==post,p
 assert d['exit']==(1 if p.parent.name=='whole-bundle-check' else 0),(p,d['exit'])
 commands.append({'group':p.parent.name,'source_count':len(pre),'pre_post_equal':True,'exit':d['exit'],'utc':d['utc']})
assert subprocess.check_output(['git','status','--short'],cwd=R,text=True)==''
assert json.loads((O/'package/package.json').read_text())['members']==175
assert len(json.loads((O/'gui-oracles.json').read_text()))==12
(O/'executed-source-identity-check.json').write_text(json.dumps(commands,indent=2)+'\n')
omitted=[]
for root in [R,B/'clean-consumer',B/'observation',B/'observation-glyph',B/'tools']:
 for p in root.rglob('*'):
  if not p.is_file() or p.is_symlink() or '.git' in p.parts or 'node_modules' in p.parts:continue
  is_generated=any(x in p.parts for x in ['target','build-script-cache','.cjtui-build']) or p.suffix in ['.o','.a','.so','.cjo','.bc','.cjp']
  if is_generated:omitted.append({'path':str(p.relative_to(B)),'bytes':p.stat().st_size,'sha256':h(p),'reason':'generated build/native artifact retained locally; omitted from curated source-and-raw evidence'})
(O/'omitted-generated-artifacts.json').write_text(json.dumps({'files':omitted,'external_omissions':{'SDK':'shared SDK setup/compiler/cjpm hashes in environment-artifact-hashes.json; SDK not redistributed','stdx':'every official installed file hash in stdx-hashes.json; readonly official install not redistributed','cache':'375 upstream source hashes in dependency-source-hashes.json; normal registry cache not redistributed','whole_checkouts':'fixed source8d git identity plus338 source/test/native hashes and175 member inventory; no checkout snapshots'}},indent=2)+'\n')
# Recompute current environment/harness/binary identifiers without copying artifacts.
extra={}
for root in [B/'tools',B/'observation',B/'observation-glyph']:
 for p in root.rglob('*'):
  if p.is_file() and not any(x in p.parts for x in ['target','build-script-cache','__pycache__']):extra[str(p.relative_to(B))]=h(p)
(O/'observation-harness-hashes.json').write_text(json.dumps(extra,indent=2)+'\n')
A=B/'artifacts';assert not A.exists();A.mkdir()
for name in ['report.md','findings.json','scope.json','preparation.md']:shutil.copyfile(B/name,A/name)
# Keep small own harness sources, not copied product/formal sources.
for p in (B/'tools').glob('*'):
 if p.is_file() and p.suffix in ['.py','.c']:
  q=A/'tools'/p.name;q.parent.mkdir(exist_ok=True);shutil.copyfile(p,q)
for name in ['observation','observation-glyph']:
 for rel in ['cjpm.toml','src/main.cj']:
  q=A/name/rel;q.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(B/name/rel,q)
for p in O.rglob('*'):
 if not p.is_file():continue
 rel=p.relative_to(O)
 if 'home' in rel.parts and p.name!='terminalrc':continue
 assert p.suffix not in ['.a','.o','.so','.cjo','.bc','.cjp','.pngx']
 q=A/'raw'/rel;q.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(p,q)
files=[{'path':str(p.relative_to(A)),'bytes':p.stat().st_size,'sha256':h(p)} for p in sorted(A.rglob('*')) if p.is_file()]
m={'task':'TASK087','utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'source':'8d75233c664fd61be08d441f74d464cbcdff2d9c','status':'EXECUTION_COMPLETE_WITH_OPEN_FINAL_RELEASE_GAP','files':files,'no_full_release_or088_claim':True}
for p in [B/'manifest.json',A/'manifest.json']:p.write_text(json.dumps(m,indent=2)+'\n')
checks=''.join(h(p)+'  '+str(p.relative_to(A))+'\n' for p in sorted(A.rglob('*')) if p.is_file())
(A/'artifacts.sha256').write_text(checks);(B/'artifacts.sha256').write_text(checks)
for p in A.rglob('*'):p.chmod(0o555 if p.is_dir() else 0o444)
A.chmod(0o555)
print('Verified',len(commands),'recorded groups; sealed',len(files),'files and',len(omitted),'omitted generated artifact hashes')

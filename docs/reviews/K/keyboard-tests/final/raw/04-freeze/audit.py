from pathlib import Path
import hashlib,json,subprocess,datetime,re
b=Path(__file__).resolve().parent.parent.parent;r=b/'replay';s=b/'source';raw=b/'raw';h=lambda p:hashlib.sha256(p.read_bytes()).hexdigest();git=lambda *a:subprocess.check_output(['git',*a],cwd=s)
phase_hashes={'01-native-read':'d32d4cbc07a16705ae9f1af0c63f967756e5f92d251233b2eeea791b42d6ed6f','02-upstream':'e0471493e429ee89c95ba22183d1827644ce69328dad69df20bf8f670a66e4ff','03-missing-keyboard':'c91cd4eae2d8b5a6c565df3ac79a3d7e8c3901af68303e06cbb2e68a62eecf12'}
for phase,want in phase_hashes.items():
 p=raw/phase;assert h(p/'manifest.json')==want,phase;m=json.loads((p/'manifest.json').read_text())
 for name,w in m['files_sha256'].items():assert h(p/name)==w,(phase,name)
pre=json.loads((raw/'02-upstream/prehash.json').read_text())
for name,w in pre['external_dependencies_sdk_sha256'].items():assert h(Path(name))==w,name
product={}
for name,w in pre['inputs_sha256'].items():
 if name.startswith(('src/','native/','scripts/')) or name in ['build.cj','cjpm.toml']:
  assert h(r/name)==w,name;assert hashlib.sha256(git('show','HEAD:'+name)).hexdigest()==w,name;product[name]=w
kb=json.loads((raw/'03-missing-keyboard/prehash.json').read_text())
for name,w in kb['inputs_sha256'].items():assert h(r/name)==w,name
files=git('ls-files','--cached','--others','--exclude-standard','tests/keyboard').decode().splitlines();files=sorted(set(files));test_hashes={}
for name in files:assert (s/name).read_bytes()==(r/name).read_bytes(),name;test_hashes[name]=h(s/name)
old=git('ls-tree','-r','--name-only','HEAD','tests/keyboard').decode().splitlines()
for name in old:
 current=(s/name).read_bytes();baseline=git('show','HEAD:'+name)
 if name=='tests/keyboard/README.md':assert current.endswith(baseline)
 elif name=='tests/keyboard/src/main.cj':assert current.replace(b'    protocolReportCases()\n',b'')==baseline
 elif name=='tests/keyboard/run.sh':assert b'upstream' in current and b'formal_dispatch' in current and b'exec bash native/run.sh' in current
 else:assert current==baseline,name
assert int((raw/'02-upstream/run.exit').read_text())==0 and int((raw/'03-missing-keyboard/build.exit').read_text())==1
binary=r/'tests/keyboard/upstream/target/release/bin/main';assert h(binary)==json.loads((raw/'02-upstream/binary-pre.json').read_text())['sha256']==json.loads((raw/'02-upstream/binary-post.json').read_text())['sha256']
assert not (r/'tests/keyboard/target/release/bin/main').exists()
assert int((raw/'04-freeze/static.exit').read_text())==0 and not (raw/'04-freeze/static.stderr').read_bytes()
protected=Path('/workspace/work/terminal.ui/docs/reviews/interaction/C/overlay-acceptance/acceptance.md');assert h(protected)=='702cd9f253fbc005821920875eccc865f7cf1dfad4847c87ed13a27ef0d8c123'
preflight=json.loads(Path('/workspace/work/input-preflight-resume/findings.json').read_text());assert len(preflight)==4 and all(x['status']=='verified' and x['verification']['result']=='pass' for x in preflight)
post={'utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'phase_manifest_sha256':phase_hashes,'test_files_sha256':test_hashes,'fixed_product_inputs_sha256':product,'external_dependencies_sdk_pre_post_sha256':pre['external_dependencies_sdk_sha256'],'upstream_binary_sha256':h(binary),'model':'requested Sol/high; actual serving metadata unavailable','skills':{'cangjie-coding':'/workspace/work/CangjieSkills/.agents/skills/cangjie-coding/SKILL.md @277f2e1234ca5217496966887243c679653887a8; batch search_docs actual signatures, SDK1.2 prevails','process':['using-superpowers(subagent stop)','cloud-environment-runtime','writing-plans(existing TASK113 card/brief; root ACTUALGO overrides extra confirmation)','test-driven-development(missing API RED; no product implementation)','systematic-debugging(native observed failure classification)','verification-before-completion']},'admission_receipts_sha256':{str(p):h(p) for p in [protected,Path('/workspace/work/input-preflight-resume/findings.json'),Path('/workspace/work/input-preflight-resume/reviewed-hashes.json'),Path('/workspace/work/terminal.ui/.superpowers/sdd/tasks-implement-linux-input-editing/task-113-final-brief.md'),Path('/workspace/work/terminal.ui/docs/reviews/R17/i015-preflight/f007-findings.json')]}}
(raw/'04-freeze/posthash.json').write_text(json.dumps(post,indent=2)+'\n')
print('PASS immutable phases01/02/03 hashes preserved; all original raw hashes verified')
print('PASS accepted current-source baseline actual0; public missing Keyboard API compile actual1 and no stale executable')
print(f'PASS {len(test_hashes)} formal test files source/replay identical; original23 history retained, pure goldens unchanged except added F006 call; entry adds qualified checks')
print(f'PASS {len(product)} fixed product inputs and {len(pre["external_dependencies_sdk_sha256"])} dependency/SDK files unchanged; upstream bin pre/post identical')
print('PASS actual PF001-004 independently closed; C112 receipt hash matches; new K native behavior/body typecheck remain explicitly UNEXECUTED')

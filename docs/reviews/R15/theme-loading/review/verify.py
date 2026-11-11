import subprocess,hashlib,json,pathlib,datetime
repo='/workspace/work/terminal.ui'; rev='797039d6da9df8d849d382aff52eeb2180ba31b8'; base='73abef3'
out=pathlib.Path('/workspace/work/theme-load-review'); raw=pathlib.Path('/workspace/work/theme-implementation/task026-final-raw')
def git(*args):return subprocess.check_output(['git','-C',repo,*args])
def digest(data):return hashlib.sha256(data).hexdigest()
def blob(path):return git('show',rev+':'+path)
pre=json.loads((raw/'pre-identity.json').read_text());post=json.loads((raw/'post-identity.json').read_text())
inputs=[]
for record in pre['tracked']:
 actual=digest(blob(record['path']));inputs.append(dict(path=record['path'],recorded_sha256=record['sha256'],git_sha256=actual,match=actual==record['sha256']))
assert all(r['match'] for r in inputs)
commands=[json.loads(line) for line in (raw/'full/commands.jsonl').read_text().splitlines()]
assert all(r['exit']==0 and r['sha']==rev and r['utc']>pre['utc'] for r in commands)
cases=[r for r in commands if 'controller_error' in r]
assert len(cases)==22
for c in cases:
 assert c['controller_error'] is None
 assert 'PASS CASE '+c['name'] in (raw/'full'/c['stdout']).read_text()
test_records=json.loads((raw/'full/source-hashes.json').read_text());test_checks=[]; untracked=[]
tracked=set(git('ls-tree','-r','--name-only',rev,'tests/theme-loading').decode().splitlines())
for path,h in test_records.items():
 if 'tests/theme-loading/'+path not in tracked:
  untracked.append(dict(path=path,recorded_sha256=h));continue
 actual=digest(blob('tests/theme-loading/'+path));test_checks.append(dict(path=path,recorded_sha256=h,git_sha256=actual,match=h==actual))
assert all(r['match'] for r in test_checks)
changed=git('diff','--name-only',base,rev).decode().splitlines()
checks={p:digest(blob(p)) for p in changed}
contract=digest(blob('openspec/changes/implement-theme-styles/design.md'))
assert contract=='084b1623937055426e0e7c57c2cc5b9cfa2e474a787ce7e81fee3cea286c30a4'
tree=git('rev-parse',rev+':tests/theme-loading').decode().strip();assert tree=='441cfd4da54c26fdad394df94bb633476d2a61e1'
package=pathlib.Path('/workspace/work/terminal.ui/.superpowers/sdd/tasks-implement-theme-styles/review-73abef3..797039d.diff')
raw_files=['pre-identity.json','post-identity.json','full/commands.jsonl','full/source-hashes.json','full.stdout','full.exit','bundle.stdout','bundle.stderr','bundle.exit','bundle.utc','bundle.sha256','bundle-identity.json']
raw_files += ['full/'+c[k] for c in commands for k in ['stdout','stderr']]
for c in cases:raw_files+=['full/'+c['name']+'.events.json','full/'+c['name']+'.initial-inputs.json']
evidence={'utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'base':git('rev-parse',base).decode().strip(),'head':rev,'commits':git('rev-list','--reverse',base+'..'+rev).decode().splitlines(),'diff_git_sha256':digest(git('diff',base,rev)),'supplied_package_sha256':digest(package.read_bytes()),'supplied_package_bytes':package.stat().st_size,'contract_sha256':contract,'tests_tree':tree,'changed_paths_sha256':checks,'pre_utc':pre['utc'],'post_record':post,'pre_source_checks':inputs,'test_source_checks':test_checks,'untracked_test_hash_records':untracked,'commands':commands,'all_22_case_sentinels_checked':True,'recorded_environment':pre['environment'],'environment_content_independently_rechecked':False,'raw_hashes':{p:digest((raw/p).read_bytes()) for p in sorted(set(raw_files))},'bundle_exit':int((raw/'bundle.exit').read_text()),'bundle_identity_record':json.loads((raw/'bundle-identity.json').read_text()),'bundle_unpacked_by_reviewer':False}
(out/'reviewed-hashes.json').write_text(json.dumps(evidence,indent=2)+'\n')
print(json.dumps({'changed':len(changed),'pre_sources':len(inputs),'test_sources':len(test_checks),'commands':len(commands),'cases':len(cases),'source_all_match':True,'contract':contract,'bundle_exit':evidence['bundle_exit']},indent=2))

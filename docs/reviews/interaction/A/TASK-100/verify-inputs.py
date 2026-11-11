import subprocess,hashlib,json,pathlib,datetime
repo='/workspace/work/terminal.ui';head='f02d8124dfad6028da1427c3da877eeec05a5708';base='3755f5793096b2f76602f5f73433fbb3a4973b65';own=pathlib.Path('/workspace/work/interaction-review');raw=pathlib.Path('/workspace/work/interaction-implementation/raw')
def git(*a):return subprocess.check_output(['git','-C',repo,*a])
def sha(b):return hashlib.sha256(b).hexdigest()
def disk(p):return sha(pathlib.Path(p).read_bytes())
def record(p):return {'path':str(p),'sha256':disk(p)}
changed=git('diff','--name-only',base,head).decode().splitlines()
tracked=[]
for path in git('ls-tree','-r','--name-only',head,'src','native','build.cj','cjpm.toml','themes').decode().splitlines():
 p=own/'source'/path
 tracked.append({'path':path,'git_sha256':sha(git('show',head+':'+path)),'probe_source_sha256':disk(p)})
pre=json.loads((raw/'final-lintfix/pre-identity.json').read_text());mismatches=[]
for e in pre['tracked']:
 actual=sha(git('show',head+':'+e['path']))
 if actual!=e['sha256']:mismatches.append({'path':e['path'],'git_sha256':actual,'pre_sha256':e['sha256']})
manifest=json.loads((raw/'manifest.json').read_text());commands=[]
for e in manifest['final_commands']:
 x=dict(e);x['raw']=[record(e['stdout']),record(e['stderr'])];stem=pathlib.Path(e['stdout']).with_suffix('');exitpath=str(stem)+'.exit';utcpath=str(stem)+'.utc';x['actual_exit_file']=pathlib.Path(exitpath).read_text().strip();x['actual_utc_file']=pathlib.Path(utcpath).read_text().strip();x['raw'] += [record(exitpath),record(utcpath)];commands.append(x)
contracts=git('ls-tree','-r','--name-only',base,'openspec/changes/implement-public-interaction').decode().splitlines();contracts=[p for p in contracts if p.endswith('.md')]
tests=git('ls-tree','-r','--name-only',head,'tests/interaction_a').decode().splitlines();test_mismatch=[]
for p in tests:
 ref='f07635e75f2b68d7bd78f41e777e9d2d481d0bef' if p.endswith('/readonly_queries.cj') else '76b8dd1c118b0f3c58327b66581d67884cec2713'
 if git('show',head+':'+p)!=git('show',ref+':'+p):test_mismatch.append(p)
r={'utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'base':base,'head':head,'source_changed':[{'path':p,'sha256':sha(git('show',head+':'+p))} for p in changed],'contracts':[{'path':p,'sha256':sha(git('show',base+':'+p))} for p in contracts],'fixed_tests':{'base':'76b8dd1c118b0f3c58327b66581d67884cec2713','readonly_overlay':'f07635e75f2b68d7bd78f41e777e9d2d481d0bef','head_tree':git('rev-parse',head+':tests/interaction_a').decode().strip(),'files':len(tests),'mismatches':test_mismatch},'probe_source':{'files':len(tracked),'mismatches':[e for e in tracked if e['git_sha256']!=e['probe_source_sha256']],'file_hashes':tracked,'identity_timing':'Post-run verification against immutable Git archive; no claim of an independently captured pre-run digest.'},'author_final_pre':{'identity':record(raw/'final-lintfix/pre-identity.json'),'utc':pre['utc'],'head':pre['head'],'tracked_count':len(pre['tracked']),'configs_count':len(pre['configs']),'git_mismatches':mismatches},'author_raw':[record(raw/'manifest.json'),record(raw/'final-lintfix/post-identity.json'),record(raw/'final-lintfix/bundle-identity.json')],'author_final_commands':commands,'diff_packages':[record(pathlib.Path(repo)/'.superpowers/sdd/tasks-implement-public-interaction'/n) for n in ['review-3755f57..55c723b.diff','review-lint-55c723b..f02d812.diff']]}
(own/'reviewed-hashes.json').write_text(json.dumps(r,indent=2)+'\n');print(json.dumps({'changed':len(changed),'source_files':len(tracked),'source_mismatches':r['probe_source']['mismatches'],'test_mismatches':test_mismatch,'author_pre_git_mismatches':mismatches,'final_exit_files':[(e['name'],e['actual_exit_file']) for e in commands]},indent=2))

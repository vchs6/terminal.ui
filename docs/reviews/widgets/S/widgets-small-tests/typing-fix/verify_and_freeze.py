import hashlib,json,pathlib,subprocess,sys
base=pathlib.Path('/workspace/work/widgets-small-tests/typing-fix');root=base/'source';ev=base/'evidence';records=[]
sha=lambda p:hashlib.sha256(pathlib.Path(p).read_bytes()).hexdigest()
def entry(p):
 p=pathlib.Path(p);return {'path':str(p),'sha256':sha(p),'bytes':p.stat().st_size}
def run(name,args):
 p=subprocess.run(args,cwd=root,stdout=subprocess.PIPE,stderr=subprocess.PIPE)
 streams={}
 for label,data in [('stdout',p.stdout),('stderr',p.stderr)]:
  f=ev/'raw'/(name+'.'+label);f.write_bytes(data);streams[label]=entry(f)
 records.append({'name':name,'cwd':str(root),'argv':args,'exit':p.returncode,'raw':streams})
 if p.returncode:raise RuntimeError(str(records[-1]))
 return p.stdout
relative='tests/widgets_small/src/event_boundaries.cj';target=root/relative
baseline='5413dc768a93b3e3f172227161bc9d8545993508'
before=run('baseline-source',['git','show',baseline+':'+relative])
assert target.read_bytes()==before
old=b'Array<?UIKeyEvent>(1, repeat: None)';new=b'Array<?UIKeyEvent>(1, repeat: Option<UIKeyEvent>.None)'
assert before.count(old)==2
(ev/'before.cj').write_bytes(before)
after=before.replace(old,new)
assert after.replace(new,old)==before
assert [(i,a,b) for i,(a,b) in enumerate(zip(before.splitlines(),after.splitlines()),1) if a!=b]==[(8,b'    let eventBox = '+old,b'    let eventBox = '+new),(98,b'    let seen = '+old,b'    let seen = '+new)]
target.write_bytes(after);(ev/'after.cj').write_bytes(after)
run('parser',['bash','-c','source /workspace/work/validation/sdk/cangjie/envsetup.sh && cjfmt -f tests/widgets_small/src/event_boundaries.cj -o /workspace/work/widgets-small-tests/typing-fix/evidence/formatted.cj'])
run('diff-check',['git','diff','--check'])
diff=run('exact-diff',['git','diff','--',relative]);assert diff.count(b'\n-    let ')==2 and diff.count(b'\n+    let ')==2
assert run('changed-files',['git','diff','--name-only']).decode().splitlines()==[relative]
# The old immutable 296 bindings and report/index must remain unchanged.
previous=pathlib.Path('/workspace/work/widgets-small-tests/final/evidence/index.json');old_index=entry(previous);data=json.loads(previous.read_text())
checks=list(data['product_files'].values())+list(data['test_files'].values())+list(data['inputs'].values())+data['sdk']['files']+data['registry_configs']+[data['resolved_dependencies'],data['prerequisite_binary'],data['report']]+data['artifacts']
for item in checks:assert sha(item['path'])==item['sha256'],item['path']
(ev/'old-bindings-check.json').write_text(json.dumps({'count':len(checks),'result':'all hashes unchanged','old_index':old_index},indent=2)+'\n')
log=pathlib.Path('/workspace/work/widgets-small-implementation/evidence/runner.log')
(ev/'raw/compiler-fixture-error.log').write_bytes(log.read_bytes())
assert b':8:50:' in log.read_bytes() and b':98:46:' in log.read_bytes()
run('stage',['git','add','--',relative])
run('commit',['git','commit','-m','test(widgets): qualify optional event sentinels in two fixtures'])
commit=run('commit-sha',['git','rev-parse','HEAD']).decode().strip()
run('commit-check',['git','show','--check','HEAD'])
assert not run('clean-worktree',['git','status','--porcelain'])
assert run('commit-scope',['git','diff','--name-only',baseline,commit]).decode().splitlines()==[relative]
assert target.read_bytes().replace(new,old)==before
report=base/'report.md'
report.write_text('# TASK-153 narrow fixture typing correction\nStatus: fixed test-only handoff; no product change or behavioral acceptance.\nTest SHA: `'+commit+'`; base `'+baseline+'`.\nOnly `tests/widgets_small/src/event_boundaries.cj` lines8/98 changed: `repeat: None` → `repeat: Option<UIKeyEvent>.None`.\nAll oracles and all other source bytes are preserved; reversing the two qualifiers reproduces exact baseline bytes.\nActual154 compiler log reports the two ambiguous None constructors; this is fixture typing failure, not product RED.\nSDK1.2 cjfmt parser0, exact-two-line diff0, inverse-byte equality0, commit/scope/clean-tree checks0.\nAll previous296 evidence bindings plus old report/index are unchanged.\nEvidence: `evidence/index.json`, before/after snapshots and raw compiler/verification logs.\nNo full-body or behavior PASS claimed; implementation154 must rerun the affected normal runner.\n')
index={'task':'TASK153 fixture typing correction','test_commit':commit,'base':baseline,'source':str(root),'only_changed_file':relative,'before':entry(ev/'before.cj'),'after':entry(ev/'after.cj'),'inverse_bytes_equal':True,'changed_lines':[8,98],'old_frozen_index':old_index,'old_bindings_rechecked':len(checks),'commands':records,'report':entry(report),'artifacts':[entry(p) for p in sorted(ev.rglob('*')) if p.is_file()],'actual_compiler_log_origin':str(log),'classification':'FIXTURE_TYPING_ERROR_NOT_PRODUCT_RED','not_claimed':['full-body typecheck','behavior','PTY','product completion']}
(ev/'index.json').write_text(json.dumps(index,indent=2)+'\n')
for p in ev.rglob('*'):
 if p.is_file():p.chmod(0o444)
report.chmod(0o444)
print(json.dumps({'sha':commit,'report':entry(report),'index':entry(ev/'index.json'),'before':entry(ev/'before.cj'),'after':entry(ev/'after.cj'),'old_bindings_unchanged':len(checks)},indent=2))

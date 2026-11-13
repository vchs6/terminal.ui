import hashlib,json,pathlib,subprocess,sys
base=pathlib.Path('/workspace/work/widgets-small-tests/pty-tool-fix');root=base/'source';ev=base/'evidence';baseline='480b066fac8d4fbe437732f2fcae6712e3ae1da6';sha=lambda p:hashlib.sha256(pathlib.Path(p).read_bytes()).hexdigest()
def entry(p):
 p=pathlib.Path(p);return {'path':str(p),'sha256':sha(p),'bytes':p.stat().st_size}
def git(*a):return subprocess.check_output(['git',*a],cwd=root,text=True).strip()
commands=json.loads((ev/'commands.json').read_text());assert commands[0]['name']=='syntax-import-transport' and commands[0]['exit']==0
relative='tests/widgets_small/pty.py';before=(ev/'before.py').read_text();after=(root/relative).read_text()
assert after.replace('json, os, select','json, os, pty, select').replace('    master, slave = os.openpty()','    master, slave = pty.openpty()')==before
changed=[i for i,(a,b) in enumerate(zip(before.splitlines(),after.splitlines()),1) if a!=b];assert changed==[3,12]
assert git('diff','--name-only').splitlines()==[relative]
unchanged=[]
for name in git('ls-files','tests/widgets_small').splitlines():
 if name==relative:continue
 assert subprocess.check_output(['git','show',baseline+':'+name],cwd=root)==(root/name).read_bytes();unchanged.append(name)
prior=pathlib.Path('/workspace/work/widgets-small-tests/focus-fixture-fix/evidence/index.json');assert sha(prior)=='299e44ddd76be1bffde303a1a55808d590eb9751a2e36a532411d3ad4bba8eb0'
d=json.loads(prior.read_text());checks=[d['inventory_and_inverse'],d['audit'],d['preservation'],d['report']]+list(d['authority'].values())+d['artifacts']+[v for v in d['probe'].values() if isinstance(v,dict) and 'sha256' in v]
for item in checks:assert sha(item['path'])==item['sha256'],item['path']
(ev/'preservation-and-inverse.json').write_text(json.dumps({'base':baseline,'changed_lines':changed,'inverse_bytes_equal':True,'all_other_test_files_byte_equal':unchanged,'device_source_behavior_assertions_exits_inputs_modes_restore_time_budget_unchanged':True,'prior_index':entry(prior),'prior_bindings_unchanged':len(checks)},indent=2)+'\n')
for mode,expected in [('normal',0),('forced-termination',-9)]:
 m=json.loads((ev/('tool-only-'+mode)/'metadata.json').read_text());assert m['classification']=='TOOL_ONLY_NONPRODUCT' and m['result']=='TOOL_ONLY_PASS' and m['exit']==expected
subprocess.run(['git','add','--',relative],cwd=root,check=True);subprocess.run(['git','diff','--cached','--check'],cwd=root,check=True)
p=subprocess.run(['git','commit','-m','test(widgets): allocate PTYs through os to avoid runner import shadowing'],cwd=root,stdout=subprocess.PIPE,stderr=subprocess.PIPE);assert p.returncode==0
(ev/'raw/commit.stdout').write_bytes(p.stdout);(ev/'raw/commit.stderr').write_bytes(p.stderr)
commit=git('rev-parse','HEAD');assert not git('status','--porcelain');assert git('diff','--name-only',baseline,commit).splitlines()==[relative];subprocess.run(['git','show','--check','HEAD'],cwd=root,stdout=subprocess.DEVNULL,check=True)
report=base/'report.md';report.write_text('# TASK-153 PTY runner import correction\nTest-only SHA: `'+commit+'`; baseline `'+baseline+'`.\nOnly pty.py lines3/12 change: remove shadowed pty import and call existing POSIX os.openpty().\nAll device source, product assertions/inputs/exit codes/mode checks/restoration/time budgets and other35 test files are byte-equal.\nActual AttributeError runner-focus.log preserved; failure preceded product PTY execution and is classified TOOL failure.\nPython syntax/help/import surface0; actual nonproduct OS PTY normal and forced-termination transport controls0; inverse/scope/commit checks0, clean worktree.\nBounded launcher import/FD/metadata/termination audit found no further proven pre-execution defect; controls are TOOL-ONLY, never target PASS.\nProducer must use a fresh PTY output path because the preserved failed run already created its normal directory.\nEvidence/index.json binds before/after, raw logs, module origins, helper/transport bytes/metadata and prior immutable index; all prior bindings checked unchanged.\nNo widget/three-mode product/native restoration/154 acceptance PASS; producer154 and later independent156 retain actual execution responsibility.\n')
artifacts=[entry(p) for p in sorted(ev.rglob('*')) if p.is_file()]
index={'task':'TASK153 PTY tool import shadowing correction','test_commit':commit,'baseline':baseline,'source':str(root),'only_changed_file':relative,'changed_lines':changed,'before':entry(ev/'before.py'),'after':entry(ev/'after.py'),'audit':entry(ev/'launcher-audit.md'),'preservation':entry(ev/'preservation-and-inverse.json'),'python':{'interpreter':entry(sys.executable),'version':sys.version,'api':'POSIX os.openpty','import_surface':entry(ev/'import-surface.json')},'commands':commands,'commit_command':{'cwd':str(root),'argv':['git','commit','-m','test(widgets): allocate PTYs through os to avoid runner import shadowing'],'exit':0},'transport_controls':'TOOL_ONLY_NONPRODUCT; actual OS PTY normal+forced termination; no driver.run or product binary invoked','artifacts':artifacts,'report':entry(report),'not_claimed':['widget behavior pass','product PTY pass','product native restoration','TASK154 acceptance','Linux completion']}
(ev/'index.json').write_text(json.dumps(index,indent=2)+'\n')
for item in artifacts+[entry(ev/'index.json'),entry(report)]:
 p=pathlib.Path(item['path']);assert sha(p)==item['sha256'];p.chmod(0o555 if p.stat().st_mode&0o111 else 0o444)
assert len(report.read_text().splitlines())<=12
print(json.dumps({'sha':commit,'report':entry(report),'index':entry(ev/'index.json'),'changed_lines':changed,'syntax_import_transport':0,'product_executed':False},indent=2))

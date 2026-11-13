import hashlib,json,pathlib,subprocess
base=pathlib.Path('/workspace/work/widgets-small-tests/focus-fixture-fix');root=base/'source';ev=base/'evidence';baseline='fc7344eecdabcb318210ff9c0b6793e83b2c47f5';sha=lambda p:hashlib.sha256(pathlib.Path(p).read_bytes()).hexdigest()
def entry(p):
 p=pathlib.Path(p);return {'path':str(p),'sha256':sha(p),'bytes':p.stat().st_size}
def git(*a):return subprocess.check_output(['git',*a],cwd=root,text=True).strip()
commands=json.loads((ev/'commands.json').read_text());by={r['name']:r for r in commands};assert by['public-focus-build']['exit']==by['public-focus-direct']['exit']==0
files=git('ls-files','tests/widgets_small').splitlines();inventory=[]
for name in files:
 if name.endswith('.cj'):
  for i,line in enumerate((root/name).read_text().splitlines(),1):
   if '.requestFocus(' in line:inventory.append({'file':name,'line':i,'source':line})
assert inventory==[{'file':'tests/widgets_small/src/event_boundaries.cj','line':90,'source':'    children[1].requestFocus()'},{'file':'tests/widgets_small/src/remount_cases.cj','line':42,'source':'    current.requestFocus()'}]
edits=[('tests/widgets_small/src/event_boundaries.cj','    children[1].requestFocus()','    app.batch({ => children[1].requestFocus() })\n    assertEvent(children[1].isFocused(), "second Radio focused before positive activation")'),('tests/widgets_small/src/remount_cases.cj','    current.requestFocus()','    app.batch({ => current.requestFocus() })\n    assertLifetime(current.isFocused(), "remounted control focused before positive activation")')]
for name,old,new in edits:
 p=root/name;before=p.read_text();assert before.count(old)==1;after=before.replace(old,new);assert after.replace(new,old)==before
 (ev/(p.stem+'-before.cj')).write_text(before);p.write_text(after);(ev/(p.stem+'-after.cj')).write_text(after)
(ev/'inventory-and-inverse.json').write_text(json.dumps({'all_tracked_S_sources_inventoried':[name for name in files if name.endswith('.cj')],'before_focus_calls':inventory,'edits':[{'file':name,'old':old,'new':new} for name,old,new in edits],'inverse_bytes_equal':True,'all_remaining_focus_calls_in_explicit_batch':True,'unfocused_negative_cases_unchanged':True,'callback_model_event_style_goldens_unchanged':True},indent=2)+'\n')
cmd='source /workspace/work/validation/sdk/cangjie/envsetup.sh && cjfmt -f tests/widgets_small/src/event_boundaries.cj -o /workspace/work/widgets-small-tests/focus-fixture-fix/evidence/formatted-event.cj && cjfmt -f tests/widgets_small/src/remount_cases.cj -o /workspace/work/widgets-small-tests/focus-fixture-fix/evidence/formatted-remount.cj && git diff --check && git diff -- tests/widgets_small/src/event_boundaries.cj tests/widgets_small/src/remount_cases.cj'
p=subprocess.run(['bash','-c',cmd],cwd=root,stdout=subprocess.PIPE,stderr=subprocess.PIPE);raw={}
for label,data in [('stdout',p.stdout),('stderr',p.stderr)]:
 f=ev/'raw'/('parser-and-exact-diff.'+label);f.write_bytes(data);raw[label]=entry(f)
commands.append({'name':'parser-and-exact-diff','cwd':str(root),'command':cmd,'exit':p.returncode,'raw':raw});assert p.returncode==0
(ev/'commands.json').write_text(json.dumps(commands,indent=2)+'\n')
changed=[name for name,_,_ in edits];assert git('diff','--name-only').splitlines()==changed
unchanged=[]
for name in files:
 if name in changed:continue
 assert subprocess.check_output(['git','show',baseline+':'+name],cwd=root)==(root/name).read_bytes();unchanged.append(name)
prior=pathlib.Path('/workspace/work/widgets-small-tests/zero-frame-fix/evidence/index.json');assert sha(prior)=='dd25c3e4da3b7a943be3b3b1b87d7f5c50171aede670374f53a57d8069f03440'
d=json.loads(prior.read_text());checks=[d['before'],d['after'],d['audit'],d['preservation'],d['report']]+list(d['authority_and_existing_positive_cases'].values())+d['artifacts']+[value for value in d['probe'].values() if isinstance(value,dict) and 'sha256' in value]
for item in checks:assert sha(item['path'])==item['sha256'],item['path']
(ev/'preservation.json').write_text(json.dumps({'prior_index':entry(prior),'prior_bindings_verified_unchanged':len(checks),'other_test_files_byte_equal':unchanged,'inverse_bytes_equal':True},indent=2)+'\n')
subprocess.run(['git','add','--',*changed],cwd=root,check=True);subprocess.run(['git','diff','--cached','--check'],cwd=root,check=True)
p=subprocess.run(['git','commit','-m','test(widgets): commit and assert focus before positive activation'],cwd=root,stdout=subprocess.PIPE,stderr=subprocess.PIPE);assert p.returncode==0
(ev/'raw/commit.stdout').write_bytes(p.stdout);(ev/'raw/commit.stderr').write_bytes(p.stderr)
commit=git('rev-parse','HEAD');assert not git('status','--porcelain');assert git('diff','--name-only',baseline,commit).splitlines()==changed;subprocess.run(['git','show','--check','HEAD'],cwd=root,stdout=subprocess.DEVNULL,check=True)
inputs={}
for name in ['openspec/changes/implement-public-interaction/design.md','openspec/changes/implement-reactive-runtime/design.md','openspec/changes/implement-standard-widgets/design.md','tests/interaction_a/src/focus_repair.cj','tests/runtime/src/scheduler.cj']:
 p=pathlib.Path('/workspace/work/terminal.ui')/name;assert subprocess.check_output(['git','show',baseline+':'+name],cwd='/workspace/work/terminal.ui')==p.read_bytes();inputs[name]=entry(p)
report=base/'report.md';report.write_text('# TASK-153 focused activation fixture preconditions\nTest-only SHA: `'+commit+'`; baseline `'+baseline+'`.\nOnly event_boundaries.cj duplicateRadioLabels and remount_cases.cj positive activation setups change: requestFocus in app.batch, then strict isFocused assertion before unchanged dispatch.\nAuthority: accepted Interaction A.4 requestFocus boundary semantics and explicit-dispatch no-focus-change rule; frozen W003 requires actual focused target.\nAll tracked S focus calls inventoried: exactly these two; remaining S02/S05 queued setup boundaries audited once with no further proven mistake.\nUnfocused negative cases, callback/model/event/style/frame expectations and other34 test files remain byte-equal; bounded inverse and parser0 verified.\nIndependent public focusable Text control build0/direct0 proves batch commits requested focus before dispatch; no Radio substitute or widget oracle.\nActual154 runner-zero.log is preserved separately; prior zero-frame index/raw/source bindings verified unchanged.\nEvidence/index.json binds inventory/audit, before/after, authority/probe inputs, binary and raw command hashes; clean test-only commit.\nNo full-widget/PTY/154 acceptance PASS; producer154 must rerun its affected normal runner.\n')
artifacts=[entry(p) for p in sorted(ev.rglob('*')) if p.is_file() and 'target' not in p.relative_to(ev).parts and 'build-script-cache' not in p.relative_to(ev).parts]
index={'task':'TASK153 focus-precondition fixture correction','test_commit':commit,'baseline':baseline,'source':str(root),'changed_files':changed,'inventory_and_inverse':entry(ev/'inventory-and-inverse.json'),'audit':entry(ev/'setup-boundary-audit.md'),'authority':inputs,'preservation':entry(ev/'preservation.json'),'probe':{'source':entry(ev/'public-probe/src/main.cj'),'manifest':entry(ev/'public-probe/cjpm.toml'),'configuration':entry(ev/'public-probe/cangjie-repo.toml'),'dependencies':entry(ev/'public-probe/cjpm.lock'),'binary':entry(ev/'public-probe/target/release/bin/main'),'product_path':'/workspace/work/terminal.ui','product_fixed_sha':baseline,'scope':'public focusable Text, batch, isFocused/focusedNode only'},'commands':commands,'commit_command':{'cwd':str(root),'argv':['git','commit','-m','test(widgets): commit and assert focus before positive activation'],'exit':0},'artifacts':artifacts,'report':entry(report),'not_claimed':['widget behavior pass','PTY','TASK154 acceptance','Linux completion']}
(ev/'index.json').write_text(json.dumps(index,indent=2)+'\n')
for item in artifacts+[entry(ev/'index.json'),entry(report)]:
 p=pathlib.Path(item['path']);assert sha(p)==item['sha256'];p.chmod(0o555 if p.stat().st_mode&0o111 else 0o444)
assert len(report.read_text().splitlines())<=15
print(json.dumps({'sha':commit,'report':entry(report),'index':entry(ev/'index.json'),'public_focus_build_direct':[0,0],'parser':0,'sites_corrected':2},indent=2))

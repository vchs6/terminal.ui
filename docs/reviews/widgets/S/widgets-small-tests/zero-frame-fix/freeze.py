import hashlib,json,pathlib,subprocess
base=pathlib.Path('/workspace/work/widgets-small-tests/zero-frame-fix');root=base/'source';ev=base/'evidence';baseline='b26529e5bd31839fdc19fb11e05cb5d814ef36f3';sha=lambda p:hashlib.sha256(pathlib.Path(p).read_bytes()).hexdigest()
def entry(p):
 p=pathlib.Path(p);return {'path':str(p),'sha256':sha(p),'bytes':p.stat().st_size}
def git(*a):return subprocess.check_output(['git',*a],cwd=root,text=True).strip()
commands=json.loads((ev/'commands.json').read_text());by={r['name']:r for r in commands};assert by['public-frame-build']['exit']==by['public-frame-direct']['exit']==0
relative='tests/widgets_small/src/progress_geometry.cj';p=root/relative;before=p.read_text();(ev/'before.cj').write_text(before)
old='equal(frame(Progress(fraction).width(0).height(2), 0, 2), "", "valid zero width")'
new='equal(frame(Progress(fraction).width(0).height(2), 0, 2), "\\n", "valid zero width")'
assert before.count(old)==1;after=before.replace(old,new);assert after.replace(new,old)==before
p.write_text(after);(ev/'after.cj').write_text(after)
# Bound the edit to the manually derived serialization literal only.
assert [(i,a,b) for i,(a,b) in enumerate(zip(before.splitlines(),after.splitlines()),1) if a!=b]==[(10,'        '+old,'        '+new)]
cmd='source /workspace/work/validation/sdk/cangjie/envsetup.sh && cjfmt -f tests/widgets_small/src/progress_geometry.cj -o /workspace/work/widgets-small-tests/zero-frame-fix/evidence/formatted.cj && git diff --check && git diff -- tests/widgets_small/src/progress_geometry.cj'
x=subprocess.run(['bash','-c',cmd],cwd=root,stdout=subprocess.PIPE,stderr=subprocess.PIPE);raw={}
for label,data in [('stdout',x.stdout),('stderr',x.stderr)]:
 f=ev/'raw'/('parser-and-exact-diff.'+label);f.write_bytes(data);raw[label]=entry(f)
commands.append({'name':'parser-and-exact-diff','cwd':str(root),'command':cmd,'exit':x.returncode,'raw':raw});assert x.returncode==0
(ev/'commands.json').write_text(json.dumps(commands,indent=2)+'\n')
assert git('diff','--name-only').splitlines()==[relative]
unchanged=[]
for name in git('ls-files','tests/widgets_small').splitlines():
 if name==relative:continue
 assert subprocess.check_output(['git','show',baseline+':'+name],cwd=root)==(root/name).read_bytes();unchanged.append(name)
old_index=pathlib.Path('/workspace/work/widgets-small-tests/initial-theme-fix/evidence/index.json');assert sha(old_index)=='d9f1daf4349f3fc008a930f2bb069ef7555727a347e67f9ea4b402c9ca450733'
d=json.loads(old_index.read_text());old_checks=[d['before'],d['after'],d['inventory'],d['preservation_and_reused_proof'],d['report']]+d['artifacts']
for item in old_checks:assert sha(item['path'])==item['sha256'],item['path']
(ev/'preservation.json').write_text(json.dumps({'prior_index':entry(old_index),'prior_bindings_verified_unchanged':len(old_checks),'other_test_files_byte_equal':unchanged,'inverse_bytes_equal':True,'only_changed_line':10,'golden_derivation':'zero width, height2: empty row + one LF + empty row','nonzero_bars_styles_events_fraction_assertions_unchanged':True},indent=2)+'\n')
subprocess.run(['git','add','--',relative],cwd=root,check=True);subprocess.run(['git','diff','--cached','--check'],cwd=root,check=True)
x=subprocess.run(['git','commit','-m','test(widgets): preserve empty-row separators in zero-width frame golden'],cwd=root,stdout=subprocess.PIPE,stderr=subprocess.PIPE);assert x.returncode==0
(ev/'raw/commit.stdout').write_bytes(x.stdout);(ev/'raw/commit.stderr').write_bytes(x.stderr)
commit=git('rev-parse','HEAD');assert not git('status','--porcelain');assert git('diff','--name-only',baseline,commit).splitlines()==[relative]
subprocess.run(['git','show','--check','HEAD'],cwd=root,stdout=subprocess.DEVNULL,check=True)
inputs={}
for name in ['openspec/changes/implement-frame-composition/design.md','openspec/changes/implement-reactive-runtime/design.md','openspec/changes/implement-public-interaction/design.md','openspec/changes/implement-theme-styles/design.md','openspec/changes/implement-standard-widgets/design.md','tests/runtime/src/scheduler.cj','tests/runtime/src/cleanup.cj','tests/runtime/src/bindings.cj','tests/interaction_a/src/full_canvas_cells.cj','tests/interaction_a/src/lifecycle_and_limits.cj','tests/interaction_b/src/root_canvas.cj','src/frame.cj']:
 path=pathlib.Path('/workspace/work/terminal.ui')/name;assert subprocess.check_output(['git','show',baseline+':'+name],cwd='/workspace/work/terminal.ui')==path.read_bytes();inputs[name]=entry(path)
report=base/'report.md';report.write_text('# TASK-153 zero-frame serialization fixture correction and bounded audit\nTest-only SHA: `'+commit+'`; baseline `'+baseline+'`.\nOnly progress_geometry.cj line10 changes: width0/height2 manual golden empty → one LF; all nonzero bars/styles/events/fraction checks unchanged.\nAuthority: accepted Frame composition design §2 explicitly preserves height−1 LF for zero-width finite-height exports; height0 and width0/height1 stay empty.\nIndependent public Frame consumer builds0/direct0 against manual goldens for (0,0), (0,1), (0,2), (1,0); no product helper generates expected values.\nRemaining S04/S05 assumptions audited once against accepted Frame/Runtime/Interaction/Theme and existing positive cases; no other clearly proven fixture mistake found.\nAudit covers content/padding/viewport/readsets, initial themes, batch/post cutoffs, stale generations, cleanup/resources, multiview/error/native setup; details in evidence/remaining-S04-S05-audit.md.\nExact one-line diff/inverse equality, parser0, unchanged other35 test files and preserved prior evidence verified; clean test-only commit.\nActual154 runner-palette.log preserved separately; no S154 implementation source read or expected values inferred from its output.\nEvidence/index.json binds authority/input/probe/source/binary/raw hashes. No widget/PTY/154 acceptance PASS or generic correctness claim.\n')
artifacts=[entry(path) for path in sorted(ev.rglob('*')) if path.is_file() and 'target' not in path.relative_to(ev).parts and 'build-script-cache' not in path.relative_to(ev).parts]
index={'task':'TASK153 zero-frame fixture literal and remaining S04/S05 audit','test_commit':commit,'baseline':baseline,'source':str(root),'only_changed_file':relative,'only_changed_line':10,'before':entry(ev/'before.cj'),'after':entry(ev/'after.cj'),'audit':entry(ev/'remaining-S04-S05-audit.md'),'authority_and_existing_positive_cases':inputs,'preservation':entry(ev/'preservation.json'),'probe':{'source':entry(ev/'public-probe/src/main.cj'),'manifest':entry(ev/'public-probe/cjpm.toml'),'configuration':entry(ev/'public-probe/cangjie-repo.toml'),'dependencies':entry(ev/'public-probe/cjpm.lock'),'binary':entry(ev/'public-probe/target/release/bin/main'),'product_path':'/workspace/work/terminal.ui','product_fixed_sha':baseline,'scope':'public Frame serialization only; no widget'},'commands':commands,'commit_command':{'cwd':str(root),'argv':['git','commit','-m','test(widgets): preserve empty-row separators in zero-width frame golden'],'exit':0},'artifacts':artifacts,'report':entry(report),'not_claimed':['generic widget correctness','full widget pass','PTY','TASK154 acceptance','Linux completion']}
(ev/'index.json').write_text(json.dumps(index,indent=2)+'\n')
for item in artifacts+[entry(ev/'index.json'),entry(report)]:
 path=pathlib.Path(item['path']);assert sha(path)==item['sha256'];path.chmod(0o555 if path.stat().st_mode&0o111 else 0o444)
assert len(report.read_text().splitlines())<=15
print(json.dumps({'sha':commit,'report':entry(report),'index':entry(ev/'index.json'),'changed_lines':1,'public_frame_build_direct':[0,0],'parser':0},indent=2))

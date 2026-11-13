import hashlib,json,pathlib,subprocess
base=pathlib.Path('/workspace/work/widgets-small-tests/palette-fix');root=base/'source';ev=base/'evidence';baseline='09ce650a07715ad67a7f22b1930745b71b61bb10'
sha=lambda p:hashlib.sha256(pathlib.Path(p).read_bytes()).hexdigest()
def entry(p):
 p=pathlib.Path(p);return {'path':str(p),'sha256':sha(p),'bytes':p.stat().st_size}
def git(*a):return subprocess.check_output(['git',*a],cwd=root,text=True).strip()
commands=json.loads((ev/'commands.json').read_text());by={r['name']:r for r in commands}
assert by['public-probe-build-constructor']['exit']==by['public-probe-direct-constructor']['exit']==0
probe_output=pathlib.Path(by['public-probe-direct-constructor']['raw']['stdout']['path']).read_text()
assert probe_output.splitlines()==['COLOR_ONLY_INHERITS_CLASSIC_INVERSE','FULL_INLINE_FALSE_OVERRIDES_CLASSIC_ATTRIBUTES','FULL_NAMED_FALSE_OVERRIDES_CLASSIC_ATTRIBUTES']
# Change setup only after the independent public-primitive diagnosis is verified.
relative='tests/widgets_small/src/theme_cases.cj';p=root/relative;before=p.read_text();(ev/'theme-before.cj').write_text(before)
old_named='        "[styles.test.text]\\nforeground = \\"cyan\\"\\n" +'
new_named='        "[styles.test.text]\\nforeground = \\"cyan\\"\\nbackground = \\"black\\"\\nbold = false\\ndim = false\\nitalic = false\\nunderline = false\\ninverse = false\\nstrikethrough = false\\n" +'
anchor='        .withValue(StyleKeys.background, StyleValue<Color>.Value(Color.Black))\n'
boolean_lines=''.join('        .withValue(StyleKeys.'+name+', StyleValue<Bool>.Value(false))\n' for name in ['bold','dim','italic','underline','inverse','strikethrough'])
assert before.count(old_named)==1 and before.count(anchor)==1
helper_before=before[before.index('func styleIs('):before.index('func themeCases(')]
edits=[(old_named,new_named),(anchor,anchor+boolean_lines)]
for variable,component in [('app','button'),('selectedApp','selected'),('inherited','root'),('simulated','visual'),('focusApp','focusPair')]:
 old='    let '+variable+' = Application('+component+')\n    '+variable+'.loadTheme(ThemeSource.Prepared(theme))'
 new='    let '+variable+' = Application('+component+', theme: theme)'
 edits.append((old,new))
old_wrap_start='    let wrapped = Application(Label("ABCD"))\n    wrapped.loadTheme(ThemeSource.Prepared(Theme.parse('
new_wrap_start='    let wrapped = Application(Label("ABCD"), theme: Theme.parse('
wrap_start=before.index(old_wrap_start);wrap_end=before.index('\n',wrap_start+len(old_wrap_start))
old_wrap=before[wrap_start:wrap_end]
assert old_wrap.endswith(')))')
new_wrap=old_wrap.replace(old_wrap_start,new_wrap_start,1)[:-1]
edits.append((old_wrap,new_wrap))
edits.append(('StyleUse, Theme, ThemeSource, VisualStates','StyleUse, Theme, VisualStates'))
after=before
for old,new in edits:
 assert after.count(old)==1,(old,after.count(old))
 after=after.replace(old,new,1)
restored=after
for old,new in reversed(edits):
 assert restored.count(new)==1,(new,restored.count(new))
 restored=restored.replace(new,old,1)
assert restored==before
assert after[after.index('func styleIs('):after.index('func themeCases(')]==helper_before
p.write_text(after);(ev/'theme-after.cj').write_text(after)
(ev/'bounded-edit.json').write_text(json.dumps({'file':relative,'old_named':old_named,'new_named':new_named,'inline_anchor':anchor,'six_false_values':boolean_lines,'inverse_equals_baseline':True,'styleIs_byte_equal':True,'expected_styles_pixels_events_unchanged':True,'initial_theme_constructor_edits':edits[2:],'root_scope':'initial theme setup in theme_cases ONLY'},indent=2)+'\n')
cmd='source /workspace/work/validation/sdk/cangjie/envsetup.sh && cjfmt -f tests/widgets_small/src/theme_cases.cj -o /workspace/work/widgets-small-tests/palette-fix/evidence/formatted.cj && git diff --check && git diff -- tests/widgets_small/src/theme_cases.cj'
p=subprocess.run(['bash','-c',cmd],cwd=root,stdout=subprocess.PIPE,stderr=subprocess.PIPE)
raw={}
for label,value in [('stdout',p.stdout),('stderr',p.stderr)]:
 f=ev/'raw'/('parser-and-bounded-diff.'+label);f.write_bytes(value);raw[label]=entry(f)
commands.append({'name':'parser-and-bounded-diff','cwd':str(root),'command':cmd,'exit':p.returncode,'raw':raw});assert p.returncode==0
(ev/'commands.json').write_text(json.dumps(commands,indent=2)+'\n')
assert git('diff','--name-only').splitlines()==[relative]
unchanged=[]
for name in git('ls-files','tests/widgets_small').splitlines():
 if name==relative:continue
 assert subprocess.check_output(['git','show',baseline+':'+name],cwd=root)==(root/name).read_bytes();unchanged.append(name)
old_indices={}
for label,path in [('final','/workspace/work/widgets-small-tests/final/evidence/index.json'),('typing_fix','/workspace/work/widgets-small-tests/typing-fix/evidence/index.json'),('contract_fix','/workspace/work/widgets-small-tests/contract-fix/evidence/index.json')]:
 f=pathlib.Path(path);d=json.loads(f.read_text());old_indices[label]=entry(f)
 if label=='final':checks=list(d['product_files'].values())+list(d['test_files'].values())+list(d['inputs'].values())+d['sdk']['files']+d['registry_configs']+[d['resolved_dependencies'],d['prerequisite_binary'],d['report']]+d['artifacts']
 elif label=='typing_fix':checks=[d['before'],d['after'],d['report']]+d['artifacts']
 else:checks=list(d['inputs'].values())+[d['preservation'],d['report']]+[v for v in d['probe'].values() if isinstance(v,dict) and 'sha256' in v]+d['artifacts']
 for item in checks:assert sha(item['path'])==item['sha256'],item['path']
 old_indices[label]['bindings_unchanged']=len(checks)
(ev/'preservation.json').write_text(json.dumps({'old_indices':old_indices,'all_other_test_files_byte_equal':unchanged,'styleIs_byte_equal':True,'inverse_equals_baseline':True},indent=2)+'\n')
subprocess.run(['git','add','--',relative],cwd=root,check=True);subprocess.run(['git','diff','--cached','--check'],cwd=root,check=True)
p=subprocess.run(['git','commit','-m','test(widgets): initialize explicit theme palettes in style fixtures'],cwd=root,stdout=subprocess.PIPE,stderr=subprocess.PIPE);assert p.returncode==0
(ev/'raw/commit.stdout').write_bytes(p.stdout);(ev/'raw/commit.stderr').write_bytes(p.stderr)
commit=git('rev-parse','HEAD');assert not git('status','--porcelain');assert git('diff','--name-only',baseline,commit).splitlines()==[relative]
subprocess.run(['git','show','--check','HEAD'],cwd=root,stdout=subprocess.DEVNULL,check=True)
report=base/'report.md';report.write_text('# TASK-153 explicit palette fixture correction\nStatus: narrow independent test-only handoff; no contract or product change.\nTest SHA: `'+commit+'`; base `'+baseline+'`.\nIndependent public Text/Checkbox-role primitive probe build0/direct0 confirms color-only Inline inherits Classic selected inverse=true.\nThe same probe confirms six explicit false Boolean attributes override Classic for both Inline and Named palettes, using complete Style equality.\nOnly theme_cases.cj setup changed: explicit complete Inline/Named palettes and six initial themes supplied through the documented Application(theme:) constructor.\nstyleIs, complete expected Styles, pixels/events/oracles and all other35 test files are byte-equal; bounded inverse proof and parser0.\nPrior final/typing-fix/contract-fix indices and bound artifacts remain unchanged; actual154 runner-contract.log and style-probe2.log preserved separately.\nEvidence: `evidence/index.json` binds before/after, canonical per-field Theme/Classic inputs, public probe source/binary and raw commands.\nOriginal pre-start loadTheme control failure is retained as fixture setup evidence; accepted inactive loads return SessionClosed.\nRemaining gap: progress_geometry.cj still uses pre-start loadTheme outside this authorized theme_cases-only correction; no full-widget/154 PASS.\n')
inputs={}
for name in ['themes/classic.toml','openspec/changes/implement-theme-styles/design.md','src/style/style_keys.cj','src/theme/theme_schema.cj','src/application.cj','src/theme_loader.cj','tests/theme-loading/consumer/src/lifecycle.cj']:
 path=pathlib.Path('/workspace/work/terminal.ui')/name
 assert subprocess.check_output(['git','show',baseline+':'+name],cwd='/workspace/work/terminal.ui')==path.read_bytes();inputs[name]=entry(path)
assert subprocess.check_output(['git','rev-parse','HEAD'],cwd='/workspace/work/terminal.ui',text=True).strip()==baseline
artifacts=[entry(path) for path in sorted(ev.rglob('*')) if path.is_file() and 'target' not in path.relative_to(ev).parts and 'build-script-cache' not in path.relative_to(ev).parts]
index={'task':'TASK153 explicit complete fixture palette','test_commit':commit,'baseline':baseline,'source':str(root),'only_changed_file':relative,'diagnosis':'Verified before fixture mutation: per-field unset flags inherit Classic; full explicit false overrides. Initial themes use Application(theme:) because inactive loadTheme returns SessionClosed.','before':entry(ev/'theme-before.cj'),'after':entry(ev/'theme-after.cj'),'canonical_inputs':inputs,'preservation':entry(ev/'preservation.json'),'probe':{'source':entry(ev/'public-probe/src/main.cj'),'manifest':entry(ev/'public-probe/cjpm.toml'),'configuration':entry(ev/'public-probe/cangjie-repo.toml'),'dependencies':entry(ev/'public-probe/cjpm.lock'),'binary':entry(ev/'public-probe/target/release/bin/main'),'product_path':'/workspace/work/terminal.ui','product_fixed_sha':baseline,'scope':'public Text/ThemeRole.Checkbox/VisualStates only; no widgets'},'commands':commands,'commit_command':{'cwd':str(root),'argv':['git','commit','-m','test(widgets): initialize explicit theme palettes in style fixtures'],'exit':0},'artifacts':artifacts,'report':entry(report),'not_claimed':['full widget pass','PTY','TASK154 acceptance','Linux completion']}
(ev/'index.json').write_text(json.dumps(index,indent=2)+'\n')
for item in artifacts+[entry(ev/'index.json'),entry(report)]:
 path=pathlib.Path(item['path']);assert sha(path)==item['sha256'];path.chmod(0o555 if path.stat().st_mode&0o111 else 0o444)
assert len(report.read_text().splitlines())<=12
print(json.dumps({'sha':commit,'report':entry(report),'index':entry(ev/'index.json'),'source_files_changed':1,'public_probe_build_direct':[0,0],'parser':0,'styleIs_unchanged':True},indent=2))

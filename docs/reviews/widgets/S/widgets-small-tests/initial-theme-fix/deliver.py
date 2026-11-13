import hashlib,json,pathlib,subprocess
base=pathlib.Path('/workspace/work/widgets-small-tests/initial-theme-fix');root=base/'source';ev=base/'evidence';baseline='c6bf589e6df199a88851f0311a606d39f4963ad7';records=[]
sha=lambda p:hashlib.sha256(pathlib.Path(p).read_bytes()).hexdigest()
def entry(p):
 p=pathlib.Path(p);return {'path':str(p),'sha256':sha(p),'bytes':p.stat().st_size}
def run(name,args):
 p=subprocess.run(args,cwd=root,stdout=subprocess.PIPE,stderr=subprocess.PIPE);raw={}
 for label,data in [('stdout',p.stdout),('stderr',p.stderr)]:
  f=ev/'raw'/(name+'.'+label);f.write_bytes(data);raw[label]=entry(f)
 records.append({'name':name,'cwd':str(root),'argv':args,'exit':p.returncode,'raw':raw})
 assert p.returncode==0,(name,p.stderr.decode())
 return p.stdout
relative='tests/widgets_small/src/progress_geometry.cj';target=root/relative
tracked=run('tracked-sources',['git','ls-files','tests/widgets_small']).decode().splitlines();sources=[name for name in tracked if name.endswith('.cj')]
site_inventory=[]
for name in sources:
 for i,line in enumerate((root/name).read_text().splitlines(),1):
  if 'loadTheme(' in line or 'reloadTheme(' in line:site_inventory.append({'file':name,'line':i,'source':line,'classification':'pre-start initial theme' if name==relative and i==52 else 'needs classification'})
assert len(site_inventory)==1 and site_inventory[0]['classification']=='pre-start initial theme'
before=target.read_text();(ev/'before.cj').write_text(before)
old='    let themedApp = Application(themed)\n    themedApp.loadTheme(ThemeSource.Prepared(theme))'
new='    let themedApp = Application(themed, theme: theme)'
old_import='Style, Theme, ThemeSource}';new_import='Style, Theme}'
assert before.count(old)==before.count(old_import)==1
after=before.replace(old,new).replace(old_import,new_import)
assert after.replace(new,old).replace(new_import,old_import)==before
target.write_text(after);(ev/'after.cj').write_text(after)
assert not any('loadTheme(' in (root/name).read_text() or 'reloadTheme(' in (root/name).read_text() for name in sources)
assert 'ThemeSource' not in (root/'tests/widgets_small/src/theme_cases.cj').read_text()
assert 'ThemeSource' not in target.read_text()
(ev/'inventory-and-inverse.json').write_text(json.dumps({'baseline':baseline,'inventory_scope':sources,'before_runtime_load_sites':site_inventory,'after_runtime_load_sites':[],'initial_setup_replacement':{'old':old,'new':new},'removed_newly_unused_import':{'old':old_import,'new':new_import},'inverse_bytes_equal':True,'theme_cases_ThemeSource_already_absent':True,'no_post_start_runtime_load_tests_present_in_S':True,'outside_S_runtime_tests_untouched':True},indent=2)+'\n')
run('parser-and-diff',['bash','-c','source /workspace/work/validation/sdk/cangjie/envsetup.sh && cjfmt -f tests/widgets_small/src/progress_geometry.cj -o /workspace/work/widgets-small-tests/initial-theme-fix/evidence/formatted.cj && git diff --check && git diff -- tests/widgets_small/src/progress_geometry.cj'])
assert run('changed-files',['git','diff','--name-only']).decode().splitlines()==[relative]
unchanged=[]
for name in tracked:
 if name==relative:continue
 assert subprocess.check_output(['git','show',baseline+':'+name],cwd=root)==(root/name).read_bytes();unchanged.append(name)
# Reuse actual constructor positive proof; never rebuild/rerun its immutable bundle.
previous=pathlib.Path('/workspace/work/widgets-small-tests/palette-fix/evidence/index.json');d=json.loads(previous.read_text());assert sha(previous)=='bcad37f6568793e1927eafb0021f2406416423699b1612eccdea88f4a305961d'
old_checks=[d['before'],d['after'],d['preservation'],d['report']]+list(d['canonical_inputs'].values())+d['artifacts']+[value for value in d['probe'].values() if isinstance(value,dict) and 'sha256' in value]
for item in old_checks:assert sha(item['path'])==item['sha256'],item['path']
proof=[row for row in d['commands'] if row['name'] in ['public-probe-build-constructor','public-probe-direct-constructor']]
assert len(proof)==2 and all(row['exit']==0 for row in proof)
(ev/'preservation-and-reused-proof.json').write_text(json.dumps({'old_palette_index':entry(previous),'old_bindings_checked':len(old_checks),'all_other_test_files_byte_equal':unchanged,'reused_actual_public_constructor_proof':proof,'no_probe_or_suite_rerun':True},indent=2)+'\n')
run('stage',['git','add','--',relative]);run('commit',['git','commit','-m','test(widgets): initialize Progress fixture theme through constructor'])
commit=run('commit-sha',['git','rev-parse','HEAD']).decode().strip();run('commit-check',['git','show','--check','HEAD']);assert not run('clean-worktree',['git','status','--porcelain'])
assert run('commit-scope',['git','diff','--name-only',baseline,commit]).decode().splitlines()==[relative]
report=base/'report.md';report.write_text('# TASK-153 remaining initial-theme fixture setup\nTest-only SHA: `'+commit+'`; base `'+baseline+'`.\nOnly progress_geometry.cj initial setup changes: Application(themed, theme: theme); newly unused ThemeSource import removed.\nInventory of all tracked S Cangjie sources found one remaining pre-start loadTheme, now corrected; no runtime/post-start loads were changed.\nAll assertions/pixels/events and other35 test files are byte-equal; exact inverse bytes, parser0, scope/commit hygiene0 and clean worktree verified.\nActual constructor primitive build0/direct0 proof from c6 palette evidence is reused; immutable palette source/index/raw bindings verified unchanged.\nEvidence: `evidence/index.json` binds inventory, before/after, inverse, raw checks and reused proof; no probes/suites repeated.\nNo full-widget/154 PASS claimed; implementation154 should consume c6 plus this follow-up and rerun its normal runner.\n')
artifacts=[entry(p) for p in sorted(ev.rglob('*')) if p.is_file()]
index={'task':'TASK153 remaining initial-theme fixture correction','test_commit':commit,'base':baseline,'source':str(root),'only_changed_file':relative,'before':entry(ev/'before.cj'),'after':entry(ev/'after.cj'),'inventory':entry(ev/'inventory-and-inverse.json'),'preservation_and_reused_proof':entry(ev/'preservation-and-reused-proof.json'),'commands':records,'artifacts':artifacts,'report':entry(report),'not_claimed':['full-widget pass','TASK154 acceptance','PTY','Linux completion']}
(ev/'index.json').write_text(json.dumps(index,indent=2)+'\n')
for item in artifacts+[entry(ev/'index.json'),entry(report)]:
 p=pathlib.Path(item['path']);assert sha(p)==item['sha256'];p.chmod(0o444)
assert len(report.read_text().splitlines())<=10
print(json.dumps({'sha':commit,'report':entry(report),'index':entry(ev/'index.json'),'parser':0,'other_files_unchanged':len(unchanged),'remaining_load_sites':0},indent=2))

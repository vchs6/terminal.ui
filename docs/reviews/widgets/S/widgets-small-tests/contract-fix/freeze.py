import hashlib,json,pathlib,subprocess,sys
base=pathlib.Path('/workspace/work/widgets-small-tests/contract-fix');root=base/'source';ev=base/'evidence';baseline='412bfcc5074c9acc5400f555a2e1aa442316ccc7'
sha=lambda p:hashlib.sha256(pathlib.Path(p).read_bytes()).hexdigest()
def entry(p):
 p=pathlib.Path(p);return {'path':str(p),'sha256':sha(p),'bytes':p.stat().st_size}
def git(*a):return subprocess.check_output(['git',*a],cwd=root,text=True).strip()
commands=json.loads((ev/'commands.json').read_text());by={r['name']:r for r in commands}
assert by['public-probe-build']['exit']==by['public-probe-direct']['exit']==by['bounded-parser-check']['exit']==0
assert git('rev-parse','HEAD')==baseline
assert set(git('diff','--name-only').splitlines())=={'tests/widgets_small/src/construction_cases.cj','tests/widgets_small/README.md'}
subprocess.run(['git','add','--','tests/widgets_small/src/construction_cases.cj','tests/widgets_small/README.md'],cwd=root,check=True)
p=subprocess.run(['git','diff','--cached','--check'],cwd=root,stdout=subprocess.PIPE,stderr=subprocess.PIPE);assert p.returncode==0
p=subprocess.run(['git','commit','-m','test(widgets): distinguish legacy and typed capability errors'],cwd=root,stdout=subprocess.PIPE,stderr=subprocess.PIPE);assert p.returncode==0,p.stderr
(ev/'raw/commit.stdout').write_bytes(p.stdout);(ev/'raw/commit.stderr').write_bytes(p.stderr)
commit=git('rev-parse','HEAD');assert not git('status','--porcelain');subprocess.run(['git','show','--check','HEAD'],cwd=root,stdout=subprocess.DEVNULL,check=True)
assert set(git('diff','--name-only',baseline,commit).splitlines())=={'tests/widgets_small/src/construction_cases.cj','tests/widgets_small/README.md'}
report=base/'report.md';report.write_text('# TASK-153 LEGACY-PROP-001 fixture correction\nStatus: narrow independent test-only handoff; product154 still awaits affected-runner execution.\nTest SHA: `'+commit+'`; baseline `'+baseline+'`.\nOnly construction_cases.cj and its README coverage text changed; old pixels/events/oracles and other34 test files remain byte-equal.\nLabel/Button constant gap now strictly requires IllegalArgumentException through a dedicated exact-type helper.\nAdded only typed setStyle gap, getter gap and resolved incompatible Inline cases requiring UIException/code InvalidProperty.\nCommon expectInvalidProperty helper, Progress.wrap assertion and all fraction assertions are unchanged.\nActual accepted-root Text/Canvas public probe CJPM build0/direct0 verifies those five precise primitive paths; no widget factories are substituted.\nParser0; bounded-edit inverse proof0; old final296 and typing-fix evidence bindings unchanged; clean test-only commit.\nActual154 runner-fixed.log failure is preserved separately as prior contract-conflict evidence.\nEvidence: `evidence/index.json` binds before/after, ruling inputs, probe source/binary, commands and raw hashes.\nNo full-widget, behavioral/PTY or154 acceptance PASS claimed; no S/E/K suite or five missing-API RED repeats.\n')
inputs={}
for name in ['openspec/changes/implement-standard-widgets/specs/standard-widgets/spec.md','openspec/changes/implement-standard-widgets/design.md','docs/reviews/widgets/S/admission/gap-contract-decision/report.md','docs/reviews/widgets/S/input-manifest.json','openspec/changes/implement-layout-decoration/design.md','src/component.cj']:
 p=pathlib.Path('/workspace/work/terminal.ui')/name
 assert subprocess.check_output(['git','show',baseline+':'+name],cwd='/workspace/work/terminal.ui')==p.read_bytes()
 inputs[name]=entry(p)
artifacts=[entry(p) for p in sorted(ev.rglob('*')) if p.is_file() and ('target' not in p.relative_to(ev).parts) and ('build-script-cache' not in p.relative_to(ev).parts)]
index={'task':'TASK153 LEGACY-PROP-001 fixture correction','test_commit':commit,'baseline':baseline,'source':str(root),'changed_files':git('diff','--name-only',baseline,commit).splitlines(),'ruling':'LEGACY-PROP-001 published by root before this correction','inputs':inputs,'preservation':entry(ev/'bounded-and-preservation-check.json'),'probe':{'source':entry(ev/'public-probe/src/main.cj'),'manifest':entry(ev/'public-probe/cjpm.toml'),'configuration':entry(ev/'public-probe/cangjie-repo.toml'),'dependencies':entry(ev/'public-probe/cjpm.lock'),'binary':entry(ev/'public-probe/target/release/bin/main'),'product_path':'/workspace/work/terminal.ui','product_fixed_sha':baseline,'scope':'accepted public Text constant/typed/getter/Inline gap and Canvas.wrap only; no target widget'},'commands':commands,'commit_command':{'cwd':str(root),'argv':['git','commit','-m','test(widgets): distinguish legacy and typed capability errors'],'exit':0},'artifacts':artifacts,'report':entry(report),'not_claimed':['full widget typecheck','widget behavior','PTY','TASK154 acceptance','Linux completion']}
(ev/'index.json').write_text(json.dumps(index,indent=2)+'\n')
for item in artifacts+[entry(ev/'index.json'),entry(report)]:
 p=pathlib.Path(item['path']);assert sha(p)==item['sha256'];p.chmod(0o555 if p.stat().st_mode&0o111 else 0o444)
assert len(report.read_text().splitlines())<=15
print(json.dumps({'sha':commit,'report':entry(report),'index':entry(ev/'index.json'),'changed_files':index['changed_files'],'public_probe_build_direct':[0,0],'parser':0},indent=2))

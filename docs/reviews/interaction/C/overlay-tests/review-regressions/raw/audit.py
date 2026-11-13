from pathlib import Path
import hashlib,json,subprocess,tomllib
b=Path(__file__).resolve().parent.parent;r=b/'replay';s=b/'source';raw=b/'raw'
h=lambda data:hashlib.sha256(data).hexdigest()
git=lambda cwd,*args:subprocess.check_output(['git',*args],cwd=cwd)
j=json.loads((raw/'prehash.json').read_text());old=json.loads((raw/'prehash-before-I10-viewport-fixture.json').read_text())
assert git(r,'rev-parse','HEAD').decode().strip()==j['fixed_product']
assert git(s,'rev-parse','HEAD').decode().strip()==j['test_base']
for p,w in j['inputs_sha256'].items():
 if p!='tests/interaction_c/cjpm.lock':assert h((r/p).read_bytes())==w,p
assert tomllib.loads((raw/'copied-prebuild-cjpm.lock').read_text())==tomllib.loads((r/'tests/interaction_c/cjpm.lock').read_text())
external_bad=[p for p,w in j['external_dependencies_sdk_sha256'].items() if h(Path(p).read_bytes())!=w]
assert not external_bad,external_bad
tracked=set(git(r,'ls-tree','-r','--name-only',j['fixed_product']).decode().splitlines())
product=[p for p in j['inputs_sha256'] if not p.startswith('tests/') and p in tracked]
for p in product:assert h(git(r,'show',j['fixed_product']+':'+p))==j['inputs_sha256'][p],p
new='tests/interaction_c/src/review_regressions.cj'
tests=git(s,'ls-files','tests/interaction_c').decode().splitlines()+[new]
for p in tests:assert (s/p).read_bytes()==(r/p).read_bytes(),p
for p in ['tests/interaction_c/README.md','tests/interaction_c/case-matrix.md','tests/interaction_c/golden.md']:
 assert (s/p).read_bytes().startswith(git(s,'show',j['test_base']+':'+p)),p
main='tests/interaction_c/src/main.cj';text=(s/main).read_text();text=text.replace('    if(let Some(name)<-getVariable("CJTUI_OVERLAY_REVIEW")){return reviewRegression(name)}\n','',1);text=text.replace('    for(name in ["C-I01","C-I02","C-I03","C-I04","C-I05","C-I06","C-I07","C-I08","C-I09","C-I10"]){reviewRegression(name)}\n','',1);assert text.encode()==git(s,'show',j['test_base']+':'+main)
original=(raw/'review_regressions-before-I10-viewport.cj').read_bytes();current=(s/new).read_bytes();prefix=b'func reviewPureExportGeometry():Unit {'
assert original.split(prefix)[0]==current.split(prefix)[0]
assert original.replace(b'let root=Text("A").viewport(ScrollAxes.Off);let layer=Text("P")',b'let root=Text("A").viewport(ScrollAxes.Off);let layer=Text("P").viewport(ScrollAxes.Off)')==current
for p,w in old['inputs_sha256'].items():
 if p not in [new,'tests/interaction_c/cjpm.lock']:assert h((r/p).read_bytes())==w,p
records=json.loads((raw/'commands.json').read_text())
for name in ['build-formal','build-I10-corrected']+[f'C-I{i:02d}' for i in range(1,10)]+['C-I10-corrected']:
 row=[x for x in records if x['name']==name];assert len(row)==1
 want=0 if name.startswith('build') else 1
 assert row[0]['exit']==int((raw/(name+'.exit')).read_text())==want
 if want:assert 'Exception: FAIL C-I' in (raw/(name+'.stderr')).read_text(),name
subprocess.run(['git','diff','--check'],cwd=s,check=True)
print(f'PASS repository prehash {len(j["inputs_sha256"])} inputs; only generated cjpm.lock entry order differs, parsed locks identical')
print(f'PASS external dependency/SDK prehash {len(j["external_dependencies_sdk_sha256"])} files unchanged; fixed-product tracked inputs {len(product)}')
print(f'PASS complete source/replay formal tests equal {len(tests)} files; all old assertions/golden preserved; entry only appends selector and default calls')
print('PASS first-nine functions/reviewThemeResult/shared assertion/Box/entry helpers unchanged from their actual run; sole I10 explicit viewport(Off) fixture correction verified byte-for-byte')
print('PASS normal builds actual0 and ten independent asserting selector exits actual1 with expected C-I assertion failures; initial infrastructure/compiler/no-viewport errors excluded')
print('FINAL_BINARY_SHA256 '+h((r/'tests/interaction_c/target/release/bin/main').read_bytes()))
print('RESOLVED_REQUIRES '+json.dumps(tomllib.loads((r/'tests/interaction_c/cjpm.lock').read_text())['requires'],sort_keys=True))

from pathlib import Path
import hashlib,json,subprocess
b=Path('/workspace/work/overlay-tests/export-turn-regressions');r=b/'replay';s=b/'source'
h=lambda data:hashlib.sha256(data).hexdigest()
git=lambda cwd,*a:subprocess.check_output(['git',*a],cwd=cwd)
j=json.loads((b/'raw/prehash.json').read_text())
assert git(r,'rev-parse','HEAD').decode().strip()==j['fixed_product']
assert git(s,'rev-parse','HEAD').decode().strip()==j['test_base']
for p,want in j['inputs_sha256'].items():assert h((r/p).read_bytes())==want,p
assert h(Path('/workspace/work/interaction-a-tests/final/env.sh').read_bytes())==j['env_sha256']
tracked=set(git(r,'ls-tree','-r','--name-only',j['fixed_product']).decode().splitlines())
product=[p for p in j['inputs_sha256'] if not p.startswith('tests/') and p in tracked]
for p in product:assert h(git(r,'show',j['fixed_product']+':'+p))==j['inputs_sha256'][p],p
assert not git(r,'diff','--name-only','--','src','native','build.cj','cjpm.toml').strip()
tests=git(s,'ls-files','tests/interaction_c').decode().splitlines()
for p in tests:assert (s/p).read_bytes()==(r/p).read_bytes(),p
allowed={'tests/interaction_c/README.md','tests/interaction_c/case-matrix.md','tests/interaction_c/golden.md','tests/interaction_c/src/export_turn_regressions.cj','tests/interaction_c/src/main.cj'}
assert set(git(s,'diff','--cached','--name-only').decode().splitlines())==allowed
assert not git(s,'diff','--name-only').strip()
subprocess.run(['git','diff','--cached','--check'],cwd=s,check=True)
records=json.loads((b/'raw/commands.json').read_text())
for name,expected in [('build',0),('pure-export',1),('open-turn',1)]:
 rows=[x for x in records if x['name']==name];assert len(rows)==1
 assert rows[0]['exit']==expected==int((b/'raw'/f'{name}.exit').read_text())
print(f'PASS unchanged replay prehash: {len(j["inputs_sha256"])} files; fixed-product tracked inputs: {len(product)}')
print(f'PASS source/replay equality: all {len(tests)} indexed formal test files, including admission metadata')
print('PASS five-file staged test-only delta, no unstaged source changes, diff whitespace check')
print('PASS original command/raw exit agreement: build=0; pure-export=1; open-turn=1')
print('REUSE existing normal build and separate behavioral runs under AGENTS 11.1; no compile/test repeated')
print('BINARY sha256='+h((r/'tests/interaction_c/target/release/bin/main').read_bytes()))
for argv in [['cjc','--version'],['cjpm','--version']]:
 result=subprocess.run(argv,text=True,capture_output=True);print('VERSION',argv,'exit='+str(result.returncode));print(result.stdout,end='');print(result.stderr,end='');assert result.returncode==0

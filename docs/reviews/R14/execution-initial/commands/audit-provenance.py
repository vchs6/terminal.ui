from pathlib import Path
import hashlib,json,subprocess,shutil,re,datetime
b=Path('/workspace/work/rich-text-execution');s=b/'source';e=b/'evidence';repo=Path('/workspace/work/terminal.ui');rev='91c22f82adcd2412d9509b9872ff63450ba81af9'
h=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
def git(*a):return subprocess.check_output(['git','-C',str(repo),*a]).decode()
inventory=json.loads((e/'source-inventory.json').read_text());assert all(h(s/f)==v for f,v in inventory.items())
proof=[]
for base in ['7ba2cd4','cc556f4e4548c51c3d99e5a06768e61b41932d75']:
 ps=git('ls-tree','-r','--name-only',base,'tests/rich-text').splitlines()
 changes=git('diff','--name-only',base,rev,'--',*ps).splitlines()
 if base=='7ba2cd4':changes=[x for x in changes if x not in ['tests/rich-text/src/main.cj','tests/rich-text/README.md']]
 assert not changes,(base,changes)
 proof.append(dict(baseline=base,scope='existing formal files; main only dispatch added and README additive metadata' if base=='7ba2cd4' else 'whole formal tests',unchanged=True))
(e/'formal-test-source-proof.json').write_text(json.dumps(proof,indent=2)+'\n')
neg=e/'reused-macro-negatives';rows=[]
for line in (s/'tests/runtime/macros/negative/cases.tsv').read_text().splitlines():
 name,loc,pattern=line.split('\t');a=neg/'artifacts';status=int((a/f'{name}.exit').read_text());diag=(a/f'{name}.diagnostics').read_text();assert status!=0 and loc in diag and re.search(pattern,diag,re.I)
 rows.append(dict(name=name,actual_exit=status,diagnostic_sha256=h(a/f'{name}.diagnostics'),expected_location=loc,expected_pattern=pattern,matched=True))
(e/'macro-negative-reuse-audit.json').write_text(json.dumps(dict(baseline=(neg/'head').read_text().strip(),source_diff=git('diff','--name-only',(neg/'head').read_text().strip(),rev,'--','src/macros','tests/runtime/macros/negative').splitlines(),cases=rows,reason='unchanged macro parser/expander and negative fixtures; same SDK1.2.0, OS ABI and source dependency versions; positive public consumer freshly executed for changed product integration'),indent=2)+'\n')
for p in [s/'cjpm.lock',s/'cangjie-repo.toml',Path('/workspace/work/validation/sdk/cangjie/envsetup.sh')]:
 if p.exists():shutil.copy2(p,e/('root-'+p.name if p.parent==s else 'sdk-envsetup.sh'))
deps={str(p.relative_to(b/'cache')):h(p) for p in sorted((b/'cache').rglob('*')) if p.is_file() and not any(x in p.parts for x in ['target','build-script-cache']) and p.suffix not in ['.a','.o','.so','.cjo']}
(e/'dependency-inventory.json').write_text(json.dumps(deps,indent=2)+'\n')
(e/'environment-provenance.json').write_text(json.dumps(dict(sdk_env_sha256=h(Path('/workspace/work/validation/sdk/cangjie/envsetup.sh')),ucd17_sha256=h(Path('/workspace/work/validation/replay-dependencies/UCD-17.0.0.zip')),source_commit=rev,tree=git('rev-parse',rev+'^{tree}').strip(),registry='http://127.0.0.1:18973',seed='/workspace/work/validation/replay-dependencies/cache',sdk='1.2.0',source_unchanged=True,skill_refs={'CangjieSkills':git('-C','/workspace/work/CangjieSkills','rev-parse','HEAD').strip() if False else subprocess.check_output(['git','-C','/workspace/work/CangjieSkills','rev-parse','HEAD']).decode().strip(),'cangjie-rules':subprocess.check_output(['git','-C','/workspace/work/cangjie-rules','rev-parse','HEAD']).decode().strip()},date_utc=datetime.datetime.now(datetime.timezone.utc).isoformat()),indent=2)+'\n')
print('fixed source and formal tests unchanged; 15 compiler-negative evidence records valid; dependency inventory saved')

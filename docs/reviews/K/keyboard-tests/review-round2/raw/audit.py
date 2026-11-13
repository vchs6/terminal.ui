from pathlib import Path
import hashlib,json,subprocess,datetime
b=Path(__file__).resolve().parent.parent;r=b/'replay';s=b/'source';raw=b/'raw';pre=json.loads((raw/'prehash.json').read_text());sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
inputs={k:sha(r/k) for k in pre['inputs_sha256']};assert inputs==pre['inputs_sha256']
deps={k:sha(Path(k)) for k in pre['external_dependencies_sdk_sha256']};assert deps==pre['external_dependencies_sdk_sha256']
paths=subprocess.check_output(['git','-C',str(r),'ls-tree','-r','--name-only','HEAD','src','native','scripts','build.cj','cjpm.toml','cangjie-repo.toml'],text=True).splitlines()
for k in paths:assert sha(r/k)==hashlib.sha256(subprocess.check_output(['git','-C',str(r),'show','HEAD:'+k])).hexdigest(),k
files={str(p.relative_to(s)):sha(p) for p in (s/'tests/keyboard/review_regressions').rglob('*') if p.is_file()};assert len(files)==7
for k,v in files.items():assert sha(r/k)==v,k
main='tests/keyboard/review_regressions/src/main.cj';original=subprocess.check_output(['git','-C',str(s),'show',pre['test_base']+':'+main]);assert (s/main).read_bytes().replace(b'else if(selected=="K115-R1-01"){roundTwo()}',b'')==original
for k,v in pre['old_other_test_files_sha256'].items():assert sha(s/k)==v
binary=r/'tests/keyboard/review_regressions/target/release/bin/main';bh=sha(binary)
for phase in ['pre','post']:assert json.loads((raw/('K115-R1-01.bin-'+phase+'.json')).read_text())['sha256']==bh
assert (raw/'build.exit').read_text().strip()=='0';assert (raw/'K115-R1-01.exit').read_text().strip()=='1';assert 'FAIL K115 K115-R1-01 oversized Alt remains isolated' in (raw/'K115-R1-01.stderr').read_text()
lines=(raw/'K115-R1-01.stdout').read_text().splitlines();assert len(lines)==8 and 'fixed timeout' in lines[-1];assert sum('bytewise=false' in x for x in lines)==6 and sum('bytewise=true' in x for x in lines)==1
sealed=Path('/workspace/work/keyboard-tests/review-round1/raw/manifest.json');assert sha(sealed)=='a50b8ad44f859f304061599a9af64542afabd3c1067d1cc46261c13ee28d8c2a'
post={'utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'inputs_sha256':inputs,'external_dependencies_sdk_sha256':deps,'test_files_sha256':files,'product_fixed_blob_checks':len(paths),'final_binary_sha256':bh,'old_functions_helpers_and_other_test_files_unchanged':True,'prior_sealed_manifest_sha256':sha(sealed),'resolved_lock_sha256':{str(p.relative_to(r)):sha(p) for p in r.rglob('cjpm.lock')}}
(raw/'posthash.json').write_text(json.dumps(post,indent=2)+'\n');print('AUDIT PASS',len(paths),'product',len(deps),'SDK/deps',len(files),'test files; bin',bh)

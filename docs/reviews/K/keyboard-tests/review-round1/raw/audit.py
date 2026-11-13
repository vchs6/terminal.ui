from pathlib import Path
import hashlib,json,subprocess,ast,datetime
b=Path(__file__).resolve().parent.parent;r=b/'replay';s=b/'source';raw=b/'raw';pre=json.loads((raw/'prehash.json').read_text());sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
inputs={k:sha(r/k) for k in pre['inputs_sha256']};assert inputs==pre['inputs_sha256']
deps={k:sha(Path(k)) for k in pre['external_dependencies_sdk_sha256']};assert deps==pre['external_dependencies_sdk_sha256']
paths=subprocess.check_output(['git','-C',str(r),'ls-tree','-r','--name-only','HEAD','src','native','scripts','build.cj','cjpm.toml','cangjie-repo.toml'],text=True).splitlines()
for k in paths:assert sha(r/k)==hashlib.sha256(subprocess.check_output(['git','-C',str(r),'show','HEAD:'+k])).hexdigest(),k
files={str(p.relative_to(s)):sha(p) for p in (s/'tests/keyboard/review_regressions').rglob('*') if p.is_file()};assert len(files)==6
for k,v in files.items():assert sha(r/k)==v,k
binary=r/'tests/keyboard/review_regressions/target/release/bin/main';bh=sha(binary)
for case in ['K115-01','K115-02','K115-03','K115-04','K115-05']:
 assert (raw/(case+'.exit')).read_text().strip()=='1'
 for phase in ['pre','post']:assert json.loads((raw/(case+'.bin-'+phase+'.json')).read_text())['sha256']==bh
 if case!='K115-05':assert 'FAIL K115 '+case in (raw/(case+'.stderr')).read_text()
assert (raw/'build.exit').read_text().strip()=='0'
m=json.loads((raw/'native-capture/metadata.json').read_text());assert m['actual_binary_exit']==1 and m['classification']=='actual-native-assertion-RED' and not m.get('forced',False);assert m['before_termios']==m['after_termios'];assert m['binary_pre_sha256']==m['binary_post_sha256']==bh
assert m['summary']=={'issues':'1','x':'0','caught':'true','message':'session is inactive','cleanup':'1','released':'true'}
assert (raw/'native-capture/input.raw').read_bytes()==bytes([0xe4,120]);assert (raw/'native-capture/issue').read_text()=='InvalidUtf8@0;count=1'
ast.parse((s/'tests/keyboard/review_regressions/native_pty.py').read_text());subprocess.run(['bash','-n',str(s/'tests/keyboard/review_regressions/run.sh')],check=True)
proof=json.loads((raw/'K115-06-proof-references.json').read_text())
for k,v in proof['sha256'].items():assert sha(Path(k))==v,k
assert sha(Path('/workspace/work/keyboard-review/findings.json'))==pre['finding_sha256']
sealed={'/workspace/work/keyboard-tests/i015-stage/raw/manifest.json':'d641028cc687e5072dd8ad9242c67f8518c6eb08a310f58eb6a70bb8250e4fcf','/workspace/work/keyboard-tests/paste-argument-regression/raw/manifest.json':'6a02cf92aafea606299310ee84bee0096440aac0e8d17791c709015f5ad8d3ff'}
for k,v in sealed.items():assert sha(Path(k))==v,k
locks={str(p.relative_to(r)):sha(p) for p in r.rglob('cjpm.lock')}
post={'utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'inputs_sha256':inputs,'external_dependencies_sdk_sha256':deps,'test_files_sha256':files,'product_fixed_blob_checks':len(paths),'final_binary_sha256':bh,'resolved_lock_sha256':locks,'sealed_previous_manifest_sha256':sealed,'native_true_child_exit':m['actual_binary_exit'],'native_termios_restored':True,'native_summary':m['summary'],'static_shell_python':'PASS'}
(raw/'posthash.json').write_text(json.dumps(post,indent=2)+'\n');print('AUDIT PASS',len(paths),'fixed product files',len(deps),'SDK/deps',len(files),'new test files','bin',bh)

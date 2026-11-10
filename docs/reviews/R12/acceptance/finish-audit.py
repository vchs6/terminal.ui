from pathlib import Path
import json,hashlib,subprocess,re
root=Path('/workspace/work/terminal.ui');out=Path('/workspace/work/runtime-acceptance');ex=Path('/workspace/work/runtime-execution/r12-execution-draft')
def git(*args):return subprocess.check_output(['git','-C',str(root),*args])
def sha(b):return hashlib.sha256(b).hexdigest()
def dump(p,x):(out/p).write_text(json.dumps(x,indent=2,ensure_ascii=False)+'\n')
candidate=git('rev-parse','0912436').decode().strip();test=git('rev-parse','6d703bf').decode().strip();contract=git('rev-parse','fc766733').decode().strip()
paths=['src','native','build.cj','cjpm.toml','examples/reactive','docs/product']
product={p:sha(git('show',candidate+':'+p)) for p in git('ls-tree','-r','--name-only',candidate,'--',*paths).decode().splitlines()}
testpaths=['tests/runtime','tests/resize-coherence','tests/support','tests/application-lifecycle','tests/integration']
tests={p:sha(git('show',test+':'+p)) for p in git('ls-tree','-r','--name-only',test,'--',*testpaths).decode().splitlines()}
assert not git('diff','dddbdd9',test,'--',*testpaths)
assert not git('diff',contract,'HEAD','--','openspec/changes/implement-reactive-runtime/design.md')
# Verify all 161 manifest entries against the precise original R019 freeze.
manifest=root/'docs/reviews/R12/test-supplements/raw/r019-test-source.sha256';count=0
for line in manifest.read_text().splitlines():
 h,p=line.split(None,1);assert sha(git('show','0912436:'+p))==h,p;count+=1
assert count==161
# Independently verify 15 compiler negative diagnostics.
art=ex/'evidence/c3/reused-macro-negatives/artifacts';cases=[]
for line in (root/'tests/runtime/macros/negative/cases.tsv').read_text().splitlines():
 name,loc,pattern=line.split('\t');s=(art/(name+'.diagnostics')).read_text();code=int((art/(name+'.exit')).read_text());assert code!=0 and loc in s and re.search(pattern,s,re.I)
 assert not re.search('failed to (resolve|download)|connection refused|undefined reference',s,re.I)
 cases.append({'fixture':name,'exit':code,'location':loc,'diagnostic_sha256':sha(s.encode())})
dump('raw/macro-negative-content-audit.json',cases)
# TDD is actual old product RED; declaration-only checks have no execution role.
red=root/'docs/reviews/R12/test-design/raw';redrows=[]
for name,want in [('baseline-build',0),('core-final-public-api-red',1),('macro-positive-red',1),('session-red',1)]:
 assert int((red/(name+'.exit')).read_text())==want;redrows.append({'prefix':str(red/name),'exit':want,'command_sha256':sha((red/(name+'.command')).read_bytes()),'stderr_sha256':sha((red/(name+'.stderr')).read_bytes())})
assert 'Observable' in (red/'core-final-public-api-red.stderr').read_text()
dump('raw/tdd-provenance-audit.json',{'actual_old_product_records':redrows,'declaration_only_scratch':'static syntax only; never executed or counted as product GREEN','r019_frozen_test_manifest_count':count,'r019_frozen_test_manifest_sha256':sha(manifest.read_bytes())})
# Metadata validity and direct source version correspondence.
invalid=[];n=0
for p in ex.rglob('*.json'):
 n+=1
 try:json.loads(p.read_text())
 except json.JSONDecodeError as e:invalid.append({'path':str(p.relative_to(ex)),'error':str(e)})
assert len(invalid)==1
orig=ex/'evidence/c3/gui-reactive/xfce-vte/interrupt/metadata.json';legacy=json.loads(orig.read_text(),strict=False);projection=json.loads((out/'metadata/xfce-vte-metadata.normalized.json').read_text());assert projection==legacy
version=orig.parent/'host-version.txt';assert version.read_text().replace('\n',' ')==projection['host_version']
# CPU remains one tick, no absolute zero claim.
cpu=json.loads((ex/'evidence/c3/cjtui-runtime-pty-qFhn8c/idle-cpu/idle-cpu.json').read_text());assert cpu['cpuSeconds']==(cpu['after']['user']-cpu['before']['user']+cpu['after']['system']-cpu['before']['system'])/cpu['ticksPerSecond'];assert cpu['absolutePassThreshold'] is None
# GUI exact saved termios on both real implementations.
for host in ['xterm-default','xfce-vte']:
 p=ex/'evidence/c3/gui-reactive'/host/'interrupt/inner-tty.txt';vals=dict(l.split('=',1) for l in p.read_text().splitlines() if '=' in l);assert vals['ready_termios']==vals['exit_termios'];assert vals['exit_status']=='0'
reviewed={'schema':'cjtui-R12-acceptance-hashes-v1','candidate':candidate,'baseline':git('rev-parse','6a7b240').decode().strip(),'c3_reuse':git('rev-parse','c3d743d').decode().strip(),'tests_through':test,'executor_tests':git('rev-parse','dddbdd9').decode().strip(),'contract':contract,'contract_sha256':sha(git('show',contract+':openspec/changes/implement-reactive-runtime/design.md')),'product_version':'0.0.0','sdk_version':'1.2.0','normal_cjp_sha256':sha(Path('/workspace/work/runtime-execution/r019-source/target/cjtui-0.0.0.cjp').read_bytes()),'executor_manifest_sha256':sha((ex/'artifacts.sha256').read_bytes()),'product_files':product,'finite_test_files':tests,'metadata_original_sha256':sha(orig.read_bytes()),'metadata_normalized_sha256':sha((out/'metadata/xfce-vte-metadata.normalized.json').read_bytes())}
dump('reviewed-hashes.json',reviewed)
dump('raw/final-verification.json',{'finite_contract_evidence':'verified','product_source_files_hashed':len(product),'finite_test_files_hashed':len(tests),'r019_frozen_manifest':count,'negative_diagnostics':len(cases),'archived_json_files':n,'invalid_original_json':invalid,'normalized_json_strict_parse':True,'normalized_values_identical':True,'host_version_matches_original_text':True,'actual_gui_termios_equal':True,'cpu_raw_arithmetic_verified':True,'product_suites_rerun':False,'metadata_projection_integration':'pending root mechanical copy/state mapping'})
print(json.dumps({'product_files':len(product),'test_files':len(tests),'r019_manifest':count,'negative_cases':len(cases),'metadata_projection_verified':True}))

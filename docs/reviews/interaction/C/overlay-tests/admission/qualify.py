from pathlib import Path
import json,hashlib,subprocess
base=Path(__file__).parent;source=base/'source';raw=base/'raw';prep=base.parent/'final-preparation';h=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
m=json.loads((source/'docs/reviews/interaction/admission/interface-map-C.json').read_text());pm=json.loads((prep/'raw/manifest.json').read_text());pre=json.loads((prep/'raw/final-prehash.json').read_text());oldB=json.loads(Path('/workspace/work/viewport-tests/admission/applicability.json').read_text())
assert h(prep/'raw/manifest.json')==m['prepare_manifest_sha256'];assert h(prep/'declarations/raw/manifest.json')==m['declaration_language_manifest_sha256']
allowed_metadata={'tests/interaction_c/README.md','tests/interaction_c/run.sh','tests/interaction_c/gate-selftest.sh'}
compared=[];metadata_changed=[]
for path,want in pre['runtime_inputs_sha256'].items():
 if path in allowed_metadata:
  if h(source/path)!=want:metadata_changed.append(path)
  continue
 assert (source/path).is_file(),path
 assert h(source/path)==want,path
 compared.append(path)
assert set(metadata_changed)==allowed_metadata
owners=[]
for owner in m['owners']:
 assert h(source/owner['path'])==owner['sha256'],owner['path']
 owners.append(owner['path'])
assert subprocess.check_output(['git','rev-parse','HEAD:src'],cwd=source,text=True).strip()==m['source_tree']
contract=subprocess.check_output(['git','show','HEAD:openspec/changes/implement-public-interaction/design.md'],cwd=source)
assert hashlib.sha256(contract).hexdigest()==m['canonical_design_sha256']
# The historical declarations remain separate and unchanged, never formal deps.
dpre=json.loads((prep/'declarations/raw/final-prehash.json').read_text())
for path,want in dpre['inputs_sha256'].items():assert h(prep/path)==want,path
sdk=oldB['SDK_tool_checks_equal_A_accepted_pre_environment']
for path,want in sdk.items():assert h(Path(path))==want,path
assert h(Path(pre['env']['path']))==pre['env']['sha256']
depsbase=Path('/workspace/work/viewport-tests/cache');depfile=Path(oldB['dependencies_now_match_A_accepted_baseline']['baseline']);dephashes=json.loads(depfile.read_text())
assert h(depfile)==oldB['dependencies_now_match_A_accepted_baseline']['sha256']
for row in dephashes:assert h(depsbase/row['path'])==row['sha256'],row['path']
stdxbase=Path('/workspace/work/linux-build-recon/stdx-env/linux_x86_64_llvm').resolve();stdxfile=Path(oldB['stdx_now_match_accepted_baseline']['baseline']);stdx=json.loads(stdxfile.read_text())
assert h(stdxfile)==oldB['stdx_now_match_accepted_baseline']['sha256']
for path,want in stdx.items():assert h(stdxbase/path)==want,path
ucd=Path('/workspace/work/validation/replay-dependencies/UCD-17.0.0.zip');assert h(ucd)==oldB['UCD_equal']
# Prove every new actual current gate using HEAD ancestry and existing real proof.
gates=[]
for row in (source/'tests/interaction_c/admission.current.tsv').read_text().splitlines()[1:]:
 gate,status,sha,evidence=row.split('\t');assert status=='ACCEPTED' and len(sha)==40
 subprocess.run(['git','cat-file','-e',sha+'^{commit}'],cwd=source,check=True)
 subprocess.run(['git','merge-base','--is-ancestor',sha,'HEAD'],cwd=source,check=True)
 assert (source/evidence).is_file(),evidence
 gates.append({'gate':gate,'source_sha':sha,'ancestor':True,'evidence':evidence,'evidence_sha256':h(source/evidence)})
assert len(gates)==8 and len({g['gate'] for g in gates})==8
for rel,want in pm['raw_sha256'].items():assert h(prep/'raw'/rel)==want,rel
result={'accepted_B_original':m['accepted_product_original'],'accepted_B_integrated':m['accepted_product_integrated'],'current_base':subprocess.check_output(['git','rev-parse','HEAD'],cwd=source,text=True).strip(),'frozen_consumer':m['fixed_tests'],'contract_sha256':m['canonical_design_sha256'],'source_tree':m['source_tree'],'prep_manifest_sha256':m['prepare_manifest_sha256'],'language_manifest_sha256':m['declaration_language_manifest_sha256'],'unchanged_prior_runtime_input_count':len(compared),'only_existing_metadata_changes':metadata_changed,'15_controller_owner_hashes_equal':owners,'current_gates':gates,'sdk_tools_sha256':sdk,'environment_script_equal':True,'shared_dependency_baseline':{'path':str(depfile),'sha256':h(depfile),'count':len(dephashes),'all_equal':True},'shared_stdx_baseline':{'path':str(stdxfile),'sha256':h(stdxfile),'count':len(stdx),'all_equal':True},'UCD_sha256':h(ucd),'declaration_probe_inputs_unchanged':True,'original_prep_raw_unchanged':True,'reused_actual_results':{'positive_build':0,'positive_direct':0,'missing_C_compile_exit':1,'missing_C_direct_diagnostics':87,'missing_C_cascades':39,'language_only_compile':0,'language_only_execution_count':0},'formal108_test_freeze':True,'C_behavior':'UNEXECUTED','C_product_or_body_typecheck':'not proved; actual C implementation absent','no_product_rerun':True,'reason':'Only admission metadata/driver controls changed; consumed source, C bodies/manifests/goldens, SDK, dependencies, configs, env and scope match earlier actual results per AGENTS11.1.'}
(base/'applicability.json').write_text(json.dumps(result,indent=2)+'\n')
print('QUALIFIED',len(compared),'unchanged runtime inputs;',len(owners),'owner hashes;',len(dephashes),'dependency files;',len(stdx),'stdx files; SDK/env/config/UCD equal;8 gates actual ancestors/proofs. No product rerun.')

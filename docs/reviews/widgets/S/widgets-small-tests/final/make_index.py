import hashlib,json,pathlib,subprocess
base=pathlib.Path('/workspace/work/widgets-small-tests/final');root=base/'source';ev=base/'evidence'
sha=lambda p:hashlib.sha256(pathlib.Path(p).read_bytes()).hexdigest()
def entry(p):
 p=pathlib.Path(p);return {'path':str(p),'sha256':sha(p),'bytes':p.stat().st_size}
def git(*args):return subprocess.check_output(['git',*args],cwd=root,text=True).strip()
commit=git('rev-parse','HEAD');baseline='8053274ad8bb7b40d35f36eac80f07745531c729'
assert commit=='5413dc768a93b3e3f172227161bc9d8545993508'
assert not git('status','--porcelain')
changed=git('diff','--name-only',baseline,commit).splitlines();assert all(p.startswith('tests/widgets_small/') for p in changed)
product_paths=git('ls-tree','-r','--name-only',baseline,'--','src','native','build.cj','cjpm.toml').splitlines()
product={p:entry(root/p) for p in product_paths}
for p in product_paths:
 assert subprocess.check_output(['git','show',baseline+':'+p],cwd=root)==(root/p).read_bytes()
test_paths=git('ls-files','tests/widgets_small').splitlines();tests={p:entry(root/p) for p in test_paths}
commands=json.loads((ev/'commands.json').read_text())
for row in commands:
 for raw in row['raw'].values():assert sha(raw['path'])==raw['sha256']
contract=['AGENTS.md','docs/development/cangjie-conventions.md','openspec/changes/implement-standard-widgets/design.md','openspec/changes/implement-standard-widgets/specs/standard-widgets/spec.md','openspec/changes/implement-standard-widgets/tasks.md']
inputs={p:entry(root/p) for p in contract}
inputs['frozen_input_manifest']=entry(ev/'frozen-input-manifest.json')
inputs['brief']=entry('/workspace/work/terminal.ui/.superpowers/sdd/tasks-implement-standard-widgets/task-153-final-brief.md')
inputs['historical_preparation_report']=entry('/workspace/work/widgets-small-tests/report.md')
sdkpaths=['/workspace/work/validation/sdk/cangjie/envsetup.sh','/workspace/work/validation/sdk/cangjie/bin/cjc','/workspace/work/validation/sdk/cangjie/bin/cjc-frontend','/workspace/work/validation/sdk/cangjie/tools/bin/cjpm','/workspace/work/validation/replay-dependencies/UCD-17.0.0.zip']
metadata={
 'task':'TASK-153','status':'FROZEN_TEST_DELIVERY_EXPECTED_TARGET_RED','test_commit':commit,'source_baseline':baseline,
 'accepted_product_reference':'b71cb2eb / E22ca byte-equal (frozen manifest is authority)',
 'role':{'kind':'independent test author','assigned_model':'Sol/high','serving_model_attestation':'not available from tools','no_author_contact':True},
 'workdir':str(root),'allowed_changes':'tests/widgets_small/**','changed_files':changed,
 'inputs':inputs,'product_files':product,'test_files':tests,
 'sdk':{'compiler':'1.2.0 cjnative x86_64-unknown-linux-gnu','cjpm':'1.2.0','files':[entry(p) for p in sdkpaths],
        'stdx_path':'/workspace/work/linux-build-recon/stdx-env','cache_path':'/workspace/work/viewport-tests/cache','registry':'https://pkg.cangjie-lang.cn/registry','sdk_cache_copies':False},
 'registry_configs':[entry(p) for p in [root/'cangjie-repo.toml',*(m.parent/'cangjie-repo.toml' for m in (root/'tests/widgets_small').rglob('cjpm.toml') if '/target/' not in str(m))]],
 'resolved_dependencies':entry(ev/'prerequisite-dependencies.lock'),
 'prerequisite_binary':entry(root/'tests/widgets_small/prerequisite/target/release/bin/main'),
 'commands':commands,
 'skills':[{'name':n,'resource':u,'read':True,'version_note':'cloud package content read through skills tool; no immutable cloud revision exposed'} for n,u in [
 ('test-driven-development','skill://plugins~Plugin_60aea7460bd4819199fd97a9553a5e12/test-driven-development/SKILL.md'),
 ('verification-before-completion','skill://plugins~Plugin_60aea7460bd4819199fd97a9553a5e12/verification-before-completion/SKILL.md'),
 ('systematic-debugging','skill://plugins~Plugin_60aea7460bd4819199fd97a9553a5e12/systematic-debugging/SKILL.md'),
 ('cloud-environment-runtime','skill://plugin_connector_1p_c5b7d5df5d7081918f2c4be5a633ed5d/cloud-environment-runtime/SKILL.md')]],
 'language_references':[entry('/workspace/work/CangjieSkills/SKILL'),entry('/workspace/work/cangjie-rules/SKILL.md')],
 'reference_revisions':{'CangjieSkills':'277f2e1234ca5217496966887243c679653887a8','cangjie-rules':'40bacab1dafc7c5710a9b14c5c5c86898feed63c'},
 'binding_notes':[
 'Prerequisite fixture initial direct1 is setup-only; corrected constructor-in-block source then clean build0/direct0. No target conclusion is based on setup failure.',
 'All five minimal RED consumer files/manifests and product inputs are unchanged since their recorded individual builds. Final headless/device files are unchanged since final parser checks.',
 'During normal-run only the later, unreached Bool diagnostic-classification branch was tightened; prerequisite/build/target-import paths and all compiled sources were unchanged. That negative stage has no execution claim; final script syntax was checked after its change.',
 'No imported target exists, so full-body target type checking, overload acceptance, behavioral/PTY/bundle/negative-signature proofs are pending; formatter and tool checks are not those proofs.',
 'Public Progress subscription cardinality is partial readset evidence. Future independent product review must check fraction absent from measure closure; M1 measures may increase.'
 ],
 'not_claimed':['S behavioral acceptance','full target body typecheck','PTY product pass','native restoration pass','Bool constructor rejection','clean-bundle execution','TASK154 complete','M complete','Linux complete'],
 'report':entry(base/'report.md'),
 'artifacts':[entry(p) for p in sorted(ev.rglob('*')) if p.is_file() and p.name!='index.json']
}
(ev/'index.json').write_text(json.dumps(metadata,ensure_ascii=False,indent=2)+'\n')
print('test_sha='+commit)
print('report_sha256='+sha(base/'report.md'))
print('index_sha256='+sha(ev/'index.json'))
print('product_files='+str(len(product))+' test_files='+str(len(tests))+' commands='+str(len(commands)))

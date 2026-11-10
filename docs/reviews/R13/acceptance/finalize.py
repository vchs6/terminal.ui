from pathlib import Path
import json,hashlib,re,datetime,subprocess
B=Path('/workspace/work/dynamic-acceptance');reviewed=json.loads((B/'reviewed-hashes.json').read_text())
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def readhash(p):reviewed[str(p)]=sha(p)
E=Path('/workspace/work/dynamic-execution');S=E/'source'
for p in [E/'commands/gui-dynamic.sh',E/'commands/gui-metadata.py',E/'commands/prepare-clean.py',S/'scripts/check-bundle.mjs']:readhash(p)
for profile in ['xterm-default','xfce-vte']:
 m=json.loads((E/'evidence/gui-dynamic'/profile/'q/metadata.json').read_text())
 tdir=S/'tests/terminals'
 names=['run.sh','verify-sgr.mjs','verify-exit.mjs','outer-recorder.sh','inner-recorder.sh','x11-xtest-interrupt.c','wait-output.mjs','wait-fence.mjs']
 inputs=''.join(f'{sha(tdir/n)}  {tdir/n}\n' for n in names).encode()
 assert hashlib.sha256(inputs).hexdigest()==m['harness_source_sha256']
 for n in names:readhash(tdir/n)
# Report refs and original raw conclusions, without any test execution.
for p in B.rglob('*.json'):json.loads(p.read_text(),parse_constant=lambda s: (_ for _ in ()).throw(ValueError(s)))
for dest in re.findall(r'\]\(([^)]+)\)',(B/'report.md').read_text()):assert (B/dest).exists(),dest
for label in ['audit','supplement']:assert not (B/f'raw/{label}.stderr').read_text()
assert subprocess.check_output(['git','-C',str(S),'diff','HEAD','--'])==b''
# Source-level inspected test files already inventory-hashed; hash current contract/read files too.
for p in [Path('/workspace/work/terminal.ui/openspec/changes/implement-reactive-runtime/design.md'),Path('/workspace/work/terminal.ui/docs/acceptance.md')]:readhash(p)
(B/'reviewed-hashes.json').write_text(json.dumps(reviewed,indent=2)+'\n')
result={'utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'audit_exit':0,'supplement_exit':0,'json_valid':True,'report_links_valid':True,'harness_hashes_equal':True,'source_tracked_diff_empty':True,'metadata_fields_changed_per_host':['artifacts.xorg.log','artifacts.xorg.stdout'],'product_suites_rerun':False}
(B/'raw/final-verification.json').write_text(json.dumps(result,indent=2)+'\n')
(B/'scope.json').write_text(json.dumps({'task':'TASK-080','destination':'docs/reviews/R13/acceptance','source':'216b2ab5f2315f4be19467b7e49f4047aec78ab9','execution_destination':'docs/reviews/R13/execution','verdict':'PASS_FINITE','metadata':'Two final artifact-hash projections; preserve and link original E metadata.','copy':'Copy this directory contents mechanically; no product binaries/caches/source trees. External original paths remain provenance references.','status_projection':'AC076–080 limited PASS; original015/016/032 original-scope passed; 014/018 and broader Linux remain pending; continue RichText.'},indent=2)+'\n')
files=[p for p in B.rglob('*') if p.is_file() and p.name!='artifacts.sha256']
for p in files:assert not p.read_bytes().startswith(b'\x7fELF')
(B/'artifacts.sha256').write_text(''.join(f'{sha(p)}  {p.relative_to(B)}\n' for p in sorted(files)))
print(json.dumps(dict(result,artifact_files=len(files),reviewed_files=len(reviewed)),indent=2))

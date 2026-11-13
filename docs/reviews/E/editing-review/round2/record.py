import pathlib,json,hashlib,subprocess
out=pathlib.Path('/workspace/work/editing-review'); r=out/'round2'; source=pathlib.Path('/workspace/work/editing-implementation/source')
base='043523cdb07d4de542174022dddfa5ed715b560d'; head='22ca8cf7c756c5185064a6f8bc7e9f2c58d4f167'
lookup_path=pathlib.Path('/workspace/work/terminal.ui/.superpowers/sdd/tasks-implement-linux-input-editing/task-120-r1-raw-index.json')
lookup=json.loads(lookup_path.read_text())
assert lookup['fixed_product_commit']==head
assert subprocess.check_output(['git','rev-parse','HEAD'],cwd=source,text=True).strip()==head
assert subprocess.check_output(['git','diff','--name-only','HEAD'],cwd=source,text=True)==''
(r/'source-state.txt').write_text(subprocess.check_output(['git','rev-parse','HEAD'],cwd=source,text=True)+subprocess.check_output(['git','status','--porcelain'],cwd=source,text=True))
(r/'fix.diff').write_bytes(subprocess.check_output(['git','diff','--unified=10',base,head],cwd=source))
(r/'commits.txt').write_bytes(subprocess.check_output(['git','log','--oneline',base+'..'+head],cwd=source))
selected=[]
for phase,names in {'fix1-editing':['command.txt','exit','stdout','stderr','source-commit','input.sha256','input-post-check','binary.sha256','test-equivalence.txt'], 'fix1-runtime':['command.txt','exit','stdout','stderr','source-commit'], 'fix1-lint':['exit','severity-counts.json'], 'fix1-lint-plain':['exit','severity-counts.json']}.items():
 for name in names:
  p=pathlib.Path('/workspace/work/editing-implementation/raw')/phase/name
  data=p.read_bytes(); digest=hashlib.sha256(data).hexdigest()
  assert lookup['raw_sha256'].get(str(p))==digest,str(p)
  dest=r/'raw'/phase/name;dest.parent.mkdir(parents=True,exist_ok=True);dest.write_bytes(data)
  selected.append({'origin':str(p),'copy':str(dest.relative_to(r)),'sha256':digest,'root_digest_verified':True})
# Bind the three changed product files directly to the executed input manifest.
manifest=(r/'raw/fix1-editing/input.sha256').read_text().splitlines()
checked={}
for relative in ['src/binding.cj','src/text_edit_session.cj','src/text_editing.cj']:
 p=source/relative; digest=hashlib.sha256(p.read_bytes()).hexdigest()
 candidates=[row for row in manifest if row.endswith('  '+relative) or row.endswith('/'+relative)]
 assert any(row.split()[0]==digest for row in candidates),(relative,candidates)
 checked[relative]=digest
 dest=r/'fixed-source'/relative;dest.parent.mkdir(parents=True,exist_ok=True);dest.write_bytes(p.read_bytes())
proofs={
 'E120-I01': {
  'result':'ADDRESSED',
  'source':'text_edit_session.cj:105–137 publishes text/token/revisions/history before signalPending; editing-source getter uses sync(deferSignal:true); text_editing.cj:133–142 installs the sole framework-owned afterEvaluate handler. binding.cj:55–58 invokes it only after track succeeds; trackSeeded restores the evaluation guard at86–88, completes subscriptions89–91, and releases ownerLock92–99 before returning.',
  'ordering':'If a consumer was already evaluated, signal.notify queues it again with committed state; if later in the ready batch, it sees committed state. Same-version sync returns without a new signal, so the added pass stabilizes. Snapshot remains a query. Getter failure skips the hook and propagates to existing runtime failure cleanup. The hook calls only signal invalidation, not user code. Disposal and intrinsic owner clearing remain unchanged; no hook is invoked by dispose.',
  'execution':'fix1-editing stdout: controller=Z@1, getter=Z@1 and full grid Z / Z@1; selector PASS. Runtime core receipt exit0 retains getter guards and cleanup/failure behavior.'},
 'E120-I02': {
  'result':'ADDRESSED',
  'source':'text_editing.cj:15–27 shares validation with mounted TextEditSession.validate. Both measure and draw choose committed edit state when mounted, otherwise read/validate the Observable and draw with TextSelection(0,0). All text/selection/LF/caret painting remains in the same Canvas callback. No intrinsic mount or controller attachment is added to temporary Runtime.',
  'ordering':'Detached measure/draw only read source and local values; illegal initial LF/CR/control/size rejects via the same validator. Existing Runtime temporary mode still suppresses effects and public references. A real later mount creates fresh revision0/selection0 state.',
  'execution':'fix1-editing stdout: input abc and area a/LF/b expected grids, mounts=0 cleanup=0 detachedBefore=true detachedAfter=true; selector PASS.'},
 'E120-I03': {
  'result':'ADDRESSED',
  'source':'text_edit_session.cj:525–533 performs the expected-version history commit, returns unchanged on failure, then clears preferredColumn before publishing the restored source/text/selection and changed()/onChange. Both undo and redo use this single history method.',
  'execution':'fix1-editing stdout: undo restored1/down4 and redo restored2/down6; both independent histories passed.'},
 'E120-I04': {
  'result':'ADDRESSED',
  'source':'handle300–301 syncs once and captures expectedVersion. Text/paste and TextArea Enter carry it through keyboardInput304/316→replace297; deletion computes its range against the same local state and passes preparedVersion405. In replace151–153, prepared callers bypass the source-refresh branch154–165. No callback/pump/local synchronization runs between captured state and candidate calculation; permitted background writes alter only Observable. commit224 passes the captured version to the unchanged sole-lock conditional write.',
  'old_counterexample':'After handle reads ax/v, a worker sets YZ/v+1. The fix still calculates the old deletion result x, but editingCommit(v,x) sees v+1 and returns None; commit then syncs latest YZ and emits the sole ConcurrentValueChanged. It cannot change expectedVersion to v+1 or commit Z as the old implementation did.',
  'rejection_and_noop':'Keyboard control/multiline/byte prevalidation uses the same frozen local text/selection and rejection returns before candidate publication; replace does not resync to a larger value after size validation. Same-text prepared/guarded paths check actual source version before selection-only publication; a mismatch returns false (prepared path synchronizes the external value) without applying the old selection, no text write/history/onChange. Guarded controller replacements retain normal identity/revision/actual-source checks. No implicit retry is added.',
  'race_attribution':'Only text_edit_session145 emits ConcurrentValueChanged, following editingCommit(expectedVersion,next)==None. Observable.cj lock/value/version/atomic snapshot and conditional helper are unchanged. Actual fix1-editing output has both original conflict and I04 selector conflict with zero edits, finalYZ and no history. These establish observed conflicts, not which internal pre-commit interval was hit.',
  'limitation':'The specific early planning window is not forced by the public fixture. Closure of that source-proven original finding rests on the explicit version/data-flow proof above; no exact-window execution is claimed.'}}
findings=json.loads((out/'round1/findings.json').read_text())
for f in findings:
 f['status']='verified';f['fix_revision']=head
 f['verification']={'round_id':'E120-R2','fix_round':1,'revision':head,'result':'ADDRESSED','proof':proofs[f['id']],'evidence_refs':['round2/fix.diff','round2/fixed-source/src/binding.cj','round2/fixed-source/src/text_edit_session.cj','round2/fixed-source/src/text_editing.cj','round2/raw/fix1-editing/stdout','round2/raw/fix1-runtime/stdout']}
 f['spec_verdict']='pass_source_review_after_fix';f['quality_verdict']='pass_source_review_after_fix'
for p in [out/'findings.json',r/'findings.json']:p.write_text(json.dumps(findings,ensure_ascii=False,indent=2)+'\n')
report='''TASK120 fix round1 / evidence round2 — spec PASS_FINITE_SOURCE; quality PASS_FINITE_SOURCE.
Reviewed fix range 043523cdb07d4de542174022dddfa5ed715b560d..22ca8cf7c756c5185064a6f8bc7e9f2c58d4f167; tracked source clean, generated untracked cjpm.lock files recorded.
All four original findings are ADDRESSED; no new required defect found in this fix diff. This closes the initial full source review without repeating it.
I01: committed external sync now schedules snapshot invalidation after the source binding's evaluation guard, subscriptions and locks finish; observed controller/getter/frame all Z@1.
The new private Binding.afterEvaluate hook has one editor-source consumer, runs only after successful track(), calls no user code, and leaves disposal/failure propagation and snapshot purity intact.
I02: detached measure/draw reads validated source through the same Canvas path with empty local selection; observed TextInput/TextArea grids correct, handles absent and lifecycle counts zero.
I03: successful undo and redo clear preferredColumn before publication; observed restored1→Down4 and restored2→Down6.
I04: handle captures one source token after sync; text/paste/Enter/deletion preparation carries it into replace without refresh, and the final CAS uses that token. Old deletion intent cannot rebase onto a newer source.
Keyboard rejection uses the same local state; guarded/prepared same-text paths check actual version before selection-only publication. No rejected operation writes text/history or invokes onChange.
I04's precise early planning window remains unforced at runtime; closure uses the explicit source-flow proof in index.json, not a timing/non-hit claim.
Retained fix1-editing command exited0: original public suite, all eight PTY vectors and four review selectors. The I04 selector observed one conflict, no edit, finalYZ and empty history.
The original race also has actual ConcurrentValueChanged; the only production emitter still follows the existing sole-lock conditional-write failure. No fake source, setter or Applied producer was introduced.
Retained Runtime core exited0; JSON/default lint exited0 with no ERROR/MANDATORY and 767 suggestions/warnings. These are finite receipts, not a lint-clean or whole-product claim.
Changed product files were matched to the executed input manifest; copied receipts match the root's pure raw digests. No author report/proof notes/excerpts were read.
No cold suites or additional probes were run; valid fixed receipts were reused under AGENTS11.1. No product/test/spec/main edits or role cross-contact.
Original unchanged source-review conclusions and limits carry forward: UInt64 exhaustion is source proof only; actual Applied unavailable; normal bundle/clean consumer/actual hosts remain TASK121, finite acceptance TASK122.
B-M01 stays deferred TASK024; T087-G01 wholechecker remains pending TASK023. This is not whole Linux, parent-AC or release acceptance.
Details: findings.json; immutable round2/index.json, fixed-source, raw and SHA256SUMS. Fix round1 of at most5 consumed.
'''
for p in [out/'report.md',r/'report.md']:p.write_text(report)
index={'round':'E120-R2','fix_round':1,'base':base,'head':head,'scope':'Original I01–I04 plus new breakage introduced by fix diff only; initial full source review otherwise retained','verdicts':{'spec':'PASS_FINITE_SOURCE','quality':'PASS_FINITE_SOURCE'},'findings':{k:'ADDRESSED' for k in proofs},'source_proofs':proofs,'changed_product_input_manifest_matches':checked,'raw_lookup':{'path':str(lookup_path),'sha256':hashlib.sha256(lookup_path.read_bytes()).hexdigest()},'copied_receipts':selected,'review_package':{'path':'/workspace/work/terminal.ui/.superpowers/sdd/tasks-implement-linux-input-editing/task-120-r1-review-package.txt'},'initial_evidence':'../round1/index.json','method':'Direct fixed git diff and source control-flow review; retained version-bound execution receipts reused. No new execution required because existing public selector observations match original reproducers and the remaining race question is settled by data flow.','limits':['Early I04 scheduling window not runtime-forced','No new full suite/bundle/clean consumer/host execution','UInt64 exhaustion remains static proof','Applied unavailable','B-M01/T087-G01 remain deferred/pending']}
package=pathlib.Path(index['review_package']['path']);index['review_package']['sha256']=hashlib.sha256(package.read_bytes()).hexdigest()
(r/'index.json').write_text(json.dumps(index,ensure_ascii=False,indent=2)+'\n')
print('Recorded',len(findings),'addressed findings;',len(report.splitlines()),'report lines;',len(selected),'digest-verified receipts; 3 source files match executed manifest.')

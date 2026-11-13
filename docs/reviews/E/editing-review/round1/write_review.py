import json, pathlib, hashlib, subprocess, shutil
out=pathlib.Path('/workspace/work/editing-review')
round=out/'round1'
source=pathlib.Path('/workspace/work/editing-implementation/verification')
base='f38c72784f440ff96a118233ad0237e1a1b57504'
head='043523cdb07d4de542174022dddfa5ed715b560d'
common={'round_id':'E120-R1','revision':head,'acceptance_ref':'TASK120 / E001–E005 / AC028','severity':'major','review_severity':'Important','status':'confirmed','fix_revision':None,'verification':None}
findings=[]
def add(id, category, target, contract, claim, setup, actions, expected, observed, refs, fix, mode):
 x=dict(common,id=id,category=category,target=target,contract_ref=contract,claim=claim,reproducer={'setup':setup,'actions':actions,'expected':expected,'observed':observed},evidence_refs=refs,required_change=fix,evidence_kind=mode,spec_verdict='fail',quality_verdict='fail')
 findings.append(x)
add('E120-I01','state','src/text_edit_session.cj:50–54,112–135; src/text_editing.cj:96–105',
 'E001 tracked, committed snapshot; F005 external synchronization; AGENTS §6/8',
 'External synchronization does not invalidate the committed editor snapshot, so a snapshot-dependent binding evaluated earlier in the same batch remains permanently stale.',
 'Mount TextInput(source="abc",controller:c) and Text({=>c.snapshot().text + "@" + caret}) guarded by c.isValid(); render once.',
 ['In one app.batch, c.select(TextSelection(2,2)); source.set("Z").','Read the committed controller snapshot and render the same application again.'],
 'Both controller and dependent Text show Z@1 after stabilization.',
 'Controller is Z@1, while the getter and rendered label remain abc@2. select() queues the snapshot binding via signal before the source binding; the getter reads the new source version but old local state. sync() then publishes Z@1 without notifying signal, so it is not revisited.',
 ['round1/probe/main.cj:9–34','round1/probe/run.stdout','src/runtime_session.cj:1338–1359','src/text_edit_session.cj:50–54,112–135'],
 'Publish/invalidate committed editor state in a safe phase so dependent bindings cannot miss synchronization. Preserve snapshot purity and do not fix this by pumping inside snapshot().',
 'executed_public_probe_plus_source')
add('E120-I02','export','src/text_editing.cj:46,107–121; src/runtime_session.cj:1273–1298',
 'E004 single Canvas/M1 render; Runtime R004 and detached-render contract; AGENTS §5/8',
 'Detached public render(TextInput/TextArea(...)) paints no editor text because its draw callback only runs with a persistent intrinsic mount session.',
 'Construct detached TextInput(Observable<String>("abc")).',
 ['Call render(component,3,1).toPlainText().'],
 'The same Canvas path exports abc without running user mount/cleanup effects or publishing a controller/NodeRef.',
 'The result is three spaces. Temporary Runtime suppresses mount effects, owner.session stays None, and the entire draw body is skipped. Measure still reads source, so this is silent loss of content, not an unsupported-operation error.',
 ['round1/probe/main.cj:6–7','round1/probe/run.stdout','src/layout.cj:492–526','src/text_editing.cj:20–24,46–84'],
 'Provide validated pure editor display state for temporary render through the existing Canvas path; retain the detached render prohibition on lifecycle side effects and published handles.',
 'executed_public_probe_plus_source')
add('E120-I03','state','src/text_edit_session.cj:477–526',
 'E003: horizontal movement/editing resets preferred display column; E002 undo/redo restores selection',
 'Undo/redo publishes a new text and caret but leaves preferredColumn from a previous vertical move, so subsequent vertical navigation uses the wrong column.',
 'TextArea("ab\\n12345\\nXY"); select gap1, insert !, select gap8 (column4 on line2), then Down (clamped to column2 on line3, preferred4).',
 ['Undo restores original text and gap1 (column1).','Press Down again.'],
 'Down lands at gap4, column1 on line2.',
 'Undo restores gap1, but Down lands at gap7, column4. history() never clears preferredColumn; ordinary replace() does.',
 ['round1/probe/main.cj:35–49','round1/probe/run.stdout','src/text_edit_session.cj:392,438,477–526'],
 'Reset the preferred display column for successful undo and redo, consistently with other editing operations, and cover navigation after both history directions.',
 'executed_public_probe_plus_source')
add('E120-I04','state','src/text_edit_session.cj:282,349–386,146–160,206',
 'E001 atomic read/compute/conditional commit and no retry of old paste/deletion intent; E002 keyboard rejection must preserve session',
 'Keyboard preparation and replace() do not share one source snapshot: replace() can resynchronize to a newer source and successfully apply a deletion range computed from the old source.',
 'Source="ax", caret=1, source version v; dispatch Backspace while a permitted background writer is active.',
 ['handle.sync() reads ax/v.','While handle scans graphemes, background source.set("YZ") commits v+1.','handle computes deletion range [0,1] from old text/selection.','replace() observes v+1 and syncs to YZ, but keeps the old range; it computes Z and successfully commits against v+1.'],
 'A background write after the edit snapshot wins: retain YZ, reject the old deletion with one ConcurrentValueChanged, no onChange/history for it.',
 'The reachable source interleaving deletes Y from the background value, commits Z and emits onChange without a conflict. The later CAS is against the refreshed token, so it cannot detect this conflict. This specific interleaving is source-proven, not claimed executed. The same split also permits keyboard size prevalidation on old text followed by an IllegalArgumentException after replace refreshes to a larger value.',
 ['src/text_edit_session.cj:282,349–386','src/text_edit_session.cj:146–160,178–180,204–219','src/observable.cj:24–50','canonical design.md:E001/E002'],
 'Capture the operation source/selection token once before keyboard planning and carry it through validation, range calculation and conditional commit. Reject intervening versions rather than silently rebasing the old intent; keep legitimate pre-operation external synchronization.',
 'source_only_explicit_reachable_interleaving')
for p in [out/'findings.json',round/'findings.json']:
 p.write_text(json.dumps(findings,ensure_ascii=False,indent=2)+'\n')
report='''TASK120 round1 — spec FAIL; quality FAIL. Four Important/major findings remain open.
Fixed range: f38c72784f440ff96a118233ad0237e1a1b57504..043523cdb07d4de542174022dddfa5ed715b560d; source verification tree clean.
E120-I01: snapshot-dependent bindings can stay stale after select + external source write in one batch; observed label abc@2 while controller is Z@1.
E120-I02: detached render(TextInput("abc"),3,1) produces three spaces; temporary rendering skips the sole editor draw state.
E120-I03: undo/redo retains a previous preferred column; observed Down after undo at gap7 instead of expected gap4.
E120-I04: keyboard range/size preparation can use an older source than replace(), which resyncs and commits old deletion intent against a newer background value.
I01–I03 have a focused public-API probe with actual output; I04 has an explicit reachable source interleaving, not an executed race claim.
Probe SDK1.2.0; public cjc consumer links the frozen candidate's existing warm libraries. Compile/run exit0 means observations executed, not product PASS; two setup-only compiler/link attempts are retained.
Complete scope checked: exact API/limits, mount identities/read-only/owner/domain guards, intrinsic lifecycle ordering/release, callbacks and revisions, Unicode seams/history and memory ownership.
Canvas composition uses one Runtime/Component/Frame/resolver and one viewport; LF selection, clipping, caret, zero/narrow geometry and target/default routing were traced against fixed tests/raw.
Observable uses its original lock/version; atomic read and conditional commit emit outside the source lock; committed local state precedes onChange, with prepublication UInt64 guards.
Existing 48-editing-expanded raw has a real ConcurrentValueChanged (changed=false, issue=1, changes=0). The sole production issue site follows failed editingCommit; sourceVersion originates in an atomic value/version read. This proves that tested CAS conflict, not I04's missing earlier guard.
Own UInt64 guard inspection is static only; no exhaustion execution or public setter is claimed. Same-text selection collapse keeps redo; history budgets count complete before/after bytes across both stacks.
Copy/cut uses actual Application.copyLocalText, exact F004 result priority and source/mount/revision guard; no fake Applied, clipboard query, second writer or queue. Actual Applied remains unavailable.
Shared writer gate order is outputGate→Runtime lock; blocking native write releases the general Runtime lock, stop admission is serialized, and first-device-error handling remains in the existing path.
Read corrected 45-session-fixed raw (33 cases/0 failures), 48 public/8 PTY output, and relevant retained lint/example/RichText receipts; no cold suite, bundle, clean-consumer or actual-host execution was repeated.
No candidate source/test/spec/main edits, author report/reasoning, test-role contact or subagents. Report details and reproduction steps: findings.json; immutable input/raw bindings: round1/index.json and SHA256SUMS.
B-M01 getter-axes/onMount-Off remains deferred TASK024 and was not reopened; T087-G01 wholechecker remains TASK023 pending.
TASK121 execution/package/host work and TASK122 finite acceptance remain separate; no full Linux/parent AC closure. Initial review used; at most five subsequent fix rounds, diff-only re-review.
'''
(out/'report.md').write_text(report)
(round/'report.md').write_text(report)
(round/'full.diff').write_bytes(subprocess.check_output(['git','diff','--no-ext-diff','--unified=5',base,head],cwd=source))
(round/'source-state.txt').write_text(subprocess.check_output(['git','rev-parse','HEAD'],cwd=source,text=True)+subprocess.check_output(['git','status','--porcelain'],cwd=source,text=True))
# Copy only finite relevant raw receipts; their origins and root-provided digests stay explicit.
rootindex=pathlib.Path('/workspace/work/terminal.ui/.superpowers/sdd/tasks-implement-linux-input-editing/task-120-raw-index.json')
lookup=json.loads(rootindex.read_text())
selected=[]
for phase,names in {'48-editing-expanded':['exit','stdout','stderr','source-commit','binary.sha256','input.sha256'], '45-session-fixed':['exit','artifacts/summary.json'], '24-stop-proof':['exit','stdout'], '39-repeat-direct':['exit','stdout'], '41-lint-default':['exit'], '37-stream-lint':['exit'], '42-example-final':['exit','stdout'], '43-rich-final':['exit','stdout']}.items():
 for name in names:
  original=pathlib.Path('/workspace/work/editing-implementation/raw')/phase/name
  if not original.exists(): continue
  data=original.read_bytes(); digest=hashlib.sha256(data).hexdigest()
  expected=lookup['raw_sha256'].get(str(original))
  assert expected==digest,(str(original),expected,digest)
  dest=round/'receipts'/phase/name; dest.parent.mkdir(parents=True,exist_ok=True); dest.write_bytes(data)
  selected.append({'origin':str(original),'copy':str(dest.relative_to(round)),'sha256':digest,'root_digest_verified':True})
probe=round/'probe'
(probe/'run-command.txt').write_text('source /workspace/work/validation/sdk/cangjie/envsetup.sh\ncd /workspace/work/editing-review/round1/probe\nTERM=dumb COLORTERM= timeout 30s ./probe >run.stdout 2>run.stderr\n')
inputs={}
paths=list(source.glob('src/text_edit*.cj'))+[source/x for x in ['src/observable.cj','src/observable_source.cj','src/runtime_session.cj','src/runtime_node.cj','src/component.cj','src/node_ref.cj','src/application.cj','src/terminal_bridge.cj','src/text/unicode.cj','src/layout.cj','src/binding.cj','openspec/changes/implement-linux-input-editing/design.md','openspec/changes/implement-reactive-runtime/design.md','AGENTS.md']]
paths += list((source/'tests/editing/target/release').glob('*/*.a'))+list((source/'tests/editing/target/release').glob('*/*.cjo'))+list((source/'native').glob('*.a'))
for p in paths: inputs[str(p)]=hashlib.sha256(p.read_bytes()).hexdigest()
index={'round':'E120-R1','base':base,'head':head,'classification':'execution: independent finite fixed-source specification and quality review','skills':['c5/requesting-code-review (reviewer role, no further delegation)','c5/verification-before-completion (reuse per AGENTS11.1; fresh focused observations and artifact checks)'],'verdicts':{'spec':'FAIL','quality':'FAIL'},'findings':[x['id'] for x in findings],'canonical_raw_lookup':{'path':str(rootindex),'sha256':hashlib.sha256(rootindex.read_bytes()).hexdigest()},'source_and_warm_probe_inputs_sha256':inputs,'copied_receipts':selected,'probe_scope':'Small public consumer linked to existing fixed candidate libraries; not a new normal product build, suite, host or acceptance result. Runtime observations I01–I03; source-only schedule I04. Setup compilation errors retained separately.','counter_proof':'Text revision prechecks sync118, replace201, history503; selection revision checks applySelection87, sync123, replace201, history503. External exhaustion fails before local text/token publication, no business rollback. UInt64 paths source-reviewed only; existing Observable Int64 source version remains its distinct authority.','race_attribution':'raw48 issue=1, changed=false, changes=0. Production ConcurrentValueChanged only text_edit_session142, entered only when observable.editingCommit32–50 returns None, which occurs only version!=expected under original source lock. Expected sourceVersion comes from init34–36/sync113–127 atomic (value,version), or earlier successful own commit. No fake setter/worker overlap inference.','limitations':['Four required findings unresolved','Applied real producer unavailable; source policy only','No fresh host/bundle/clean consumer/full suite','B-M01 deferred024; T087-G01 pending023','No author self-assessment or role cross-contact']}
(round/'index.json').write_text(json.dumps(index,ensure_ascii=False,indent=2)+'\n')
print('findings',len(findings),'report lines',len(report.splitlines()),'verified copied receipts',len(selected),'input bindings',len(inputs))

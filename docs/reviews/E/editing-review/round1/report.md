TASK120 round1 — spec FAIL; quality FAIL. Four Important/major findings remain open.
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

TASK120 fix round1 / evidence round2 — spec PASS_FINITE_SOURCE; quality PASS_FINITE_SOURCE.
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

# TASK008.d independent spec + quality review
Source `80d21e071537898cde27f1c7de4328ab6f27d991`; BASE `5a6819ffd2226ad31e725669209b94607f2b1e63`; frozen tests `9d224da8f74997fa8329a84c798c61e5a57d2fc9`.
Scope: canonical review brief/C002, eight-line Application diff, formal tests and relevant frame/session/native ordering; read-only, no product-author report or reasoning consumed.
Declined: full host/M1 recovery and TASK041 acceptance belong to future gates; current PTY/source review cannot certify them.
Declined: archive allowlist correction belongs to known T087/TASK023; current checker failure remains visible, with no release PASS.
SPEC: PASS for the scoped correction and source-review gate; not final TASK008 acceptance.
QUALITY: PASS; no Critical/Important/Minor findings requiring changes.
STATUS: READY_FOR_INDEPENDENT_EXECUTION_AND_ACCEPTANCE; no merge, publish or product-ready assertion.
Strength: minimal change in the existing Application owner; immutable existing CaretSnapshot, no new API/entity/renderer/writer.
`src/application.cj:613,653–659`: first visible caret and changed position emit CUP; identical successful grid/caret/profile emits nothing; any nonempty grid output always restores visible physical position even when logical pose is unchanged.
`src/application.cj:661–691`: known-probe visibility remains independent; allocation failure clears frame baseline for full retry; cancellation breaks and device failure records/throws before Frame/caret/profile/glyph/dimension commit.
All device baselines and probe are local to run; `runtime_session.cj:1549,1562` counts generated targets and returns a Frame copy, not a successful-device metric or mutable prior-frame alias.
`frame.cj:282–309` compares projected rows under old/new profiles and forces complete size repaint; glyph/profile baselines retain success-only ordering.
`terminal_bridge.cj:43–68` shares writer with optional operations; `native/cjtui_terminal.c:32–69,108–122` retries short/EINTR writes, records exact bytes, latches only partial fatal unsafe across reopen, and frees/restores native resources without output.
`application.cj:759–805`, `runtime_session.cj:1422–1441`, and session extension cleanup preserve first failure, suppress unsafe later bytes, and still attempt cleanup; raw partial-caret/cleanup cases corroborate ordering.
Frozen RED normal-caret records 4→5 transactions; fixed developer raw records 4→4, genuine movement CUP and initial full-grid+CUP preserved.
Read-only audit verified fixed HEAD/tracked source, all nine frozen test hashes, baseline index SHA, supplied command hashes, and consistency of all 338 developer case/check/direct-exit/transaction/termios/signal/native-close records: zero failures.
Evidence sufficiency: literal normal/short/style/resize/profile/caret controls plus exhaustive finite wire cuts and source ordering support this review gate; developer execution is not the independent final execution.
Post-text unchanged-logical-caret supplement remains an unexercised fixture precondition, not a new RED or positive PASS; source branch proof establishes preservation here, and initial grid+CUP corroborates physical positioning. No claim of that dedicated runtime case.
Configured build exit0; bundle exit0 with 789 warning diagnostics; structured cjlint has 791 SUGGESTIONS and zero other severities; range-format diff empty. New baselineCaret scope suggestion does not invalidate necessary across-loop lifetime.
Archive checker exit1 rejects `themes/light.toml`; this pre-existing separate release gate is not closed by successful bundle creation.
Skills applied: requesting-code-review reviewer template and verification-before-completion; AGENTS11.1/Battle7 evidence reuse honored, with no build/test reruns or source edits.
Findings: `findings.json` (empty); fixed inputs, exact skills, factual evidence hashes and audit scope: `index.json`.

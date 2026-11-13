# TASK-153 narrow fixture typing correction
Status: fixed test-only handoff; no product change or behavioral acceptance.
Test SHA: `fe9f66fc10a9f864c1db55dd1d507b78defacbfc`; base `5413dc768a93b3e3f172227161bc9d8545993508`.
Only `tests/widgets_small/src/event_boundaries.cj` lines8/98 changed: `repeat: None` → `repeat: Option<UIKeyEvent>.None`.
All oracles and all other source bytes are preserved; reversing the two qualifiers reproduces exact baseline bytes.
Actual154 compiler log reports the two ambiguous None constructors; this is fixture typing failure, not product RED.
SDK1.2 cjfmt parser0, exact-two-line diff0, inverse-byte equality0, commit/scope/clean-tree checks0.
All previous296 evidence bindings plus old report/index are unchanged.
Evidence: `evidence/index.json`, before/after snapshots and raw compiler/verification logs.
No full-body or behavior PASS claimed; implementation154 must rerun the affected normal runner.

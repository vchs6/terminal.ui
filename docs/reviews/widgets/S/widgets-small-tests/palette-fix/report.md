# TASK-153 explicit palette fixture correction
Status: narrow independent test-only handoff; no contract or product change.
Test SHA: `c6bf589e6df199a88851f0311a606d39f4963ad7`; base `09ce650a07715ad67a7f22b1930745b71b61bb10`.
Independent public Text/Checkbox-role primitive probe build0/direct0 confirms color-only Inline inherits Classic selected inverse=true.
The same probe confirms six explicit false Boolean attributes override Classic for both Inline and Named palettes, using complete Style equality.
Only theme_cases.cj setup changed: explicit complete Inline/Named palettes and six initial themes supplied through the documented Application(theme:) constructor.
styleIs, complete expected Styles, pixels/events/oracles and all other35 test files are byte-equal; bounded inverse proof and parser0.
Prior final/typing-fix/contract-fix indices and bound artifacts remain unchanged; actual154 runner-contract.log and style-probe2.log preserved separately.
Evidence: `evidence/index.json` binds before/after, canonical per-field Theme/Classic inputs, public probe source/binary and raw commands.
Original pre-start loadTheme control failure is retained as fixture setup evidence; accepted inactive loads return SessionClosed.
Remaining gap: progress_geometry.cj still uses pre-start loadTheme outside this authorized theme_cases-only correction; no full-widget/154 PASS.

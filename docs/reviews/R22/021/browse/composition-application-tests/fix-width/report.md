TASK021.a bounded Done-row width fixture correction
Classification: execution; arithmetic error in an80-column expected row.
Parent: 95b6d780a92b65bf4c83540d3e7c8a47c131df64
TESTONLY commit: 384a90053a3e9467799ef8600e8ecc9253647f92
Source: /workspace/work/composition-application-tests/fix-width/source
Independent arithmetic: ASCII Done occupies4 columns; 80−4=76 trailing spaces.
Old expected4+77=81 conflicts with frozen80x24 viewport; captured row is80 with no stale tail.
PTY change: sole numeric literal77→76; full-row equality and stale-tail requirement retained.
Oracle: fixed phase length80, rejects same-width nonspace final cell and81-column padding.
Same-class scan: no other explicit space-repeat padding literals in PTY; repeat4 sites are key navigation.
Counterexample actual replay exit1; corrected replay/oracle/syntax/whitespace each exit0.
Expected row comes from manual arithmetic/frozen viewport, not generated from product output.
No app/compiler build/run, core/app/API/CLI/key changes, subagents, cleanup or push.
Exactly2 formal test files changed; later real-key execution remains pending independently.
All5 older indices/reports/indexed raw verified unchanged; retry3raw/events/exact Done frame retained separately.
Separate immutable provenance/commands/results/limits: fix-width/index.json and evidence/verify.sh.

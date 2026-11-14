TASK021.a bounded retained-selection fixture correction
Classification: execution; old append expectation conflicts with local grapheme-gap selection/history/source-sync contract.
Parent: d07a6933be8ff2429ee9799ee32043642e0dfeb4
TESTONLY commit: 95b6d780a92b65bf4c83540d3e7c8a47c131df64
Source: /workspace/work/composition-application-tests/fix-selection/source
Basis: text-editing docs local per-view gaps; TextEditSession.history restores beforeSelection, sync only clamps endpoints.
Manual derivation: qrcvzy six clusters +LF one => second-line r at index7; Home/ShiftRight selects [7,8].
X/Y undo restores [7,8]; external Shared note has11 clusters, so neither endpoint clamps.
Retained [7,8] selects n; ! replaces it yielding literal Shared !ote. Append would lose selection.
PTY diff only2 expected literals: failed ! check and downstream F1 roundtrip; no End/caret/focus/key changes.
Contract records exact positions; oracle validates r/n range and rejects append/collapsed/start alternatives.
Old captured append-expectation replay true exit1; corrected replay/oracle/syntax/whitespace each true exit0.
Captured raw corroborates source-derived expectation; expected text not generated from program output.
No demonstrated editor defect; actual independent sequence beyond this point remains pending.
No application/compiler build/run, core/app/API/CLI edits, subagents, cleanup or push.
All4 older indices/reports/indexed raw verified unchanged; original retry2 raw/events and exact prior frame retained.
Separate immutable provenance/results/limits: fix-selection/index.json; commands: evidence/verify.sh.

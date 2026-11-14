TASK021 supplemental TESTONLY retained-selection review — 2026-11-14
BASE d07a6933be8ff2429ee9799ee32043642e0dfeb4 → HEAD 95b6d780a92b65bf4c83540d3e7c8a47c131df64.
SPEC: passed for this bounded expectation correction. QUALITY: passed; no findings in the three-file delta (25 additions/2 deletions).
Public editing documentation defines grapheme-gap selections local to each view. TextEditSession.history restores beforeSelection; sync clamps each endpoint to the new count without moving valid endpoints.
The existing paste normalizes CRLF to LF: six qrcvzy clusters plus LF place second-line r at [7,8]. Home/Shift+Right selects r; the X/Y undo operations restore [7,8].
The modal changes the shared source to eleven-cluster Shared note. The ordinary retained view keeps [7,8], selecting n; typing ! replaces it with Shared !ote.
Independent captured pre-! frame shows n inverse-selected after F9, event log then sends only hex21, and raw output contains Shared !ote. This corroborates the source-derived expectation; captured bytes did not define a new editing rule.
Only the immediate focus-return and downstream Tasks-roundtrip expected strings changed. No End, selection collapse, focus workaround, key order, delay, parser, product/core change or removed assertion was introduced.
New arithmetic controls document the literal gap derivation and reject append, insertion-at7 and reset-to-start alternatives. They validate fixture reasoning, not runtime controller correctness; stored replay separately checks the captured positive/negative strings.
Recorded original expectation RED, replay and infrastructure outcomes were inspected and hash-verified; no commands/tests/builds/application runs were repeated. Standalone author report/derivation/self-assessment was not consumed.
Final author seal 5f1189b5206ac030e446a35268bac59ee84e99a19a66fc1a2f2ca15b825bb630 was explicitly supplied before binding. Exact source/raw/command references are in index.json.
All three prior review indexes remain byte-identical and are reused; product e3016afe and prior source/theme/PTY verdicts are unchanged. Historical metadata limitation remains in the original review.
This is a scoped test-source gate, not full ordinary/actual-host AC021 acceptance. Later width-fixture diagnosis and remaining execution are outside this sealed scope.

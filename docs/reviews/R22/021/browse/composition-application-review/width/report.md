TASK021 supplemental TESTONLY Done-row width review — 2026-11-14
BASE 95b6d780a92b65bf4c83540d3e7c8a47c131df64 → HEAD 384a90053a3e9467799ef8600e8ecc9253647f92.
SPEC: passed for the bounded fixture correction. QUALITY: passed; findings.json is [].
The full-row expectation must have 80 columns: Done is four ASCII columns, leaving 76 spaces. The previous 77-space literal required 81 columns.
The only PTY change is repeat(77)→repeat(76); strict full-row assert.equal remains. No trimming, prefix-only replacement, removed stale-tail check, key/parser/product change or timeout alteration occurs.
New controls require literal width80 and separately reject an 80-column row with stale x at column79 and an 81-column padded row. They validate fixture arithmetic, not application correctness.
The independent captured Done row has length80 and a wholly blank 76-column tail; recorded old-literal RED and replay/selftest outcomes corroborate the correction. No test/build/application rerun was performed.
Explicit final test seal 4413bb5e4e28f45abb9ce5a3cfde199b5eba4d41f73dcf13773625e7ee01cf26 and necessary source/raw/command hashes were verified; no author report/reasoning was consumed.
All four prior review indexes remain byte-identical. This supplemental gate reuses their product/core conclusions and historical provenance limitation without changing them.
Full ordinary interaction completion and actual-host AC021 acceptance remain separate executor/acceptance responsibilities; this arithmetic review makes no such claim.

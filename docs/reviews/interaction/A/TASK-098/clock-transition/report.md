# TASK098 I05 transition supplement

Test-only `722560383dd8933236155bbc6989e4cfb060eb8f` (parent13f75fcc),7 test files, clean; replay fixed6f0fcc4006d3b6138e823eaa6d127a548db58a21. No product/contract/status edits, authors' reports/contact or subagents. Original94 vector bytes, always-1 function/13 old goldens and readonly guard are preserved. Only this new control/transition pair ran.

I015 preserves actual100ms input idle and ordinary input when the clock fails. Initial always-1 recovery does not prove the first failure observed after a pending read. New public consumer uses Application.run/onKey and file observations; no terminal protocol output bypasses the product writer. Existing clock seam remains the sole fault clock. Optional poll-entry observation extends the existing test shim, without a decoder or fake policy.

Ordinary wrapped CJPM build0 (8 pre-existing unused-expression warnings). Same compiled binary both cases; actual prehash precedes the build. After exact original-visible report and managed25l, send ESC at clock1000; observe exactly two1000 samples (lastInput and pre-read), plus the next100ms poll entry. The failure case atomically changes clock to-1 while that read is pending, then sends[A. Matching poll completes readable without any completed100ms idle. q ends each run. No sleep guessing or timeout-only oracle.

| Input/control | ESC→[A gap | Actual public events | Driver / product |
| --- | --- | --- | --- |
| valid clock1000 | 711147ns | up: / text:q | 0 / 0 |
| clock1000→-1 after handshake | 1023695ns | escape: / text:[ / text:A / text:q | 1 / 0 |

Both keep original-visible status and restore termios; poll rows/entry, clock samples, exact input timestamps, wire, binary and public event files are retained. Failure reaches the literal expected `up:|text:q|` assertion. This measures the post-read application.cj630 branch;645 remains a source risk, not a claimed execution. Default review mode now includes this pair; `--review-regressions --clock-transition-only` runs only it.

Initial environment setup errors (duplicate-doc ENOSPC and unpopulated sparse index/missing manifest) are retained separately and never counted as behavior RED. Only fresh own duplicate tracked docs were removed; Git/history/raw and old sources remain. Sparse checkouts and existing SDK/stdx/cache/UCD were reused; no SDK/dependency cache copy. After correct materialization, one ordinary build and the two intended cases ran. README/coverage only were updated after execution; committed runtime Cj/native/Python/shell bytes match those executed.

Pure manifest `raw/manifest.json`, SHA256 `56a2eb054d71fd610ea61d59b6234f246ee20bb9249be4f78361c911381c5295`. Original independent proof is copied/hash-indexed. Old13/87/full hierarchy, source645, and post-round2 product behavior were not run here; no extra asset review/archive.

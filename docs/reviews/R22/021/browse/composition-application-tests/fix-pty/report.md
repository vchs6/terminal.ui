TASK021.a bounded PTY fixture correction
Classification: execution; two confirmed test assumptions conflict with fixed encoder/G012 contracts.
Parent: 2e5e998d00f2f60e45376bca4ada8376273d339a
TESTONLY commit: 6dbece66e2989849d87729a5da10d95b4fbb0a24
Source: /workspace/work/composition-application-tests/fix-pty/source
Encoder: Frame full output resets frame bounds; encodeTerminalRow omits row-end reset when final style is default.
Old WireScreen incorrectly required reset after every row; source-derived literal reproduces actual exit1.
Fix: existing Screen flush validates complete row at actual CUP/native boundary; no synthetic reset or style normalization.
Auto: unknown PTY uses conservativeUnicode; 👩‍💻 logical2/scalar-sum4 projects exactly??; CJK stays unchanged.
Old literal Unicode wait fails on supplied captured raw (exit1); headless Unicode smoke remains unchanged.
Separate manual minimal-pty.json fixes Auto16x3; TextArea visible predicate projects?? while pasted Unicode bytes stay unchanged.
Tests: full/delta/byte chunks/resize/style inheritance positive cases; short/overlong/unsupportedSGR/truncated row/control/UTF8 negatives.
After: literal row case, oracle, syntax, original110-byte raw replay under1/7/all-byte chunks each exit0.
Expected grid derived from fixed source/G012 independent width facts, never generated from captured product output.
No application/compiler build or run; actual keys/business results still pending independent execution.
No app/core/API/CLI/override changes, subagents, cache copies, cleanup or push.
Original c51/index84da and shadow2e/index4798 reports/all indexed raw verified unchanged.
Original diagnostic raw copied byte-identically into this versioned evidence; source path/hash indexed.
Commands/results/proof/limits: separate fix-pty/index.json and evidence/verify.sh.

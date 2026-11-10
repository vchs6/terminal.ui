# Formal093 G012 test refresh archive

[Original report](report.md), [actual command result ledger](results.md) and [source-to-copy/SHA256/omission index](archive-index.json) retain the original test author facts.

Fixed test-only commit: `df21f3def32de39a415d1d8d9845b83514dc2902`, integrated by root at `9454f22`. Normal old-product build0 and limited conservative-kernel5/5PASS are actual executions. Complete API missing RED1 and positive readonly gate BLOCKED2 are separate; readonly product checks did not run and complete094 is not passed.

Three SDK compile-only controls show mutable parameters are immutable inside their function, a mutable local with public mutable field compiles, and a readonly field rejects assignment. They were not executed. The fixture now tests each field via a mutable local, removing that false positive, while actual product readonly remains blocked by absent API.

Original Unicode/Ascii/map/native cases and earlier093 evidence are preserved by original source hashes and selected logs. Native compile and script syntax checks do not imply native/PTY execution. No product or task state changed. Source checkouts, caches, SDK and binary artifacts remain external; the original report folder contains only selected text/source/command evidence and was copied without changing its bytes.

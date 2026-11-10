# Instrumented VTE viewport recon archive

[Original report](report.md), [findings](findings.json) and [source-to-copy/hash/omission index](archive-index.json) preserve the investigation without changing its verdict.

The developer test module reads `vte_terminal_get_text()` inside real XFCE1.1.4/VTE0.80.1. This is **instrumented native viewport text**, not a complete cell-attribute grid, an uninstrumented product run or product/TASK148/TASK151 PASS. TASK148 oracle and requirements are unchanged.

Final normal/alternate/restored/scrollback reads, native PID/version/module compilation and load hashes, baseline and before/after original PNGs and unchanged-read controls are preserved. Every original PNG is retained. GUI Save failure, naive alternate-range error, and write_contents history/NUL counterexamples remain evidence. Intermediate repeated non-PNG iterations remain external with original hash mappings.

Clipboard observation queried only the private server's empty owner metadata (`owner=0`). No clipboard payload or user data was read; no nonempty-owner payload control was performed. This finite observation does not establish general noninterference. Native module loading and callbacks are instrumentation; future151 must explicitly decide its evidence policy.

No whole source checkout, SDK, executable module, cache, private key or temporary HOME directory was copied. External tool/module paths in provenance are source records, not claims that their binary artifacts are archived.

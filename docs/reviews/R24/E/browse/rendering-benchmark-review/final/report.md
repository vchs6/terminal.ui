# TASK145 final independent review closure

**Specification verdict: PASS. Code-quality verdict: PASS. TASK145 review is closed for candidate `c8624c1de5ab7ec6727ef59d9f2897f9cf6b7960`.** Both original P2 findings are addressed, with no unresolved finding or additional breakage found. This combines the original complete 44-file review, the three-file R1 correction review, and the final artifact/evidence binding checks. It does not claim performance benefit, real-host acceptance, AC-022/031 closure, or Linux completion.

The original review and R1 report/index remain immutable. No new full-source review, build, benchmark probe, product edit, or subagent was used for this closure. Producer plans, reasoning, reports and self-assessment were not used. The final producer factual index is SHA-256 `3f180509442e32671ba0df0a2bf87811b6f2f22dfa8989f7e3289dc6b29ca148`; all 51 primary file bindings were independently checked and matched.

## Findings closed

- **F145-01 — ADDRESSED:** `layout_scene.cj` now constructs seven unchanged `.layoutWeight(1)` siblings, invoking the existing Row weighted allocator. One first-column width input changes, and fixture facts report one directly dirty leaf. Public observations show three bindings/subscriptions rather than ten. Hand-expected allocations pass at both required sizes; `same_row_columns` retains independent fixed columns and its complete Cell/caret checks pass in both entrypoints at both sizes.
- **F145-02 — ADDRESSED:** `terminal_runner.cj` applies `workload.glyph(0)` before the first normal `Application.run` target. Zero-warmup glyph projection starts in Ascii, with all three logical updates producing no business-row grid output under the same profile. Fence output is separately observed. Other steady scenarios retain their Unicode initialization; fresh initial lifecycles remain separate.

The independent frozen 80×24 regression implementation passes against the corrected old-package, transferred new-package and final delivered-package compat executables. The 160×48 runs are explicitly derived producer supplements, not the unchanged independent test. Their synthetic-PTY records include normal exit/restoration and are not labeled real-host measurements. Source review establishes genuine weighted allocation; matching geometry alone is not substituted for that proof.

## Final package and normal consumption

The delivered ordinary CJP is SHA-256 **`8572434f9b83603e96b2bf9ea50965a8b3b6a888ff69680a7e8df24d9c805ff6`**. Its 44 benchmark/documentation members were read directly from the archive and match candidate Git bytes and the extracted consumer. No excluded development/build members were found in the 333-file archive inspection. The 33 shared compat/workloads source files are byte-identical across the old, transferred new and delivered consumer trees.

The final extracted CJP's workloads, compat and diagnostic projects each have successful ordinary CJPM build records. Their declared relative dependencies, normal SDK 1.2 setup, stdx/UCD prerequisites and established official dependency cache were retained. This is normal clean archive consumption, not a claim of an empty-cache or hermetic build. The normal old M1 workloads/compat builds also pass; the frozen old library was not modified to add new diagnostics or backfill benchmark implementation into its baseline artifact.

Actual delivered executable hashes were checked:

- Compat: `b5344b1fb93ad74bd2ec308cebf5da6dc220a93679c918284ddeb2d56ceced32`.
- Diagnostic: `b99c297590e1ae11c9774eec5b765611f8272cb0ff2d7d58e9f8cc79823679f1`.

The plain default bundle exited 0. Its unsuppressed test phase reports **TOTAL 0, FAILED 0**; this is not evidence of zero-count tests covering the benchmark. Its lint output contains **836 warning lines**, with no reported lint errors, followed by `cjpm bundle success`. These facts are retained without describing the build as warning-free.

The first delivered compat build was interrupted with exit −15 after disk exhaustion; its empty log and resource/exit receipt remain separate from the successful retry. Initial delivered runtime attempts failed with exit 2 because the SDK runtime library environment was absent; their loader-error records remain separate from the successful correctly configured retries. Neither failed attempt is treated as a product assertion failure or a passing run.

## Corrected and reused execution evidence

The original fixed-330 matrices remain historical evidence for unchanged paths: 142 required compat commands, 162 required diagnostic commands, 54 unsupported diagnostic rejections, and complete Cell/caret checks at both sizes. They are not relabeled as a fresh full c862 execution. Corrected flex, projection initialization and the directly affected same-row paths have separate R1 coverage; earlier incorrect fixture data is not used to validate either repaired finding.

Old/new comparison coverage combines the retained 53 completed comparisons with 19 remaining 160×48 correctness runs. Those 19 records contain 38 successful Cell/caret validations and 38 successful old/new comparisons, plus 19 valid author-bound sample rows. Their comparisons to retained 330 new outputs concern unchanged headless frame/caret behavior; this includes independently rechecked same-row output and glyph projection's unchanged headless behavior. Such output reuse does not authorize reuse of old dependency counts, timing costs or the incorrect initial TTY profile.

Corrected affected old/new Cell/caret comparison logs pass at both sizes. The delivered diagnostic has eight successful affected correctness/M2 runs and eight complete Cell/caret validations. The earlier rejection and mode-eligibility evidence remains applicable because the correction does not change dispatch or eligibility. The same frozen library-only three-counter boundary remains intact.

Six delivered compat samples and eight delivered diagnostic samples have successful frozen-validator metadata joins. Their actual sample IDs, overlapping runtime fields, source/CJP/ELF hashes, dependency/native digests and compiler hash agree with their designated external provenance manifests. Dependency manifests cover 366 files each; native manifests cover four archives. Their listed files and aggregate digests were independently recomputed and matched. These are verified producer-generated functional evidence bindings, not independently executed performance measurements or globally merged measurement datasets.

## Acceptance boundary

No unresolved TASK145 source, package or evidence-binding issue remains. The benchmark's reviewed correctness/timing separation, mode matrix, fresh-generation/idle handling, full Cell/caret observations, scoped counters, public API isolation, ordinary consumption and two repaired fixtures are sufficient for this review closure.

TASK146/147 still own sufficient-duration independent repetitions, distributions/noise, true process CPU and scoped allocation/heap/GC/RSS costs, separate syscall-return output tracing, real terminal hosts, all broad/negative results, and the original AC-022/031 benefit/acceptance decision. Functional exit-zero counts and metadata-valid smoke rows do not establish those outcomes.

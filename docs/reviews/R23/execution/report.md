# TASK166 independent execution — fixed 199f00076

**TASK166 independent execution: PASS for the bounded fixed-source scope, including the final corrected color fixture.** Product source is `199f00076c1a79cfa6d0be92e7be09366e1a06af`; formal glyph tests are `614d0a2f0e33e54ecc07bd783eaeb0b9957ca557` (identical test tree `26a127a1bd31b99c12168f50cf584ad74dc4a052`). No product, formal glyph test or main checkout edits; no subagents or author self-assessments used.

## Fresh actual execution

| Scope | Result | Original evidence |
|---|---|---|
| SDK1.2 normal root build/check | 0 / 0 | [build](raw/01-root-build/stdout), [check](raw/02-root-check/stdout) |
| Formal public consumer | 34 literal checks, 0 | [formal all](raw/03-formal-all/stdout) |
| Package-local normal CJPM tests | 9 passed, 0 skipped/error/fail | [formal all](raw/03-formal-all/stdout) |
| Fixture controls | 0; historical physical failures remain rejected | [formal output](raw/03-formal-all/stdout) |
| Frozen old physical evidence | intentional 1, 16 actual failures, 116 old DSR | [preserved RED](raw/06-preserved-old-red/stdout) |
| Repository/OpenSpec checks | 0; 23 OpenSpec items | [check](raw/16-repository-check/stdout) |
| Normal `cjpm bundle` including mandatory lint | 0; **315 warnings**, no skip/suppression | [bundle](raw/05-normal-bundle/stdout), [warning counts](bundle-warning-counts.json) |
| Fresh extracted package root build/check | 0 / 0 | [build](raw/07-packaged-root-build/stdout), [check](raw/08-packaged-root-check/stdout) |
| Clean package public consumer | build/direct binary 0; 34 literal checks | [build](raw/09-packaged-public-build/stdout), [direct](raw/10-packaged-public-direct/stdout) |
| Unmodified packaged rich-text example | build/direct `--smoke` 0 | [build](raw/11-packaged-rich-build/stdout), [smoke](raw/12-packaged-rich-smoke/stdout) |
| Known whole-product boundary | expected 1: missing `examples/composition/cjpm.toml`; future benchmark boundary remains | [unchanged checker](raw/13-known-whole-boundary/stderr) |
| Historical color fixture `3138d1a` | observed 0 / 0; incomplete facility result retained, superseded below | [controls](raw/14-colors-oracle-controls/stdout), [actual](raw/15-colors-actual/stdout) |
| Final color fixture `0d46c35` | stop controls8/8, resize controls0, actual fixture/example0 | [stop controls](raw/26-final-stop-controls/stdout), [resize controls](raw/27-final-resize-controls/stdout), [actual199](raw/28-final-colors-actual/stdout) |

Every fresh command has separate command/cwd/start/end/stdout/stderr/exit originals; [command-results.json](command-results.json) enumerates them. An independent cache copied from the read-only dependency seed and the existing relay were used; the extracted package and ordinary consumer used a separate fresh cache. [Package byte comparison](package-byte-comparison.json) proves all tracked functional source/native/product-doc/example files equal the fixed checkout. CJPM omits the empty `src/.gitkeep` placeholder; it is explicitly accounted for. Public consumer source is exact and only its manifest dependency path changed. [Archive hash](package-archive.sha256) identifies the fresh CJP; no CJP/ELF is included in the curated evidence.

## Actual two-host physical matrix

The genuine hosts are XTerm398 and XFCE Terminal1.1.4 / VTE0.80.1, using the original Monospace/geometry/locale/initially-empty-XDG configuration. [Font identity](provenance/font-match.txt), [font bytes](provenance/font-file.sha256), [host/config hashes](provenance/host-config.sha256), [package versions](provenance/package-versions.txt) and every host command/config/version are retained. The default glyph policy was used; Basic8 and TrueColor variants use the existing public color override, without any glyph override.

| Scene, same binary on both hosts | Actual GUI | Actual DSR replay | Row-four pixels |
|---|---|---|---|
| Original packaged `examples/rich-text` | [PASS](raw/21-rich-verify/stdout) | [PASS](raw/23-rich-dsr-verify/stdout): ZWJ prefix `3;12`, final `3;100` | unchanged |
| Public heart VS16, default Auto | [PASS](raw/21-heart-verify/stdout) | [PASS](raw/23-heart-dsr-verify/stdout): suffix `3;3`, final `3;100` | unchanged |
| Same public heart, explicit Basic8 | [PASS](raw/21-basic8-verify/stdout) | [PASS](raw/23-basic8-dsr-verify/stdout) | unchanged |
| Same public heart, explicit TrueColor | [PASS](raw/21-truecolor-verify/stdout) | [PASS](raw/23-truecolor-dsr-verify/stdout) | unchanged |

Eight actual application sessions each performed initial → t → t → real X11/PTTY resize → t → q, with 100→120 actual columns, direct exit0, exact inner and outer termios restoration, host exit0 and recorded host/Xorg reaping. Forty original application stages, 40 complete raw DSR replies, 80 original full-window PNGs, 24 application row-four comparisons and 16 DSR row-four comparisons are retained. Every DSR comes from the real host with input/output offsets, raw reply bytes and original captured payload derivation hashes; no logical-width/grid model supplies the physical oracle. The replay only strips the initial util-linux script header and inserts the fixture's DSR query at its fixed payload boundary.

The 40 stage [literal row/style audit](scene-bytes-audit.json) checks complete row text and padding, unchanged positive ASCII/CJK/e+0301/single woman/single laptop/flag bytes, all CUP rows and every SGR sequence against hand literals. The original business Unicode remains in the clean package public/offline checks and `--smoke`; device bytes replace the incompatible ZWJ/VS16 clusters with `??`. Actual PNGs were also visually inspected for XTerm rich-text and VTE heart. This auxiliary byte audit is not the physical oracle.

[Original image provenance](original-images.json) records exact hashes and dimensions. Capture UTC is retained per stage; hashes were finalized after host/Xorg exit. The original package example source is unchanged; the same packaged example binary hash appears on both hosts. Sun/keycap GUI variants were optional and were not run; their canonical/offline rows remain covered by the formal public checks. No assertion is made about arbitrary fonts or unknown terminal hosts.

## Reused regression scope

[Reuse proof](reuse-proof.json) independently checks the preserved pre-lint source hashes. Exactly one file differs: `terminal_projected_row.cj`, whose two `Style()` default constructions were hoisted into one local immutable default value. The reconstructed old file strictly matches its original manifest hash `6f98c3ff…`; the fixed file matches `93ca7894…`. [Exact diff](reuse-source-diff.patch) and the actual immutable, field-assignment-only `Style` constructor establish unchanged values/equality/output. All other runtime/native files match. [Dependency proof](dependency-reuse-proof.json) checks the same dependency source bytes, SDK1.2/UCD/registry; only independent cache paths differ.

Under AGENTS11.1, six original successful scopes are semantically reused: pure colors, rich text, runtime core, runtime session, capability branches, and resize coherence/inflight. [Original/copy hashes](reuse-originals.json) and `raw/reused/` retain their exact commands, outputs, restoration/native/gate evidence. These are explicitly semantic reuse from the pre-lint execution, not claims that those old commands ran against exact199. New formal tests, package/bundle/consumer, changed runtime GUI/DSR/color overrides and corrected-color observations are fresh exact199 execution.

## Corrected color fixture and preserved attempts

The original official seven-file color overlay `3138d1a549c5941793b24183bd71cad74d2c688c` and its observed run remain preserved in [historical overlay hashes](colors-test-overlay-3138.json). Independent review found **CRF001 Important** in that facility: final close could miss late partial rows/incomplete ESC/wrong-style same-width output. Its earlier exit0 was explicitly held short of acceptance.

The independent scoped review verified CRF001 addressed with no open findings, admitting official test-only `0d46c35456db148f08bd407825a4fd559467249a` (parent3138). Exactly README, pty.mjs and the new stop_oracle_test.mjs were updated; the full eight-file overlay hashes are in [final overlay](colors-test-overlay.json). Product HEAD remains199 and every fixed product/formal glyph source hash was rechecked. No other suite, GUI, package or dependency build was repeated.

Fresh actual execution of `node tests/colors/stop_oracle_test.mjs` passed all eight child/stdout/close cases: five invalid tails rejected and quiet/reset/identical-row closes accepted. The separate resize controls returned0. A single fresh `node tests/colors/pty.mjs fixture example` against the existing unchanged199 binaries returned0: 14 acknowledged exact-byte actions, RGB cycle, six attributes, atomic31×12→8×4→100×40, final grid/parser/style reset validation after stdio close, q exit0 and exact real termios restoration for both sessions. [Source and binary proof](colors-final-binaries.json) records the fixed example/fixture source hashes, identical before/after binary hashes, raw session hashes and exact before/after termios hashes. These are new199 observations; the test author's old91 runs do not supply this result. The corrected-color obligation is now satisfied.

External adapter failures are preserved in [package proof attempts](raw/package-proof-attempts.json): directory enumeration first included generated native artifacts and then an empty `.gitkeep`; functional byte comparison passes after exact scope correction. The finalizer's first hand-written command-count assertion expected34 rather than actual35; [original script](raw/commands/finalize-attempt1.py) remains preserved and the corrected audit uses the actual list. These are evidence-adapter failures, not product failures. `fc-match` returned the recorded font identity with [cache warnings](provenance/font-query-stderr.txt). Formal fixtures were never edited to accept failure.

This report does not mark TASK167, original083/084, TASK094, M2, the complete-product boundary or full Linux acceptance complete. [Scope](scope.json), [verification counts](verification.json) and [artifact counts](artifact-counts.json) state the exact completed execution scope and retained limitations.

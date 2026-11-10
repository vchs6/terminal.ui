# TASK057 independent acceptance — pending preparation

Prepared 2026-11-10 in independent fresh clone `/workspace/work/layout-acceptance/repo` from `/workspace/work/terminal.ui`. Checkout `e27b154decf97239d1f86d7a3900a4eedfe16e8c`; reviewed technical baseline `425626a1b6556b16837cb0744d5a5f46ebd54814`.

**Verdict: pending.** TASK056 has not delivered its final frozen execution revision, raw results, actual archive or clean-consumer evidence. AC-011/012/054–058 cannot yet be signed passed. No product/test/main-workspace edits or full functional test reruns were made.

## Authority and scope

Read AGENTS including §§7, 8, 10.5, 11, 13.2 and user source-organization §14; layout-decoration proposal/design/tasks; docs/tasks.md; docs/acceptance.md; docs/development/cangjie-conventions.md; frozen public tests/runner; independent local and whole review outputs. Implementation-author reports were not used as acceptance conclusions.

This acceptance concerns finite Linux layout, character decoration and source organization. It does not complete themes, reactive state, editing, scrolling, overlays, M2, composition/benchmark delivery or other operating systems. R8's previously accepted facts remain historical evidence for their bounded scope. Existing unrelated pending AC entries must remain pending.

## Fresh checks already performed

- Technical byte identity: `git diff --exit-code 425626a1b6556b16837cb0744d5a5f46ebd54814 HEAD -- src native build.cj cjpm.toml tests examples`, exit 0. Per-file SHA256 inventory: [technical.sha256](technical.sha256).
- Repository/configuration/link/task mapping: exit 0, [raw](logs/repository-metadata.log). Used existing main repository node_modules read-only through an ignored symlink in this clone.
- OpenSpec all/strict/noninteractive: exit 0; ten items passed, [raw](logs/openspec-strict.log). This validates metadata only.
- Source scan: each product class/struct/enum/interface occurs in its own lowercase-underscore file and directory/package correspondence holds; [inventory](logs/source-organization.json). Root exports explicitly retain Rect, BorderStyle, Color, Style, displayWidth and graphemeClusters. Runtime/package compatibility still awaits TASK056.
- Whole-repository whitespace check exits 2 for preserved rendering trailing spaces and saved patch context in R9 evidence. Technical-only whitespace check exits 0. These are evidence-format findings, not product defects; original raw must retain its bytes.

## Required final evidence

| AC | Required acceptance basis | Current state |
|---|---|---|
| 011 | Frozen independent consumer expectations: actual/zero viewport, clamped minima, exact largest-remainder ties/extreme weights, setter rejection preserving state, clipping/control safety, old behavior; final direct-binary results on fixed source | pending |
| 012 | Frozen golden cells/styles and shared wide-cluster cleanup, original geometry clipping/extrema/degeneration, shadow paint-only expansion and ancestor clipping; actual example d off/on and resize clears old cells | pending |
| 054 | Independent test provenance, true API-absence RED, final immutable-reference capture correction preserving assertions, unchanged R8 assertions and final frozen test bytes | pending |
| 055 | Independent local and whole spec/quality verdicts covering final fixed technical content, closed required findings | pending final identity linkage |
| 056 | Fresh all suite and true binary exit propagation; actual example d/resize/q plus exact termios; raw hashes and fixed execution version; cjp contents and clean extracted consumer | pending |
| 057 | Actual raw inspected against contract/source; final integration technical bytes unchanged; state/evidence links and metadata consistent; no wider release claims | pending |
| 058 | One type per file, package direction/root re-export compatibility, actual archive new subpackages and no development dependencies, clean consumer using public root API | pending execution |

The public width policy keeps shade `░` one column even in ambiguous-wide mode, so runtime forcing of shadow-dot fallback is not available through the frozen public API. That conditional branch requires source review, not fabricated runtime coverage. Border fallback is exercised through actual ambiguous-wide glyph widths.

The full `check:bundle` release checker is expected to remain nonzero because composition and rendering benchmark projects are absent; a bounded archive check can establish this slice's usable source distribution but cannot establish complete-release readiness.

When execution arrives, inspect raw results rather than accepting report counts, verify each delivered hash and copy/projection mapping, compare final integration technical paths byte-for-byte, and update this report/results only after concrete evidence closes the obligations.

## Frozen cold/PTY evidence audited (partial handoff)

Independent executor's `logs/slice.exit` is 0, and `slice.log` reaches the final bounded-slice marker after original R8 modes, both new public consumers, actual layout PTY and both example build/check/test entries. Read the actual raw including exact expected strings, setter failures, integer-extreme `ABB`, infeasible-minimum `AAAABB`, wide-continuation cleanup, clipped geometry, explicit Default styled-space and shadow-style assertions. CJPM's own zero-test summaries are not counted as public consumer coverage: the fail-fast runner explicitly executes the built consumer binaries.

All **53** entries of executor `inspected-source.sha256` independently equal the corresponding fixed `425626a` git objects. Independently fetched `dabd60b` and confirmed its complete execution/packaging technical scope diff against `425626a` is empty; metadata-only changes therefore do not invalidate these runs under AGENTS §11.

Rehashed every PTY artifact. The 3595-byte raw stream SHA256 is `63149ac67c9e3aca0ce839ca46b4eea11245dc710514d54cefddffcb8e1693b4`. A separate read-only decoder parsed all 55 complete-row writes from raw, retained previous rows across differential updates and found the seven saved screens in order. It confirmed exact viewport shapes, no border/shadow glyph after normal d-off, complete initial-screen equality after d-on and final resize-back, and no decoration in the tiny screen. Tiny d events may emit nothing because no decoration is visible, as expressly allowed by the frozen harness. Both captured termios strings are identical; actual example exit is 0 without forced signal; stderr is empty. The unchanged reviewed harness enforces idle silence before toggling. Audit command and conclusions: [audit-cold.mjs](audit-cold.mjs), [log](logs/cold-raw-audit.log). Byte-identical audit copies are retained under `frozen-cold/`.

This establishes the cold functional/actual-example portion only. Package/clean-consumer and final integrated metadata are still pending; AC-056/057 have not received final passed verdicts.

# TASK057 independent acceptance — pending resumed execution

## Current resumed scope (2026-11-10)

**Verdict remains pending.** Independent clone is now detached at `6ffc6d7600142928baa4a1aeeeca4690e8872c94`; its technical source/tests/build/example scope equals fixed repair `40aa4db6c2b7673bb3e8c9a80fdb5b4e385cb940` byte-for-byte. Current finite scope is AC-011/012/054–060. Independent repair review and the executor's completed lifecycle/native-session/root checks have now been independently audited below. Final integration/actual-layout-PTY/package/consumer handoff remains outstanding. This role has not rerun functional tests.

This is an execution/acceptance continuation under binding AGENTS, D-026/D-027, change tasks and acceptance matrix; it neither changes their contract nor extends product scope. Applied verification-before-completion to require concrete raw and source identity before any passed verdict. Only this role's evidence files are edited; product, tests, native code and main workspace are not edited. Implementation-author reports and reasoning are not acceptance inputs.

[Resume audit](audit-resume.mjs), [raw result](logs/resume-scope-audit.log), [current technical manifest](technical-40aa4db.sha256) and [current source organization](logs/source-organization-40aa4db.json) record the independent source/contract preparation. The complete original report/results are retained as [pre-resume report](pre-resume-verification.md) and [pre-resume JSON](pre-resume-results.json). The original frozen logs and PTY artifacts all match their previously recorded [hash inventory](logs.sha256); none were regenerated or overwritten.

The only product change from `425626a` is `src/application.cj`: capture a business Exception, perform exactly one close and record its status in a non-throwing finally, then propagate the original exception or both messages after cleanup. The only other technical changes are the new six-file independent lifecycle consumer plus its runner and README wiring. Of the 51 original technical files, 48 are identical; all Frame, layout, decoration, Unicode, native code, examples, root public exports, build and dependency manifest bytes remain unchanged. The source scan still finds 19 files and 12 correctly named single-entity files with corresponding packages. Static inspection establishes identity/organization, not runtime or bundle correctness.

Per D-027 and AGENTS §11, reuse the original `425626a` cold numerical/golden consumer results for unchanged Unicode/Frame/layout/decoration paths. Original seven-frame/termios evidence remains explicitly historical at its original SHA. It is not described as a fresh full-suite run on the repair. New `Application.run` evidence must cover the affected lifecycle, previous session/integration paths and actual layout PTY, root build/check, standard non-skip bundle and clean extracted consumer.

| New obligation | Evidence required before closure | State |
|---|---|---|
| AC-059 / D-027 | Review and lifecycle raw now audited; standard bundle and final source linkage still required | pending |
| AC-060 | Real 5-pass/1-fail RED and all six independent final modes/termios/close count now audited; final handoff/linkage still required | pending |
| AC-056/058 package | Actual cjp hash/list includes new product subpackages; artifact source bytes equal fixed git; no development runtime dependencies; ordinary clean public-root consumer builds/runs without private flags | pending |
| AC-057 final linkage | Executor fixed SHA and inspected-source manifest; copy/projection hashes and resolving evidence links; final main technical bytes unchanged and only bounded statuses changed | pending |

The standard `cjpm bundle` command must succeed with SDK 1.2.0 mandatory checks enabled. The separate complete-release checker may still fail because required composition/benchmark delivery is absent; its actual expected failure must be recorded separately from finite package usability. Remaining full-project obligations and unrelated pending AC entries cannot be marked passed by this slice.

## Resumed partial execution independently audited

Audited immutable completed evidence only, via [audit script](audit-resumed-partial.mjs), [raw audit log](logs/resumed-partial-audit.log), [case details](logs/resumed-partial-audit.json) and a [copy/source/hash inventory](frozen-resumed-partial/inventory.json). These copies retain original bytes under `frozen-resumed-partial/`; historical failing bundle and RED evidence remain intact. This is evidence inspection, not repeated test execution or final TASK056 acceptance.

- All 87 entries of executor `source-hashes.json` independently equal the fixed `40aa4db` git objects and actual executor checkout files. Its text manifest agrees entry-for-entry. This includes build/configuration/scripts, product docs, source, native, tests, examples and license inputs.
- Independent scoped cleanup review is spec/quality passed with empty findings. Its exact technical diff SHA256 is `919094a488182162faac9b9fe1dfcb6d00aa5fecf73d70e50f0dc9e964a2face`, independently regenerated from git; original review files and main `docs/reviews/R9/cleanup-review/` copies are identical. This covers review responsibility and does not substitute for execution.
- Independent `application-lifecycle` log exits 0, SDK/cjpm 1.2.0. Read every final result, raw stream, stderr, before/after termios and close record: q/Ctrl-C/resize exit 0; q+close failure, callback exception and callback+close failure exit 1. All six have no forced signal, actual first ANSI frame, empty stderr, exactly one real close with `real_result=0`, and exact termios restoration. Injected close failures retain `terminal restore failed`; callback failures retain `CJTUI_CALLBACK_SENTINEL`, including both in the dual-failure raw.
- Independently inspected the frozen original RED: exactly five modes pass and dual-failure mode fails because the business sentinel is absent while restore failure remains visible. The real close still occurs once and exact termios is restored. The final six-case independent raw closes this regression without replacing RED with an author's self-test.
- Original native-session owner and setup-signal modes each pass with restored state, and commands/logs report exit 0. Ordinary `cjpm build` and `cjpm check` each exit 0; check traverses `cjtui.geometry`, `cjtui.style` and `cjtui.text` with the root package. These checks do not establish archive boundaries or extracted-consumer usability.

All nine bounded AC statuses remain pending until the executor's complete final result and remaining package/integration evidence arrive. Later main integration requires only source/evidence/metadata identity checks if technical content remains equal; it does not require repeating already valid functional runs.

## Preserved initial preparation and cold evidence

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

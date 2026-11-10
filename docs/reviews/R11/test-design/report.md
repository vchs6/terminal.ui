# TASK-067 independent test author

## Scope and inputs

Frozen contract: `458a4b684afe8bb9a8c1dfbe050f368bcc2fc123`, design/tasks in `implement-frame-composition`. Product source is unchanged from `31a7017`. Only independent tests and test documentation are changed in `/workspace/work/frame-tests/repo`. No product source edits, implementation author materials, delegated reviewers or subagents.

Execution task: exact API/observable semantics were frozen. TDD and verification-before-completion skills were read and applied. SDK 1.2.0 selected through envsetup; private copied read-only dependency cache; ignored registry relay configuration `127.0.0.1:18973`; original UCD17 input. Literal grids were hand-derived, and public Cell metadata is checked separately. No product compositor/export was used to generate an expected result.

## Fixed deliveries

- Core admission commit: `159d44ef856694992952b73bb60b3590da499108`. Five test-only files: public consumer, CJPM manifest, build/direct-binary runner, run-slice composition/all mode, test README. Genuine missing-API RED had actual exit **1**, with original stdout/stderr/status and source/test hashes under `evidence/core-*`. Product author received this fixed input while remaining boundary/file tests were independently prepared.
- Final edge/file increment: `b4684be2919473586d01e7a9e6654f9e42b544b4`. Added cohesive pure test functions in `boundaries.cj`/`files.cj`, external literal-byte verifier, expanded runner/README. No old assertion or old test body changed.

## Contract coverage

| Behavior | Evidence in consumer |
| --- | --- |
| Explicit opacity and layer order | transparent initial cells; default/styled opaque spaces; foreground/background metadata; later layer precedence; different source unchanged |
| Shared write behavior | put, fillRect, border and shadow write opaque cells on transparent frames; unused allocation stays transparent |
| Whole-cluster clear | both leader/continuation touched; outside partner; explicit opaque/transparent blank kinds and Style reset; clear does not change future default cleanup |
| Copy/resize | literal source clips on both sides; complete wide clusters; exact requested size/origin; out-of-source padding; growth/shrink; both directions of ownership; future blank kind/ambiguous-width policy and original budget retained |
| Composite wide boundaries | left continuation/right leader clipped to source-style opaque space; both target halves; wide source crossing two target clusters; outside target partners use default blanks; transparent source never clears target |
| Self overlap | left/right, up/down, wide clusters, transparent holes, zero offset; snapshots are hand-derived |
| Bounded geometry | negative x/y, Min/Max, huge offscreen clear, huge visible clear, bounded copy with extreme origins, legacy zero-area extreme dimensions, no virtual-axis iteration |
| Budget/policy errors | invalid budget/dimensions; positive-area cap; multiplication overflow before allocation; copy/resize budget; zero-width LF length at/over cap; all mismatches reject before changes even zero area/offscreen |
| File bytes | exact UTF-8 CJK/combining composed snapshot; default and explicit TrueColor, Basic8, Monochrome; transparent flattening; zero-width LF; zero-height empty outputs; no BOM/extra LF/extra bytes; exact ANSI CUP/reset/style bytes |
| File lifecycle/errors | create missing file; replace/truncate 1024-byte prefills; empty truncation; missing parent and directory target standard FSException; LF-budget validation before create/open; actual `/dev/full` writes must fail with standard FS/I/O exception when device exists |

Small resulting grids are scanned for valid leaders/continuations and normalized transparent blanks. No helper reimplements compositing or Unicode segmentation. Allocation tests use invalid large sizes or small explicit budgets; no huge valid allocation is attempted.

## Commands and original evidence

Normal unchanged-product `cjpm build` completed actual exit **0**: `evidence/baseline-build.stdout`, `.stderr`, `.exit`; source/input/SDK hashes retained. Contract commit is docs-only, and baseline source hash manifest was rechecked as unchanged (`final-product-unchanged.stdout`).

Core RED `./tests/run-slice.sh composition` completed actual exit **1**; diagnostics show missing new Cell/Frame APIs. Final frozen runner completed actual exit **1**; evidence is `evidence/delivery-red.stdout/.stderr/.exit`, with exact test hashes `evidence/delivery-tests.sha256`. The command/environment are in `delivery-red.command`. Normal build is used, no product stubs or ad hoc FFI flags. Direct produced binary is required by the runner after a successful build, so SDK cjpm-run masking cannot hide assertion failures.

The final source was additionally compiled with `cjc -p tests/composition/src --import-path tests/composition/target/release --error-count-limit all`; `frozen-all-diagnostics.*` stores all **82** diagnostics, exclusively new `isTransparent`, `transparent`, `maxCells`, `clear`, `composite`, `copy`, `resized`, `writePlainText` and `writeAnsi` API absence (the extra constructor argument is the new named arguments on the old constructor). This isolates missing implementation from hidden syntax errors; it is not a substitute for behavioral execution.

Shell syntax, Node syntax and git whitespace checks are retained with actual statuses under `shell-check.*`, `node-check.*`, `diff-check.*`. All returned **0**. The SDK-only throwaway file-error probe confirmed std.fs.FSException is available; `/dev/full` primitive probe returned FSException. Neither probe is product acceptance.

## Execution boundaries

This role establishes frozen RED only. The new consumer cannot execute on old product lacking the APIs; no behavior/file GREEN, old-regression pass, bundle pass, application overlay capture, AC-010 closure or full Linux/release success is claimed. Independent implementation review/execution/acceptance must run the frozen consumer and contract/coordinates/colors/layout/decoration regressions against the reviewed product SHA.

Runner artifact directories are fresh and retained; file verification compares Buffers against literal UTF-8/ANSI bytes, not the product string export. Consumer executes under `TERM=dumb` and empty `COLORTERM`, so default file TrueColor must remain independent of device probing. File failure can leave partial data as allowed; tests assert no unpromised atomicity/persistence behavior.

Final working tree is clean. Both test-only commits are in the independent clone; delivery-tests/evidence manifests were checked against committed contents. Product-source checksums remain unchanged.

## F003 clarification regression (additional scope)

Input original tests `b4684be2919473586d01e7a9e6654f9e42b544b4` and unchanged product fixed `883444195725224985f29060253017432abaa7f3`. Contract clarification is formally committed as `277841d445329662cc0f8ba14d293bf651a635a8`, design SHA256 `7aa92d812303ee1aadcffddd3a539216f9174b5aef34ffd18ec58783c8663331`. This clarifies an ambiguity in the original shared “transparent skip” wording; no claim is made that the product author violated the original ambiguous wording. It adds a narrower data-copy contract: `copy`/`resized` preserve explicit transparent source holes, while `composite` skips transparent cells.

A fresh independent clone `/workspace/work/frame-tests/validation` is checked out at product `8834441`. Its existing tests exactly match frozen `b4684be` before this addition. No product source or old golden/assertion is modified; no author analysis or implementation body read. Private read-only dependency cache and ignored registry configuration are reused as environment inputs. Only the new `CJTUI_COMPOSITION_CASE=transparent-hole` target will be executed, after ordinary `cjpm build`; unrelated suites are not rerun.

The new public consumer constructs opaque-default `XYZ`, clears column 1 transparent, and independently composes the original/full copy/same-size resized frames over fresh `ABC`. All three expected grids are literal `XBZ`; all flags are false/true/false. It also checks normalized transparent metadata, independent mutable cells, grown resize preserving the original hole, and newly allocated rows/columns remaining opaque source-default spaces. All checks run before the final aggregate exception, so original/copy/resize results remain observable separately.

Fixed test-only commit: `7a4def72509401665c9914b81e6a95be1e0b0ee6` (parent is product `8834441`; only three tests/test-documentation files added to the diff). The working tree is clean. Normal consumer build completed actual exit **0** (`build.stdout/.stderr/.exit`), then the direct focused binary completed actual exit **1** (`red.stdout/.stderr/.exit`). The original source composed as `XBZ` and retained its transparent hole. Copy/same-size resize closed the middle hole (`isTransparent=false`) and composed as `X Z`; grown resize also closed the old hole. New growth cells correctly retained opaque default blanks and mutation independence passed. Eight explicit FAIL lines were recorded before the aggregate exception; no unrelated test ran.

All original stdout/stderr/actual statuses, reproducible command/environment, SDK versions, product-source/test/binary/design hashes are retained in `evidence/f003/`. Product-source and test hash manifests were rechecked before committing; git diff whitespace check returned 0. `evidence.sha256` hashes the original records. This is a focused contract-clarification RED regression, not a repeat of or replacement for the original missing-API RED. No product fix/GREEN or original-contract implementation violation is claimed.

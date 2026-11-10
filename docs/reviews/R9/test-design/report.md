# TASK-054 independent test-author report

Execution task; binding contract is `openspec/changes/implement-layout-decoration/design.md` at `86b088f` (clone checked out before authoring). Workspace `/workspace/work/layout-tests/repo`, branch `test/task054-contract`. No production sources modified or implementation-author directories inspected. Skills actually read: TDD including writing-good-tests, verification-before-completion. Parent coordinates OpenSpec authoritative state.

## Layout freeze

Command from clone:

```sh
source /workspace/work/validation/sdk/cangjie/envsetup.sh
CJTUI_UCD_ZIP=/workspace/work/validation/replay-dependencies/UCD-17.0.0.zip ./tests/run-slice.sh layout
```

SDK compiler and CJPM both report 1.2.0. Local ignored repository configs use `/workspace/work/validation/replay-dependencies/cache` and relay `http://127.0.0.1:18972`. Note: first command used `CJTUI_UCD_ZIP`, which native build does not consume; native build downloaded and SHA-verified UCD successfully. Subsequent commands use `CJTUI_UCD_ARCHIVE`.

Raw output: `/workspace/work/layout-tests/layout-red.log`. Result: exit 1, `68 errors generated, 8 errors printed`; missing real `Rect` and `Component.width/height` APIs. No stubs used. This is API-absence RED, not behavioral GREEN. Hand-checked ratio fixtures and setters remain to be run against implementation by independent executor. `bash -n tests/run-slice.sh` and `git diff --check` pass.

All original R8 assertion sources are unchanged. New mode is appended to all after retained original modes. Parent owns later full execution and implementation integration.

## Decoration freeze and actual-example PTY support

Decoration baseline command:

```sh
source /workspace/work/validation/sdk/cangjie/envsetup.sh
CJTUI_UCD_ARCHIVE=/workspace/work/validation/replay-dependencies/UCD-17.0.0.zip ./tests/run-slice.sh decoration
```

Raw `/workspace/work/layout-tests/decoration-red.log`: exit 1, actual missing `Frame.drawBorder` and `BorderStyle`; API-absence RED. No production stub or source change used. The final test also captures the panel created inside the Row construction block (a prebuilt component expression does not attach a child under the existing public block API).

Public-width probe, same baseline product, independent temporary consumer at `/workspace/work/layout-tests/width-probe`:

```sh
cd /workspace/work/layout-tests/width-probe
CJTUI_UCD_ARCHIVE=/workspace/work/validation/replay-dependencies/UCD-17.0.0.zip cjpm build
./target/release/bin/main
```

Raw `/workspace/work/layout-tests/public-width.log`: build and direct binary exit 0; `displayWidth("░", ambiguousWide: true) == 1`, `displayWidth("─", ambiguousWide: true) == 2`. UCD17 `EastAsianWidth.txt` independently identifies 2590..2591 as N, 2500..254B as A. Decoration consumer expects real shade, and forces actual border fallback. Conditional shadow-dot fallback is not reachable with this public width policy; independent code review must examine that branch. No imaginary hook was added for coverage.

Actual example PTY support: `/workspace/work/layout-tests/repo/tests/integration/layout-pty.mjs`; agreed with coordinator, initial rounded plus exposed shadow, d off/on, q normal exit, 48x14→23x9→8x4→48x14. It builds actual example before running, preserves raw/frame/termios artifacts, and never uses a fake application. The example is absent at baseline, so actual-example execution remains blocked until implementation integration; syntax verification is not a behavioral pass. Tiny d toggles permit idle silence if there are no visible decorations to change.

Static verification: `node --check tests/integration/layout-pty.mjs`, `bash -n tests/run-slice.sh`, and `git diff --check` exit 0. R8 consumers/assertions remain unchanged, and all runner modes preserve direct binary exit propagation.

Generated CJPM lockfiles are excluded from both new consumer projects, as requested by coordinator. The first layout lockfile is removed in second commit. Added one hand-derived layout fixture beyond first freeze: (Max/2-1):(Max/2) weights for three columns must allocate 1:2, detecting floating-point false ties.

Final supplemental decoration fixture: operations on Frame(0, Max), Frame(Max, 0), and Frame(0, 0) must terminate without iterating an invisible axis; `toAnsi()` stays empty. Actual `./tests/run-slice.sh decoration` rerun after this addition remains RED exit 1 for missing public APIs (61 errors, 8 printed), raw `/workspace/work/layout-tests/decoration-final-red.log`. This is compiler verification of the final test source, not runtime verification of geometry.

Product-under-test baseline full SHA: `86b088faf77e18b76e9771d086f55f762f9503a8`.

## Full baseline regression run

```sh
cd /workspace/work/layout-tests/repo
source /workspace/work/validation/sdk/cangjie/envsetup.sh
CJTUI_UCD_ARCHIVE=/workspace/work/validation/replay-dependencies/UCD-17.0.0.zip ./tests/run-slice.sh all
```

Raw `/workspace/work/layout-tests/all-baseline.log`. Native ownership/setup-signal, native-smoke, full contract, coordinate extrema, non-TTY, and every original PTY mode reached PASS. The exception PTY correctly returned 1 with termios restored. The all run subsequently reached real missing-layout-API RED (`70 errors generated, 8 printed`); decoration and actual layout example are after layout in the fail-fast runner and therefore were not reached in all (decoration was separately built to RED as documented). The changed tests' behavioral GREEN remains the independent executor's responsibility after implementation.

`git diff --quiet 86b088f -- src native build.cj cjpm.toml tests/contract/src tests/coordinate-boundary/src tests/native-smoke/src tests/integration/pty.mjs tests/integration/fixture/src tests/native-session` returned 0: production baseline and all R8 assertion sources remain identical.

Frozen test commits in dependency order:
1. `73448b644a551d6abc64a68d696c20a01aa7df8f` layout + runner + documentation.
2. `bc38a80c8d01cfe8a638e24b9e8e352b0140e8d1` decoration + actual-example PTY + runner + lock cleanup + exact-float counterexample.
3. `af4bfb30fcc5e63dbeb6586f78a4cf5c1be4d104` zero-area extreme-axis boundedness.

Remaining limitations: new consumer runtime assertions and actual example PTY need implementation integration; shadow-dot conditional fallback cannot be forced through current public width policy. No blocked requirement was reported as GREEN.
c5ec6cfa794d829bbe05d7040d457affcb8037b7d5b9951c2002608ed06d71d0  /workspace/work/layout-tests/layout-red.log
09ae33fc622308a3a85eaf14eb46a47a23c329ce29b658c8b16a232558554982  /workspace/work/layout-tests/decoration-red.log
22eb538ceae73f7a35e7b3f0de3bc136b13beaa4a1ad019981d5a4a2084ae331  /workspace/work/layout-tests/decoration-final-red.log
6c9e2c8022a7a43fdae4fcba0ed91bd68d89897ee479a2b605930f401e3338ab  /workspace/work/layout-tests/all-baseline.log
ee9e91fc1859d398f370f5f442efc5753fa5eafb10c424d3cdb89641cd4bb7ac  /workspace/work/layout-tests/public-width.log

Final all shell exit was observed as 1 (`ALL_BASELINE_EXIT=1`). Final static checks all exit 0; working tree is clean after removing only generated, initially absent old-consumer lockfiles. New projects ignore their own generated locks. Report and raw logs are external artifacts, not tracked product sources.

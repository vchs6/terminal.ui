# TASK006 Auto implementation report

Product/test integration HEAD: `0568a09bdb55d9cf02de362da5ff1c2631ddaabf`.

## Delivered implementation

- Added concrete `ColorMode.Basic8`, automatic `Application(root)`, explicit override overload, `colorModeAuto()`, and the read-only `TerminalCapabilities` diagnostic snapshot.
- Kept `Frame.toAnsi()` as a pure TrueColor/six-attribute snapshot; real sessions derive an internal profile from one post-open capability detection per run.
- Added the glibc-private `dlmopen(LM_ID_NEWLM, "libtinfo.so.6")` capability adapter. It reuses one mutex-protected private handle, accepts only known SGR capabilities, preserves raw style data, applies NCV color-priority pruning, and exposes only the packed Int64 FFI result.
- Added `TerminalRenderProfile` in its own source file; projection remains in the existing Color/Style/Frame path.
- Updated the normal colors example to use `Application(root)`, cycle three RGB samples with `c`, toggle all six attributes with `t`, exit with `q`, and include a Unicode line.
- Restored profile recalculation on each render after observing that a runtime `colorMode(...)` override was not changing device output. Baselines now advance only after a successful write.

## Native namespace check

Using the isolated synthetic `probe-16` terminfo entry from the capability reconnaissance source, compiled the product adapter with a temporary C caller and ran it with `TERMINFO` pointing to the temporary database. It returned packed value `1019` (terminfo-known and Basic16), so the private glibc namespace sees the standard `TERMINFO` environment lookup without base-namespace mutation.

## Verification

- `cjpm build` for the product root: success.
- `tests/run-slice.sh colors`: exit 0.
- `tests/run-slice.sh colors-integration`: exit 0; its fixture reported all 14 actions and normal example checks passing with termios restored.
- `tests/terminals/fixture` public no-override consumer: `cjpm build` success.
- `tests/run-slice.sh capabilities`: public API and pure snapshot checks pass through the corrected Cyan golden. The PTY harness then stops before product execution because this ncurses `tic` rejects `--version` (exit 1); `tic -V` works and reports ncurses 6.5.20250216. This frozen harness issue was reported to the test owner.

An earlier frozen snapshot golden asserted SGR34 for RGB `(1,128,254)` at Basic16. Independent output was SGR36 (nominal Cyan); the test owner corrected the golden and commit `04271d4` was integrated.

No real-host matrix was run here; its harness was integrated and its public fixture was compiled.

## Follow-up product handoff

- Fixed product HEAD `06fd2cd0cea27fb4e1db2f4f7f4662633fb83965`; product-only patch from `04271d4` excluding `tests` is `/workspace/work/auto-implementation/product-only.patch`, SHA256 `b643bd319fbc020786a6e7a797f72cfe4ddd1478d6fcd115a55753ca5e67f39f`. `git diff --check 04271d4..HEAD -- . ':!tests'` exit 0. This avoids the fixture manifest mixed into `0e202f9`.
- `2d9071f` corrects ASCII-only TERM validation under non-C locales, accepts decimal terminfo padding, and updates stale product README to describe Auto. Temporary native probe command `cc -D_GNU_SOURCE /tmp/cjt-auto-probe.c -o /tmp/cjt-auto-probe -ldl -pthread && /tmp/cjt-auto-probe`: before exit 1 `non_ascii_term=1 decimal_padding=0`; after exit 0 `non_ascii_term=-1 decimal_padding=1` (compiler warning for duplicate `_GNU_SOURCE` in probe).
- `06fd2cd` corrects an invalid-name early return: `cc /tmp/cjt-invalid-probe.c native/cjtui_capabilities.c -o /tmp/cjt-invalid-probe -ldl -pthread && /tmp/cjt-invalid-probe`: before exit 1 `mode=5 reason=7`; after exit 0 `mode=0 reason=3`. Independent test author was notified for black-box regression.
- `source /workspace/work/validation/sdk/cangjie/envsetup.sh && cjpm build` exited 0 with `cjpm build success`, but the last C edit occurred during this build; do not treat it as final-code build evidence. Capabilities test pending fixed test harness SHA; no independent matrix or bundle acceptance performed.
- Test fix `78ae76c7129bb903ebb6b3b6861c3a7a0851b06b` cherry-picked as `69fb7ca`; `source /workspace/work/validation/sdk/cangjie/envsetup.sh && tests/run-slice.sh capabilities > /workspace/work/auto-implementation/capabilities-69fb7ca.log 2>&1` exit 1. Both builds and six public API/snapshot checks passed, then `timeout: eight first frame`. Raw `/tmp/cjtui-capabilities-KSu34Q/eight/session.raw` shows shell exit 127: `/workspace/work/auto-implementation/repo/tests/capabilities/tests/capabilities/session/target/release/bin/main: not found`. Test author owns path repair; no product change made for this failure.

## Independent review fix round 1

- Fixed test `226886a80ae848b3806a4e855c2ca33b7249328d` cherry-picked as `deb1be8`. Before product fix, capabilities exit 1: `unknown ncv bit conservatively removes SGR1`. Full raw `/workspace/work/auto-implementation/capabilities-deb1be8.log`.
- Product commit `fffd824dbd4c81788936ef0aee80b824ff5e58c5`: colored styles with unknown NCV bits discard all six attributes; default/monochrome styles retain supported attributes; session detection is inside existing `try/finally`; named packed ABI and NCV constants; removed unused superseded private wrappers. No tests changed by product author.
- Fixed increment from `06fd2cd0cea27fb4e1db2f4f7f4662633fb83965` excluding tests: `/workspace/work/auto-implementation/round1-product-only.patch`, SHA256 `ba542f6c389e90e909b80e08a25ec900892027560ee79975af903f2beef80ef0`; `git diff --check` exit 0.
- `source /workspace/work/validation/sdk/cangjie/envsetup.sh && tests/run-slice.sh capabilities` exit 0; raw `/workspace/work/auto-implementation/capabilities-round1.log`, synthetic PTY artifacts `/tmp/cjtui-capabilities-TTNcdC`.
- `tests/run-slice.sh application-lifecycle` first exit 1, raw `/workspace/work/auto-implementation/lifecycle-round1.log`, because fixture lacked local registry configuration (`Failed to resolve address pkg.cangjie-lang.cn`). Copied ignored local registry config using this author's private cache; rerun exit 0, raw `/workspace/work/auto-implementation/lifecycle-round1-configured.log`, PTY artifacts `/tmp/cjtui-lifecycle-JQyIe0`: all six cases pass with exact termios restored.
- Scope is developer checks only; independent reviewer/executor and final real-host/bundle acceptance remain outstanding.

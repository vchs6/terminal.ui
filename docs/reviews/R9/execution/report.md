# Final independent execution — implemented slice passed

Final fixed commit: `40aa4db6c2b7673bb3e8c9a80fdb5b4e385cb940`. SDK 1.2.0, original isolated cache/relay/UCD configuration unchanged. No product or frozen test edits; tracked-source diff exit 0. Full source hashes: `final-40aa4db/source-hashes.json`.

Original cold425 all exit0 remains valid for identical Unicode/Frame/text/style, coordinates, layout, decoration and unaffected example checks; hash-based applicability and exact changed paths are recorded in `final-40aa4db/reuse.json`. The full cold suite was not repeated.

| Final command/stage | Actual exit |
|---|---|
| root-build | 0 |
| root-check | 0 |
| lifecycle | 0 |
| native-session | 0 |
| integration | 0 |
| layout-integration | 0 |
| bundle | 0 |
| slice-boundary-runtime-audit | 0 |
| clean-build | 0 |
| clean-check | 0 |
| consumer-build | 0 |
| consumer-direct | 0 |

Lifecycle includes six real PTY sessions: q, callback failure, injected close failure, combined callback/close failure, Ctrl-C and resize. All assert exact termios restoration and one real close. Normal exits are 0; injected/callback failures remain directly observable as process exit1. Existing integration includes non-TTY plus 11 real PTY cases. Actual layout example verified d off/on, 48x14→23x9→8x4→48x14, idle behavior and exact termios restoration. Raw outputs, frames and termios snapshots are in `final-40aa4db/lifecycle/` and `final-40aa4db/layout-pty/`.

Standard `cjpm bundle` succeeded without skip-lint or fabricated archives; lint warnings remain in the raw log. Root local test count is zero and is not used as contract evidence. Archive SHA256: `12ffc2f4591acfbd1ffe06ea12a55648af642f284d34b92134389c691d462c42`. The local archive is retained but excluded from copied evidence.

Unmodified full-release `scripts/check-bundle.mjs` actually exited **1**, first missing `examples/composition/cjpm.toml`; `benchmarks/rendering/cjpm.toml` is also absent. This is **expected nonzero / incomplete full release, never passed**. The independent implemented-slice package audit passed: 54 regular files, 32 tracked source files compared byte-for-byte, style/geometry/text subpackages and all 19 single-entity product source files included; no development runtime, artifacts or cache paths. Clean extraction root build/check and an ordinary external consumer build/direct binary all exited0, with no private FFI/compile/link flags. Public consumer plain/ANSI output is retained.

Historical failures are preserved: npm default-cache permissions exit254 corrected using workspace cache exit0; original dabd standard bundle exit1 for genuine G.ERR.04 finally-throw; initial final slice audit exit1 was a **harness false positive** from matching node_modules in legitimate manifest excludes. Original/final checker scripts, hashes and diff are retained; corrected audit parses actual dependency tables and archive runtime entries, keeping the original path allowlist. Only the affected audit was rerun; successful bundle was reused.

Complete machine-readable commands, actual exits, scope and historical results: `results.json`; timing: `logs/timeline.txt`. Evidence copy allowlist and SHA256: `evidence-files.json`. Full product/release acceptance remains outside this slice.


# Preserved historical blocked report

# TASK056 independent execution — bundle blocked

Executor workspace: `/workspace/work/layout-execution`; clone `/workspace/work/layout-execution/repo`.
Technical test commit: `425626a1b6556b16837cb0744d5a5f46ebd54814`.
The executor did not read implementation/review author reports and made no product/test edits.

## Scope and commands

- SDK `/workspace/work/validation/sdk/cangjie/envsetup.sh`: compiler and CJPM 1.2.0, Linux x86_64.
- Isolated writable copied dependency cache `/workspace/work/layout-execution/cache`; relay `http://127.0.0.1:18972` via ignored per-project `cangjie-repo.toml`. Executor did not write to the shared cache.
- `CJTUI_UCD_ARCHIVE=/workspace/work/validation/replay-dependencies/UCD-17.0.0.zip`.
- `CJTUI_LAYOUT_PTY_ARTIFACTS=/workspace/work/layout-execution/layout-pty`.
- `bash scripts/check-product.sh slice`: unmodified runner builds root before check; `tests/run-slice.sh all` builds consumers then invokes actual binaries, including actual `examples/layout` PTY. No `cjpm run` is used as an exit oracle.
- Normal local `cjpm bundle`, never publish/upload. Unmodified `node scripts/check-bundle.mjs target/cjtui-0.0.0.cjp` remains full-release checker; its actual result is distinct from the implemented-slice package boundary.
- Clean extracted package build/check and ordinary external consumer build/direct binary, with public imports only and no private FFI/compile/link flags. Consumer stdout is split into plain and ANSI snapshot artifacts.

## Evidence rules

`logs/*.log`, `logs/*.exit`, and `logs/timeline.txt` retain raw commands' output, shell exits and timestamps. `inspected-source.json` / `inspected-source.sha256` record tested code file hashes. Final `SHA256SUMS` covers delivered evidence, excluding itself and heavyweight rebuildable caches/repository build products.

Root `cjpm test` reports zero local cases; this is not evidence of contract acceptance. Contract checks come from the direct consumer binary runner and PTY checks. Slice success cannot establish full product/release completion: composition example and rendering benchmark remain absent, along with later planned framework requirements.

## Environment preparation

Initial `npm ci --ignore-scripts --no-audit --no-fund` exited 254 because npm's default `/home/agent/.npm` cache lies outside writable roots. The same locked install with `--cache /workspace/work/layout-execution/npm-cache` exited 0. This environment-only failure and correction are retained as `logs/npm-ci.*` and `logs/npm-ci-workspace-cache.*`; no manifest/lock/source change was made.

## Results

Fresh unmodified `scripts/check-product.sh slice` exited **0** (01:17:29–01:27:47 UTC). All direct consumer/PTY stages ran, and both introduced examples completed build/check/test. Layout PTY artifacts and structured results are in `layout-pty/`.

Package metadata commit `dabd60b8a7216531d37582ff623aa50ed263a1b6` was fetched only after the suite completed. Restricted technical git diff exited 0, and all 53 inspected file hashes remain identical; see `technical-equivalence.json`. No suite rerun was needed for documentation-only metadata updates.

Normal `cjpm bundle` exited **1**: SDK cjlint reports mandatory `G.ERR.04` at `src/application.cj:74` for throwing in a finally block. No cjp was produced. Execution stopped and the issue was reported to the primary agent without product/test edits or a skip-lint retry. Package boundary and clean consumer stages remain pending. This is an intermediate blocked report, not AC056 completion.

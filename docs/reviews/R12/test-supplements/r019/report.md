# R019 independent tests and resize-oracle correction

Fixed test-only commit: `dddbdd9e02fbb6e8a998b24d447ec9b97a79a439` (16 test files, 426 added/15 replaced lines). Cherry-pick only this commit. Local product dependency pin `dc9eeacb5bda480e26eaa41db907c586e88ca465` is not a test output. Product src/native/build.cj/cjpm.toml blobs match fixed pre-R019 candidate `c3d743d2dd5cb125e4ca435b2842d1b10c501281` (original product alias 01efa7676438f2978feb712b9dd9a4ddb89bbdec). Product tree listing hash: `c96485702816cc0f93dbc021a72875db5657ea562c67af5f7fd1d70d7eab8647`.

Contract input: R019 at fc7667339d39208bbd0c25650696a7f495ca971d. Independent expected results derive from two controlled real terminal states (24×5 and 8×3) and hand-authored fixture grids. The test does not compare against debugger-generated golden output or merely assert a new ABI symbol exists. Root-cause source/syscall/raw facts were read; no product fix or specification was edited.

## Normal builds and separate outcomes

Each raw prefix records UTC start/end, command/cwd, HEAD/source hash, separate stdout/stderr and actual exit.

| Prefix | Actual result |
| --- | --- |
| `r019-product-normal-build` | ordinary fixed product CJPM build **0** |
| `r019-coherence-normal-build` | ordinary new public consumer/native test-support build **0** |
| `r019-coherence-old-product` | direct PTY harness **1**; actual child **0**, final grid settled/native restored, but impossible 24×3 frame observed |
| `r019-inflight-old-product` | separate direct PTY harness **0**; legal complete old frame delivered after atomic resize accepted |
| `r019-lifecycle-settled-old-product` | ordinary lifecycle consumer build plus selected revised resize-success PTY **0** |
| `r019-integration-normal-build` | ordinary integration fixture build with test-only real-close wrapper **0** |
| `r019-integration-settled-old-product` | selected revised integration resize PTY and retained non-TTY preflight **0** |
| `r019-final-facilities` | Node/bash/C syntax and final whitespace facilities **0** |

The coherence RED was saved before any product R019 repair. The two corrected legacy resize scenarios passing on this old product do not mark the product coherent: the independent controlled real-App regression still fails. No old full suite, CPU benchmark, or later product implementation was run.

## Independent real-App coherent pair regression

The new normal CJPM application declares two public Text rows. The test links wrappers for actual libc ioctl/write and actual product close, using the established D027 wrapping technique. Wrappers preserve actual return data; no winsize/Frame/ANSI bytes are synthesized, and they never restore termios for the product.

In coherence mode, after a complete old 24×5 frame, an odd successful TIOCGWINSZ result is held before returning its real old winsize to the app. The parent performs exactly one TIOCSWINSZ containing both new fields, independently reads back 8×3, then releases. Old two-axis reads produce a mixed pair; the new one-snapshot path can return old or new complete pairs. Every recorded successful ioctl result is only 24×5 or 8×3. Actual full app frame pairs are **[24×5, 24×3, 8×3]**, so 24×3 is unambiguously absent from all real states in this controlled run. The final 8×3 target is nevertheless complete and settled. The assertion is evaluated after normal q, actual child exit 0, exactly one successful real close and exact termios restoration; no forced termination supplies the RED.

Artifact directory: `/workspace/work/runtime-tests/r019-artifacts/cjtui-resize-QLuMDr/coherence`. It retains queries.log, arm/query-held/release handshakes, single atomic-resize readback, full session bytes, complete frame grids, observations.json, actual close record, saved termios and failed result JSON.

In inflight mode, the first already-prepared full old frame is held before its actual write. The parent first changes the real terminal to 8×3 in one atomic SET, then releases. Actual frame pairs are **[24×5, 8×3]**. The complete old 24×5 frame arrives after resize and is explicitly accepted; final grid settles and all native/exit checks pass. This establishes that the stronger oracle does not repeat the old history-wide ban.

Artifact directory: `/workspace/work/runtime-tests/r019-artifacts/cjtui-resize-5ftANm/inflight`.

## Corrected legacy fixtures

Both old resize scenarios replace GNU stty's two-field update with the shared test-only C helper's **single TIOCSWINSZ**, followed by independent readback. Both wait for all rows/cells and a closing reset of the hand-authored final 8×3 grid, then observe a bounded settled interval. A shared text prefix or partial frame cannot satisfy this check. They retain width/height/content clipping, normal q exit, exactly one actual successful close and exact termios restoration. The integration fixture gains the same established test-local close wrapper/archive build facility so that close count is observable without a product hook.

Lifecycle final rows: `CJTUI_LI`, `01234567`, eight spaces. Raw directory: `/workspace/work/runtime-tests/r019-lifecycle-artifacts/resize-success`.

Integration final rows: `cjtui` plus three spaces; `中文 👩‍💻 ` (eight display columns); `01234567`. Original fresh artifact directory `/tmp/cjtui-pty-9v5Dku` is retained; a copy is preserved at `/workspace/work/runtime-tests/r019-integration-artifacts/cjtui-pty-9v5Dku`. It includes session.raw, frames.json, atomic readback, stderr, actual close record and both termios snapshots. Its selected run also retains the original non-TTY no-ESC check.

The shared reader is deliberately narrow: the supported full CUP-row/SGR repaint stream, ASCII and the integration fixture's three known wide graphemes. It is a test wire-format facility, not a second renderer, complete terminal emulator, or replacement Unicode engine. All historical bytes remain available. Gate polling only waits for explicit markers; the final observation timer is not used to order the resize race. ABI extreme/zero/EINTR unit coverage is not claimed by this increment; its main regression is the real Application behavior.

## Evidence retention / source

The original failed lifecycle session.raw and the independent debugger atomic-mixed raw remain untouched, both SHA-256 `e246929ecf8675be06fc70a6a4abd00f25fd5e7e8a44a91bdb63b93700c0a4c7`; see `raw/r019-original-evidence-preserved.*`. No original failure was overwritten or relabeled. The old raw cannot by itself uniquely attribute the original failure to mixed reads versus a real stty intermediate pair; this new controlled run establishes its own atomic-input facts instead.

Final committed source manifest: `raw/r019-test-source.sha256`, SHA-256 `fa1101fea7e1fd54d0dd17c31b4aaa20bdd625f01ec5cc2e7517f4410fb068b0`. Generated binaries/archives remain ignored, and generated lockfiles are retained under raw/r019-locks. The source working tree is clean. Requested role configuration remains Sol/high; actual serving identity is independently unobservable. This is fixed test/fixture and pre-repair RED evidence, not repaired-product or TASK074 acceptance.

# TASK-060 independent lifecycle regression

Execution task, authorized D027 contract from coordinator: cleanup always stops running and invokes cjt_close, no throw from finally, normal close failure reports after cleanup, callback+successful close preserves original exception, dual failure explicitly reports original exception and terminal restore failed. Existing stop/Ctrl-C/resize behavior remains. No product-source edits, private imports, runtime hook, or alternate backend. Applicable skills: TDD, systematic-debugging, verification-before-completion (already read and applied in this test-author session).

Workspace `/workspace/work/layout-tests/repo`, isolated branch `test/task060-lifecycle`, frozen product base `dabd60b8a7216531d37582ff623aa50ed263a1b6` fetched from main with clean working tree. Prior TASK054 branch remains separate. The coordinator owns OpenSpec task/decision state.

## Existing mandatory packaging RED

Authorized original evidence `/workspace/work/layout-execution/logs/bundle.log` contains `G.ERR.04: Avoid throwing exceptions to cause a finally block to terminate abnormally` at src/application.cj and `Error: cjpm bundle failed`. This is real ordinary bundle output, not a source-text regression assertion. It remains unmodified and must be rechecked by the independent executor after the product fix.

## SDK linker capability probe

Temporary independent `/workspace/work/layout-tests/wrap-probe`: its own C function returns 7, test-only `__wrap_cjt_close` calls `__real_cjt_close` and returns that+1. Manifest `[package] link-option = "--wrap=cjt_close"` and `[ffi.c]` test archive. SDK/CJPM1.2.0, `cjpm build` then `./target/release/bin/main` both succeed; actual result 8 and exit 0. Raw `/workspace/work/layout-tests/wrap-probe.log`. This is linkage validation, not product lifecycle behavior or a product stub.

## Frozen regression consumer

`tests/application-lifecycle` depends on cjtui by ordinary relative path. `run.sh` builds a test-local native wrapper archive, then ordinary `cjpm build`, then directly runs the binary through real util-linux PTYs. Native wrapper calls actual product close first and records its real return before optional failure injection; no test code repairs the terminal. Each case compares actual `stty -g` before/after and requires one close with real return 0. Four q/callback × close-success/failure combinations, Ctrl-C, and resize cover external behavior. Raw unhandled exception output must retain the original callback sentinel and/or restore failure as appropriate. Dual failure has both literal independent expected markers, not product-derived expected text.

Command from clone:

```sh
source /workspace/work/validation/sdk/cangjie/envsetup.sh
CJTUI_UCD_ARCHIVE=/workspace/work/validation/replay-dependencies/UCD-17.0.0.zip \
CJTUI_LIFECYCLE_ARTIFACTS=/workspace/work/layout-tests/lifecycle-red-artifacts \
./tests/run-slice.sh application-lifecycle
```

Ignored repository config uses existing read-only cache and local registry relay, same inputs as TASK054. New test directory ignores generated lock. `node --check tests/application-lifecycle/pty.mjs`, `bash -n tests/application-lifecycle/run.sh tests/run-slice.sh`, and `git diff --check` exit 0. These do not substitute for the pending actual run below.

## Actual baseline result / real RED

Raw `/workspace/work/layout-tests/lifecycle-red.log`: ordinary consumer **build succeeded**, direct PTY harness exit **1**, exactly one failing case. q-success, q-close-failure, callback-success, Ctrl-C-success, and resize-success pass. Dual failure exits nonzero with `terminal restore failed`, but **does not contain CJTUI_CALLBACK_SENTINEL**, triggering `original callback exception remains explicitly observable`. All six cases actually restored exact termios; dual-failure record is `real_result=0 injected=1` exactly once. Thus failure is the missing original exception under dual failure, not a syntax error, missing API, fake backend, invalid terminal setup, or linker failure. Cases continue after this failure, so Ctrl-C/resize results are retained too.

Artifacts `/workspace/work/layout-tests/lifecycle-red-artifacts/<mode>/` retain `session.raw`, `stderr.txt`, before/after, close-record, and result.json. No original failure overwritten. The wrapper's forced error happens after a successful real restore; this tests high-level error handling, not inability of the kernel to restore a TTY. Independent execution of a product fix and ordinary bundle remains required. Earlier full-suite results are not claimed as fresh on this new baseline; existing R8 files and old assertions are unchanged and coordinator's fixed-source executor owns full suite.

Frozen test commit: `e404026408d6fa75b6679c12ebbcc3411d204b3b`, parent `dabd60b8a7216531d37582ff623aa50ed263a1b6`. Final node syntax, bash syntax, and diff-check pass; working tree clean. Main coordinator notified with exact SHA and RED command. No implementation work or product-source changes in this task.

Evidence SHA256:
0dcc56c076220f373ada392fb04b7ee8c5abf294b3cdb03f17b33ede83155c6f  /workspace/work/layout-tests/wrap-probe.log
3f14fa52acda8db5f8248da2e7486aa98a31b3652ea8a047fc58f21d7f30307d  /workspace/work/layout-tests/lifecycle-red.log
c3c43c2089f23fdb918476868f572a01131a42cc78cc1d820125a7e4d4068263  /workspace/work/layout-execution/logs/bundle.log
c60daa622a69c317d5a5ae6e68a42ef4e15dd2374cdb2ffdd2e090d1339b7202  /workspace/work/layout-tests/lifecycle-red-artifacts/callback-close-failure/session.raw

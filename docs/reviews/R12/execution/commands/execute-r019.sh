#!/usr/bin/env bash
set -euo pipefail
source /workspace/work/runtime-execution/env.sh
export CJTUI_RESIZE_ARTIFACTS=/workspace/work/runtime-execution/r019-evidence
export CJTUI_LIFECYCLE_ARTIFACTS=/workspace/work/runtime-execution/r019-evidence/lifecycle
cd /workspace/work/runtime-execution/r019-source
log=/workspace/work/runtime-execution/r019-log.sh
$log root-build cjpm build
$log root-check cjpm check
$log native-session tests/native-session/run.sh
$log resize-coherence tests/resize-coherence/run.sh
$log lifecycle-build bash -c 'gcc -std=c11 -Wall -Wextra -Werror -fPIC -O2 -c tests/application-lifecycle/native/close_wrap.c -o tests/application-lifecycle/native/close_wrap.o && ar rcs tests/application-lifecycle/native/liblifecycle_close.a tests/application-lifecycle/native/close_wrap.o && cd tests/application-lifecycle && cjpm build'
$log lifecycle-resize node tests/application-lifecycle/pty.mjs tests/application-lifecycle/target/release/bin/main resize-success
$log integration-build tests/integration/fixture/build.sh
$log integration-resize node tests/integration/pty.mjs tests/integration/fixture/target/release/bin/main resize
$log bundle cjpm bundle

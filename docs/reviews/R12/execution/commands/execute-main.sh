#!/usr/bin/env bash
set -euo pipefail
source /workspace/work/runtime-execution/env.sh
cd /workspace/work/runtime-execution/source
log=/workspace/work/runtime-execution/run-logged.sh
$log root-check cjpm check
$log runtime-core tests/runtime/run.sh core
$log macro-positive-build bash -c 'cd tests/runtime/macros/positive && cjpm build --target-dir ../target'
$log macro-positive-direct env TERM=dumb COLORTERM= timeout 45s tests/runtime/macros/target/release/bin/main </dev/null
$log runtime-session tests/runtime/session/run.sh
$log runtime-idle-cpu tests/runtime/session/run.sh idle-cpu
$log regressions bash -c 'for mode in contract coordinates colors layout decoration composition application-lifecycle; do ./tests/run-slice.sh "$mode" || exit; done'
$log reactive-build bash -c 'cd examples/reactive && cjpm build'
$log bundle cjpm bundle

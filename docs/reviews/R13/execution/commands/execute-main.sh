#!/usr/bin/env bash
set -euo pipefail
source /workspace/work/dynamic-execution/env.sh
cd /workspace/work/dynamic-execution/source
log=/workspace/work/dynamic-execution/run-logged.sh
$log versions bash -c 'cjc --version; cjpm --version; node --version; gcc --version; date -u +%FT%TZ; uname -a'
$log root-build cjpm build
$log root-check cjpm check
$log dynamic-build bash -c 'cd tests/dynamic && cjpm build'
$log dynamic-direct env TERM=dumb COLORTERM= timeout 45s tests/dynamic/target/release/bin/main </dev/null
$log core-build bash -c 'cd tests/runtime && cjpm build'
$log core-direct env TERM=dumb COLORTERM= timeout 45s tests/runtime/target/release/bin/main </dev/null
$log runtime-session tests/runtime/session/run.sh
$log macro-positive-build bash -c 'cd tests/runtime/macros/positive && cjpm build'
$log macro-positive-direct env TERM=dumb COLORTERM= timeout 45s tests/runtime/macros/positive/target/release/bin/main </dev/null
$log layout tests/run-slice.sh layout
$log decoration tests/run-slice.sh decoration
$log dynamic-example-build bash -c 'cd examples/dynamic && cjpm build'
$log dynamic-example-smoke env TERM=dumb COLORTERM= timeout 45s examples/dynamic/target/release/bin/main --smoke </dev/null
$log bundle cjpm bundle

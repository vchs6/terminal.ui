#!/usr/bin/env bash
set -uo pipefail
source /workspace/work/rich-text-execution/commands/env.sh
cd /workspace/work/rich-text-execution/source
log=/workspace/work/rich-text-execution/commands/run-logged.sh
$log versions bash -c 'cjc --version; cjpm --version; node --version; gcc --version; uname -a'
$log root-build cjpm build
$log root-check cjpm check
$log rich-build bash -c 'cd tests/rich-text && cjpm build'
$log rich-direct env TERM=dumb COLORTERM= timeout 60s tests/rich-text/target/release/bin/main </dev/null
$log dynamic-build bash -c 'cd tests/dynamic && cjpm build'
$log dynamic-direct env TERM=dumb COLORTERM= timeout 45s tests/dynamic/target/release/bin/main </dev/null
$log core-build bash -c 'cd tests/runtime && cjpm build'
$log core-direct env TERM=dumb COLORTERM= timeout 45s tests/runtime/target/release/bin/main </dev/null
$log runtime-session tests/runtime/session/run.sh
$log macro-positive-build bash -c 'cd tests/runtime/macros/positive && cjpm build'
$log macro-positive-direct env TERM=dumb COLORTERM= timeout 45s tests/runtime/macros/positive/target/release/bin/main </dev/null
for slice in contract coordinates layout decoration composition colors; do $log "$slice" tests/run-slice.sh "$slice"; done
$log rich-example-build bash -c 'cd examples/rich-text && cjpm build'
$log rich-example-smoke env TERM=dumb COLORTERM= timeout 45s examples/rich-text/target/release/bin/main --smoke </dev/null
$log bundle cjpm bundle
$log whole-archive-boundary node scripts/check-bundle.mjs target/cjtui-0.0.0.cjp

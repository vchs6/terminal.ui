#!/usr/bin/env bash
set -euo pipefail
source /workspace/work/runtime-execution/env.sh
cd /workspace/work/runtime-execution/source
log=/workspace/work/runtime-execution/run-logged.sh
$log archive-boundary node scripts/check-bundle.mjs target/cjtui-0.0.0.cjp || true
mkdir -p /workspace/work/runtime-execution/clean-product
$log archive-list tar -tzf target/cjtui-0.0.0.cjp
tar -xzf target/cjtui-0.0.0.cjp -C /workspace/work/runtime-execution/clean-product
python3 /workspace/work/runtime-execution/prepare-clean.py
product=$(cat /workspace/work/runtime-execution/clean-product-path)
$log clean-root-build bash -c 'cd "$1" && cjpm build' bash "$product"
$log clean-root-check bash -c 'cd "$1" && cjpm check' bash "$product"
$log clean-core-build bash -c 'cd /workspace/work/runtime-execution/clean-consumers/tests/runtime && cjpm build'
$log clean-core-direct env TERM=dumb COLORTERM= timeout 45s /workspace/work/runtime-execution/clean-consumers/tests/runtime/target/release/bin/main </dev/null
$log clean-macro-positive-build bash -c 'cd /workspace/work/runtime-execution/clean-consumers/tests/runtime/macros/positive && cjpm build'
$log clean-macro-positive-direct env TERM=dumb COLORTERM= timeout 45s /workspace/work/runtime-execution/clean-consumers/tests/runtime/macros/positive/target/release/bin/main </dev/null
$log clean-reactive-build bash -c 'cd "$1/examples/reactive" && cjpm build' bash "$product"
$log clean-reactive-direct node /workspace/work/runtime-execution/clean-reactive-pty.mjs "$product/examples/reactive/target/release/bin/main" /workspace/work/runtime-execution/evidence/clean-reactive-pty

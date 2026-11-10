#!/usr/bin/env bash
set -euo pipefail
source /workspace/work/dynamic-execution/env.sh
cd /workspace/work/dynamic-execution/source
log=/workspace/work/dynamic-execution/run-logged.sh
$log clean-prepare-recheck python3 /workspace/work/dynamic-execution/prepare-clean.py
product=$(cat /workspace/work/dynamic-execution/clean-product-path)
$log clean-root-build bash -c 'cd "$1" && cjpm build' bash "$product"
$log clean-root-check bash -c 'cd "$1" && cjpm check' bash "$product"
$log clean-dynamic-build bash -c 'cd /workspace/work/dynamic-execution/clean-consumers/tests/dynamic && cjpm build'
$log clean-dynamic-direct env TERM=dumb COLORTERM= timeout 45s /workspace/work/dynamic-execution/clean-consumers/tests/dynamic/target/release/bin/main </dev/null
$log clean-example-build bash -c 'cd "$1/examples/dynamic" && cjpm build' bash "$product"
$log clean-example-smoke env TERM=dumb COLORTERM= timeout 45s "$product/examples/dynamic/target/release/bin/main" --smoke </dev/null

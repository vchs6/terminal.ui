#!/usr/bin/env bash
set -euo pipefail
source /workspace/work/rich-text-execution/commands/env.sh
cd /workspace/work/rich-text-execution
log=$PWD/commands/run-logged.sh
$log clean-prepare python3 commands/prepare-clean.py
product=$(cat clean-product-path)
$log clean-root-build bash -c 'cd "$1" && cjpm build' bash "$product"
$log clean-root-check bash -c 'cd "$1" && cjpm check' bash "$product"
$log clean-rich-build bash -c 'cd clean-consumers/tests/rich-text && cjpm build'
$log clean-rich-direct env TERM=dumb COLORTERM= timeout 60s clean-consumers/tests/rich-text/target/release/bin/main </dev/null
$log clean-example-build bash -c 'cd "$1/examples/rich-text" && cjpm build' bash "$product"
$log clean-example-smoke env TERM=dumb COLORTERM= timeout 45s "$product/examples/rich-text/target/release/bin/main" --smoke </dev/null

#!/usr/bin/env bash
set -euo pipefail
source /workspace/work/runtime-execution/env.sh
cd /workspace/work/runtime-execution/r019-source
log=/workspace/work/runtime-execution/r019-log.sh
$log archive-boundary node ../source/scripts/check-bundle.mjs target/cjtui-0.0.0.cjp || true
mkdir -p /workspace/work/runtime-execution/r019-clean
$log archive-list tar -tzf target/cjtui-0.0.0.cjp
tar -xzf target/cjtui-0.0.0.cjp -C /workspace/work/runtime-execution/r019-clean
product=/workspace/work/runtime-execution/r019-clean/cjtui-0.0.0
cp cangjie-repo.toml "$product/cangjie-repo.toml"
cp cangjie-repo.toml "$product/examples/reactive/cangjie-repo.toml"
$log clean-root-build bash -c 'cd "$1" && cjpm build' bash "$product"
$log clean-root-check bash -c 'cd "$1" && cjpm check' bash "$product"
$log clean-abi-build gcc -std=c11 -Wall -Wextra -Werror -O2 "$product/native/cjtui_terminal.c" /workspace/work/runtime-execution/r019-evidence/size_abi_probe.c -Wl,--wrap=ioctl -o /workspace/work/runtime-execution/r019-clean-abi
$log clean-abi-direct /workspace/work/runtime-execution/r019-clean-abi
$log clean-reactive-build bash -c 'cd "$1/examples/reactive" && cjpm build' bash "$product"
$log clean-reactive-direct node /workspace/work/runtime-execution/clean-reactive-pty.mjs "$product/examples/reactive/target/release/bin/main" /workspace/work/runtime-execution/r019-evidence/clean-reactive-pty

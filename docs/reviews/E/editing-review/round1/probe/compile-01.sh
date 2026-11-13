#!/usr/bin/env bash
set -uo pipefail
source /workspace/work/validation/sdk/cangjie/envsetup.sh
cd /workspace/work/editing-review/round1/probe
candidate=/workspace/work/editing-implementation/verification
warm="$candidate/tests/editing/target/release"
args=()
for dir in "$warm"/*/; do args+=(-I "$dir" -L "$dir"); done
args+=(-I /workspace/work/linux-build-recon/stdx-env/linux_x86_64_llvm/static/stdx -L /workspace/work/linux-build-recon/stdx-env/linux_x86_64_llvm/static/stdx)
args+=(-L "$candidate/native" -lunicodedata -lcjtui_terminal -lcjtui_capabilities -lcjtui_glyphs)
cjc main.cj "${args[@]}" -o probe >compile.stdout 2>compile.stderr
status=$?
printf '%s\n' "$status" >compile.exit
exit "$status"

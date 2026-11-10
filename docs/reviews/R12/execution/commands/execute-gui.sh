#!/usr/bin/env bash
set -euo pipefail
source /workspace/work/runtime-execution/env.sh
export CJTUI_TERMINAL_SCENE=example
export CJTUI_SDK_ENV=/workspace/work/validation/sdk/cangjie/envsetup.sh
export CJTUI_TERMINAL_HOST_ROOT=/workspace/work/cross-terminal-recon
export CJTUI_TERMINAL_CAPTURE_DIR=/workspace/work/runtime-execution/evidence/gui-reactive
export CJTUI_TERMINAL_EXAMPLE_BIN=/workspace/work/runtime-execution/source/examples/reactive/target/release/bin/main
/workspace/work/runtime-execution/run-logged.sh gui-reactive-command /workspace/work/runtime-execution/gui-reactive.sh xterm-default xfce-vte
/workspace/work/runtime-execution/run-logged.sh gui-reactive-raw-check python3 /workspace/work/runtime-execution/verify-reactive-raw.py

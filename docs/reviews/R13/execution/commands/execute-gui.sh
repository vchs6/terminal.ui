#!/usr/bin/env bash
set -euo pipefail
source /workspace/work/dynamic-execution/env.sh
export CJTUI_TERMINAL_SCENE=example
export CJTUI_SDK_ENV=/workspace/work/validation/sdk/cangjie/envsetup.sh
export CJTUI_TERMINAL_HOST_ROOT=/workspace/work/cross-terminal-recon
export CJTUI_TERMINAL_CAPTURE_DIR=/workspace/work/dynamic-execution/evidence/gui-dynamic
export CJTUI_TERMINAL_EXAMPLE_BIN=/workspace/work/dynamic-execution/source/examples/dynamic/target/release/bin/main
/workspace/work/dynamic-execution/run-logged.sh gui-dynamic-command /workspace/work/dynamic-execution/gui-dynamic.sh xterm-default xfce-vte

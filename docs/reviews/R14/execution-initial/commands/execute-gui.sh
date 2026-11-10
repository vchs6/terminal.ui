#!/usr/bin/env bash
set -euo pipefail
source /workspace/work/rich-text-execution/commands/env.sh
export CJTUI_TERMINAL_SCENE=example
export CJTUI_SDK_ENV=/workspace/work/validation/sdk/cangjie/envsetup.sh
export CJTUI_TERMINAL_HOST_ROOT=/workspace/work/cross-terminal-recon
export CJTUI_TERMINAL_CAPTURE_DIR=/workspace/work/rich-text-execution/evidence/gui-rich
export CJTUI_PACKAGED_ROOT=$(cat /workspace/work/rich-text-execution/clean-product-path)
export CJTUI_TERMINAL_EXAMPLE_BIN=$CJTUI_PACKAGED_ROOT/examples/rich-text/target/release/bin/main
cd /workspace/work/rich-text-execution
commands/run-logged.sh gui-rich-command commands/gui-rich.sh xterm-default xfce-vte

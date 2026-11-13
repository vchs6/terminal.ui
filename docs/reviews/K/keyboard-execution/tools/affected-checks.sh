#!/usr/bin/env bash
set -euo pipefail
source /workspace/work/keyboard-execution/env.sh
export CJTUI_LIFECYCLE_ARTIFACTS=/workspace/work/keyboard-execution/raw/application-lifecycle/artifacts
python3 /workspace/work/keyboard-execution/tools/run-phase.py application-lifecycle /workspace/work/keyboard-execution/source bash tests/run-slice.sh application-lifecycle
export CJTUI_RUNTIME_ARTIFACTS=/workspace/work/keyboard-execution/raw/runtime-session/artifacts
python3 /workspace/work/keyboard-execution/tools/run-phase.py runtime-session /workspace/work/keyboard-execution/source bash tests/runtime/run.sh session
mkdir -p /workspace/work/keyboard-execution/raw/integration-originals
export TMPDIR=/workspace/work/keyboard-execution/raw/integration-originals
python3 /workspace/work/keyboard-execution/tools/run-phase.py integration /workspace/work/keyboard-execution/source bash tests/run-slice.sh integration

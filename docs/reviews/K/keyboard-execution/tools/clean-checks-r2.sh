#!/usr/bin/env bash
set -euo pipefail
source /workspace/work/keyboard-execution/env.sh
base=/workspace/work/keyboard-execution
python3 "$base/tools/run-phase.py" package-audit-command-r2 "$base" python3 tools/package-audit.py
python3 "$base/tools/run-phase.py" clean-preparation "$base" python3 tools/prepare-clean.py
python3 "$base/tools/run-phase.py" clean-keyboard-build "$base/clean-consumers/keyboard" cjpm build
python3 "$base/tools/run-phase.py" clean-keyboard-run "$base/clean-consumers/keyboard" ./target/release/bin/main
python3 "$base/tools/run-phase.py" clean-dispatch-build "$base/clean-consumers/dispatch" cjpm build
python3 "$base/tools/run-phase.py" clean-dispatch-run "$base/clean-consumers/dispatch" ./target/release/bin/main
python3 "$base/tools/run-phase.py" clean-example-build "$base/clean-unpacked/cjtui-0.0.0/examples/keyboard" cjpm build
python3 "$base/tools/run-phase.py" clean-example-run "$base" python3 tools/example-pty.py clean-unpacked/cjtui-0.0.0/examples/keyboard/target/release/bin/main raw/clean-example-run/artifacts

#!/usr/bin/env bash
set -euo pipefail
task_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
# Pure driver controls in a temporary Git fixture borrowing actual objects.
# Sentinel compiler always fails95; sentinel binary must NEVER run.
exec python3 "$task_dir/gate_selftest.py"

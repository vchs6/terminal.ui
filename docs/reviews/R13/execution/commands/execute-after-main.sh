#!/usr/bin/env bash
set -euo pipefail
while test ! -e /workspace/work/dynamic-execution/evidence/bundle/exit; do sleep 1; done
test "$(cat /workspace/work/dynamic-execution/evidence/bundle/exit)" = 0
/workspace/work/dynamic-execution/execute-clean.sh

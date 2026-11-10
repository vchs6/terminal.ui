#!/usr/bin/env bash
set -euo pipefail
for ((n=0;n<1800;n++)); do
 if test -f /workspace/work/rich-text-execution/evidence/bundle/exit; then
  test "$(cat /workspace/work/rich-text-execution/evidence/bundle/exit)" = 0
  exec /workspace/work/rich-text-execution/commands/execute-clean.sh
 fi
 sleep 1
done
printf 'timed out waiting for bundle\n' >&2
exit 2

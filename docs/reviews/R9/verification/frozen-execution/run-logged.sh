#!/usr/bin/env bash
set -u
stage="$1"
shift
base=/workspace/work/layout-execution
printf '%q ' "$@" > "$base/logs/$stage.command"
printf '\n' >> "$base/logs/$stage.command"
pwd > "$base/logs/$stage.cwd"
start="$(date -u +%FT%TZ)"
"$@" > "$base/logs/$stage.log" 2>&1
code=$?
end="$(date -u +%FT%TZ)"
printf '%s\n' "$code" > "$base/logs/$stage.exit"
printf '%s %s %s exit=%s\n' "$stage" "$start" "$end" "$code" >> "$base/logs/timeline.txt"
cat "$base/logs/$stage.log"
exit "$code"

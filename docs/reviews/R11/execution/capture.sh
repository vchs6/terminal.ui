#!/usr/bin/env bash
set -uo pipefail
label=${1:?label required}
shift
out=/workspace/work/frame-execution/raw/$label
mkdir -p "$(dirname "$out")"
printf '%s\n' "$PWD" > "$out.cwd"
printf '%q ' "$@" > "$out.command"
printf '\n' >> "$out.command"
date -u +%FT%TZ > "$out.start"
"$@" > "$out.stdout" 2> "$out.stderr"
status=$?
printf '%s\n' "$status" > "$out.actualexit"
date -u +%FT%TZ > "$out.end"
exit "$status"

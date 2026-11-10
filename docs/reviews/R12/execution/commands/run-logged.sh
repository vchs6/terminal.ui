#!/usr/bin/env bash
set -uo pipefail
name=$1; shift
out=/workspace/work/runtime-execution/evidence/$name
mkdir -p "$out"
date -u +%FT%TZ > "$out/start"
printf '%q ' "$@" > "$out/command"; printf '\n' >> "$out/command"
"$@" > "$out/stdout" 2> "$out/stderr"
status=$?
printf '%s\n' "$status" > "$out/exit"
date -u +%FT%TZ > "$out/end"
echo "$name exit=$status"
exit "$status"

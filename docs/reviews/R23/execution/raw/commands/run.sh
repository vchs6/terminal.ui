#!/usr/bin/env bash
set -u
base=/workspace/work/glyph-advance-execution
label=$1; shift
out=$base/raw/$label
mkdir -p "$out"
printf '%q ' "$@" > "$out/command"; printf '\n' >> "$out/command"
pwd > "$out/cwd"
date -u +%FT%TZ > "$out/start"
"$@" > "$out/stdout" 2> "$out/stderr"
status=$?
printf '%s\n' "$status" > "$out/exit"
date -u +%FT%TZ > "$out/end"
printf '%s exit=%s\n' "$label" "$status"
exit "$status"

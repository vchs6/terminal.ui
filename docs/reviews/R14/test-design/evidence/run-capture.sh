#!/usr/bin/env bash
set -u
name="$1"; shift
base=/workspace/work/rich-text-tests/evidence
{ date -u +%FT%TZ; printf 'cwd=%s\n' "$PWD"; printf 'command='; printf '%q ' "$@"; printf '\n'; git rev-parse HEAD; git status --short; } > "$base/$name.meta"
"$@" > "$base/$name.stdout" 2> "$base/$name.stderr"
result=$?
printf '%s\n' "$result" > "$base/$name.exit"
date -u +%FT%TZ >> "$base/$name.meta"
exit "$result"

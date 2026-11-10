#!/usr/bin/env bash
set -u
name=$1; shift
base=/workspace/work/auto-final-execution
log=$base/raw/$name.log
meta=$base/raw/$name.meta
{
  printf 'start_utc=%s\n' "$(date -u +%FT%TZ)"
  printf 'cwd=%s\n' "$PWD"
  printf 'source_commit=%s\n' "$(git rev-parse HEAD 2>/dev/null || true)"
  printf 'command='; printf '%q ' "$@"; printf '\n'
  printf 'model=GPT-6.1 Sol\nreasoning=medium\n'
  printf 'scope=independent execution; env.sh; private writable dependency cache; SDK 1.2.0\n'
} > "$meta"
"$@" > "$log" 2>&1
result=$?
printf 'end_utc=%s\nactual_exit=%s\n' "$(date -u +%FT%TZ)" "$result" >> "$meta"
printf '%s actual_exit=%s log=%s\n' "$name" "$result" "$log"
exit "$result"

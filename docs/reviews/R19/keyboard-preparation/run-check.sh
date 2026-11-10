#!/usr/bin/env bash
set -u
name=$1
shift
directory=/workspace/work/keyboard-tests/evidence
date -u +%FT%TZ > "$directory/$name.started"
pwd > "$directory/$name.cwd"
printf '%q ' "$@" > "$directory/$name.command"
printf '\n' >> "$directory/$name.command"
"$@" > "$directory/$name.stdout" 2> "$directory/$name.stderr"
status=$?
printf '%s\n' "$status" > "$directory/$name.exit"
date -u +%FT%TZ > "$directory/$name.ended"
exit "$status"

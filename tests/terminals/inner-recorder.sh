#!/bin/sh
set -eu
: "${TASK066_INNER_STATE:?}" "${TASK066_FIXTURE:?}"
record() { printf '%s_size=%s\n%s_termios=%s\n' "$1" "$(stty size)" "$1" "$(stty -g)" >> "$TASK066_INNER_STATE"; }
: > "$TASK066_INNER_STATE"
record ready
trap 'record exit; exit 130' HUP INT TERM
set +e
"$TASK066_FIXTURE"
status=$?
set -e
record exit
printf 'exit_status=%s\n' "$status" >> "$TASK066_INNER_STATE"
exit "$status"

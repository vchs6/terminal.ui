#!/bin/sh
set -eu
: "${TASK066_OUTER_RAW:?}" "${TASK066_INNER_RAW:?}" "${TASK066_INNER_STATE:?}" "${TASK066_FIXTURE:?}" "${TASK066_INNER_RUNNER:?}"
record() { printf '%s_size=%s\n%s_termios=%s\n' "$1" "$(stty size)" "$1" "$(stty -g)" >> "$TASK066_OUTER_RAW"; }
: > "$TASK066_OUTER_RAW"
record ready
printf 'TERM=%s\nCOLORTERM=%s\ntty=%s\n' "${TERM-}" "${COLORTERM-}" "$(tty)" >> "$TASK066_OUTER_RAW"
set +e
script --quiet --flush --return --log-out "$TASK066_INNER_RAW" --command "/bin/sh $TASK066_INNER_RUNNER"
status=$?
set -e
record exit
printf 'exit_status=%s\n' "$status" >> "$TASK066_OUTER_RAW"
exit "$status"

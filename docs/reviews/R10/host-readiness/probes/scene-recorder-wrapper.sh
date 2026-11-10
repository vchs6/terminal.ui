#!/bin/sh
set -eu

: "${TASK065_OUTER_RAW:?set outer raw output}"
: "${TASK065_ANSI_RAW:?set ANSI raw output}"

outer_file=$TASK065_OUTER_RAW

record_outer() {
    printf 'outer_%s_tty_size=%s\n' "$1" "$(stty size)" >> "$outer_file"
    printf 'outer_%s_termios=%s\n' "$1" "$(stty -g)" >> "$outer_file"
}

on_termination() {
    record_outer termination
    exit 0
}

: > "$outer_file"
record_outer ready
printf 'outer_TERM=%s\n' "${TERM-}" >> "$outer_file"
trap on_termination HUP INT TERM
trap 'record_outer exit' EXIT

script --quiet --flush --return --log-out "$TASK065_ANSI_RAW" \
    --command '/bin/sh /workspace/work/cross-terminal-recon/probes/scene-control.sh'

#!/bin/sh
set -eu

: "${TASK065_CONTROL_RAW:?set a per-run raw output path}"
raw_file=$TASK065_CONTROL_RAW

record_termios() {
    stty -g
}

on_termination() {
    printf 'termination_termios=%s\n' "$(record_termios)" >> "$raw_file"
    exit 0
}

on_winch() {
    size=$(stty size)
    printf 'resize_ack=%s\n' "$size" >> "$raw_file"
    printf 'resize_termios=%s\n' "$(record_termios)" >> "$raw_file"
    printf 'SIGWINCH child TTY size: %s\n' "$size"
}

trap on_winch WINCH
trap on_termination HUP INT TERM
: 'The EXIT trap records a normal inner-app completion as well.'
trap 'printf "exit_termios=%s\\n" "$(record_termios)" >> "$raw_file"' EXIT
: > "$raw_file"
initial_size=$(stty size)
printf 'host_label=%s\n' "${TASK065_HOST_LABEL-unknown}" >> "$raw_file"
printf 'ready_tty_size=%s\n' "$initial_size" >> "$raw_file"
printf 'ready_termios=%s\n' "$(record_termios)" >> "$raw_file"
printf 'TERM=%s\n' "${TERM-}" >> "$raw_file"
printf 'COLORTERM=%s\n' "${COLORTERM-}" >> "$raw_file"

printf '\033[1;36mTASK065 X11 control probe: %s\033[0m\n' "${TASK065_HOST_LABEL-unknown}"
printf 'ready child TTY size: %s; TERM=%s\n' "$initial_size" "${TERM-}"
printf 'awaiting XTEST key input and X11 resize\n'

while :; do
    if IFS= read -r line; then
        now_size=$(stty size)
        printf 'input_ack=%s size=%s\n' "$line" "$now_size" >> "$raw_file"
        printf 'XTEST input ACK: %s; child TTY size: %s\n' "$line" "$now_size"
        if [ "$line" = q ]; then
            exit 0
        fi
    fi
done

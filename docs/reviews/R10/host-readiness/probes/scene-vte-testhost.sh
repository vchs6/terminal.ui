#!/bin/sh
set -eu

raw_dir=/workspace/work/cross-terminal-recon/raw
child_size=$(stty size)
{
    printf 'host=task065-vte-testhost\n'
    printf 'engine=VTE\n'
    printf 'child_tty_size=%s\n' "$child_size"
    printf 'TERM=%s\n' "${TERM-}"
    printf 'COLORTERM=%s\n' "${COLORTERM-}"
} > "$raw_dir/vte-testhost-child.txt"

printf '\033[1;36mTASK065: explicit VTE testhost\033[0m\n'
printf '\033]0;TASK065 explicit VTE testhost\007'
printf '\033[31mred\033[0m  \033[4munderline\033[0m  \033[7minverse\033[0m\n'
printf 'child TTY size: %s; TERM=%s\n' "$child_size" "${TERM-}"
printf 'grid query runs in vte-testhost.c\n'
sleep 12

#!/bin/sh
set -eu

raw_dir=/workspace/work/cross-terminal-recon/raw
child_size=$(stty size)
{
    printf 'host=xterm\n'
    printf 'engine=xterm\n'
    printf 'child_tty_size=%s\n' "$child_size"
    printf 'TERM=%s\n' "${TERM-}"
    printf 'COLORTERM=%s\n' "${COLORTERM-}"
    printf 'TERM_PROGRAM=%s\n' "${TERM_PROGRAM-}"
} > "$raw_dir/xterm-actual-child.txt"

printf '\033[1;36mTASK065: xterm actual host\033[0m\n'
printf '\033[31mred\033[0m  \033[4munderline\033[0m  \033[7minverse\033[0m\n'
printf 'child TTY size: %s; TERM=%s\n' "$child_size" "${TERM-}"
printf 'scene source: probes/scene-xterm.sh\n'
sleep 20

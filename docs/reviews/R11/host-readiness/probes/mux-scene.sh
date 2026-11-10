#!/bin/sh
set -eu
base=/workspace/work/linux-console-hosts
log="$base/raw/$MUX_HOST-child.log"
saved=$(stty -g)
{
 printf 'host=%s tty=%s TERM=%s COLORTERM=%s\n' "$MUX_HOST" "$(tty)" "$TERM" "${COLORTERM-}"
 printf 'ready_grid='; stty size
 printf 'termios_before=%s\n' "$saved"
} >"$log"
printf '\033[2J\033[H%s actual multiplexer readiness\r\n\033[1;36mcyan bold\033[0m \033[31mred\033[0m \033[4munderline\033[0m \033[7minverse\033[0m\r\n' "$MUX_HOST"
stty -echo -icanon min 1 time 0
printf 'READY\n' >>"$log"
while :; do
 key=$(dd bs=1 count=1 2>/dev/null)
 printf 'INPUT=%s\n' "$key" >>"$log"
 printf 'keyboard=%s\r\n' "$key"
 test "$key" = q && break
done
stty "$saved"
printf 'termios_after=%s\n' "$(stty -g)" >>"$log"
printf 'EXIT=0\n' >>"$log"

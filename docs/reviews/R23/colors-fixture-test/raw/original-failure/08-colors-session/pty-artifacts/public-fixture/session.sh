#!/bin/sh
stty rows 6 cols 32
stty -g > "$2/before"
tty > "$2/tty"
"$1" < /dev/tty &
p=$!
echo "$p" > "$2/pid"
wait "$p"
status=$?
stty -g > "$2/after"
exit "$status"

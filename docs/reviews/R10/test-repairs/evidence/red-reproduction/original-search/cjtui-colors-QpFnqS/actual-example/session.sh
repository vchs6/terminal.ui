#!/bin/sh
stty rows 40 cols 100
stty -g > "$2/before"
tty > "$2/tty"
"$1" < /dev/tty &
p=$!
echo "$p" > "$2/pid"
wait "$p"
status=$?
stty -g > "$2/after"
exit "$status"

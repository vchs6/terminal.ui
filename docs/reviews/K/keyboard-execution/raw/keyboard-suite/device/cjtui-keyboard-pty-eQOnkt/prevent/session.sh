#!/bin/sh
stty rows 5 cols 40
stty -g > "$2/before"
"$1" < /dev/tty &
p=$!
echo "$p" > "$2/pid"
wait "$p"
status=$?
stty -g > "$2/after"
exit "$status"

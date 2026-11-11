#!/bin/sh
stty rows 8 cols 5
stty -g > "$2/before"
"$1" < /dev/tty &
p=$!
echo "$p" > "$2/pid"
wait "$p"
r=$?
stty -g > "$2/after"
exit "$r"

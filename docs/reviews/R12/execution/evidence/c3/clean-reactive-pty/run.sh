#!/bin/sh
stty rows 8 cols 48
stty -g > "$2/before"
tty > "$2/tty"
"$1" < /dev/tty
status=$?
stty -g > "$2/after"
exit "$status"

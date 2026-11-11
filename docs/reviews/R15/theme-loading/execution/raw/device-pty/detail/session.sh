#!/bin/sh
stty rows 3 cols 20
date -u +%FT%TZ > "$2/utc-before"
stty size > "$2/grid"
stty -g > "$2/before"
tty > "$2/tty"
"$1"
status=$?
stty -g > "$2/after"
echo "$status" > "$2/exit"
date -u +%FT%TZ > "$2/utc-after"
exit "$status"

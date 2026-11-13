#!/bin/sh
if [ "$CJTUI_RUNTIME_MODE" = idle-cpu ]; then stty rows 256 cols 512; else stty rows 5 cols 24; fi
stty -g > "$2/before"
"$1" < /dev/tty &
p=$!
echo "$p" > "$2/pid"
wait "$p"
status=$?
stty -g > "$2/after"
exit "$status"

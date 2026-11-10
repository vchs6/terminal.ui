#!/bin/sh
stty rows 8 cols 100
stty -g > "$2/before"
"$1"
status=$?
stty -g > "$2/after"
exit "$status"

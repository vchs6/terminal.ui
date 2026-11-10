#!/bin/sh
/workspace/work/cursor-capability-recon/packages/cursor-probe "$CURSOR_RUN" "$CURSOR_STATE" gui
status=$?
printf '%s\n' "$status" > "$CURSOR_RUN/fixture-exit.txt"
while test ! -e "$CURSOR_RUN/ack-exit"; do sleep .05; done
exit "$status"

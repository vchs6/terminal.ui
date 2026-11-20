#!/usr/bin/env python3
"""Parameterize existing recorder only for same-endpoint existing host probes."""
import os,pathlib,sys
assert os.environ.get('C008_ROOT_ACTUAL_GO')=='1'
source=pathlib.Path(os.environ['C008_SOURCE'])/'tests/terminals/inner-recorder.sh';text=source.read_text()
helper=pathlib.Path(__file__).resolve().parent
before='set +e\n"$TASK066_FIXTURE"\nstatus=$?'
after='''python3 "$C008_HOST_PROBE" "$C008_OUT/cursor-before.json"
date -u +%FT%TZ > "$C008_OUT/app-start.utc"
set +e
"$TASK066_FIXTURE" < /dev/tty &
app_pid=$!
printf '%s\\n' "$app_pid" > "$C008_OUT/app.pid"
python3 "$C008_PID_RECORDER" "$app_pid" "$C008_OUT/app-identity.json"
wait "$app_pid"
status=$?'''
assert text.count(before)==1;text=text.replace(before,after)
needle='record exit\nprintf \'exit_status=%s\\n\' "$status"'
replacement='''record exit
date -u +%FT%TZ > "$C008_OUT/app-exit.utc"
printf '%s\\n' "$status" > "$C008_OUT/app.exit"
python3 "$C008_HOST_PROBE" "$C008_OUT/cursor-after.json"
printf 'exit_status=%s\\n' "$status"'''
assert text.count(needle)==1;text=text.replace(needle,replacement)
pathlib.Path(sys.argv[1]).write_text(text)

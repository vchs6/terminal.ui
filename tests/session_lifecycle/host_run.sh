#!/usr/bin/env bash
# Run inside the named actual terminal host. script forwards that host's real
# replies and records child PTY traffic; it does not manufacture replies.
set -euo pipefail
[[ ${CJTUI_020_ROOT_GO:-} == 1 && -f ${CJTUI_020_ADMISSION:-} ]]
[[ $# == 3 ]] || { echo 'usage: host_run.sh BINARY NEW_OUT CASE' >&2; exit 2; }
export CJTUI_020_BINARY=$(realpath "$1")
export CJTUI_020_OUTPUT=$(realpath -m "$2")
export CJTUI_020_CASE=$3
# Normal host integration keeps default Auto; title stress is explicit opt-in.
export CJTUI_020_HOST_AUTO=1
if [[ ${CJTUI_020_HOST_TITLE_STRESS:-0} == 1 ]]; then export CJTUI_020_HOST_AUTO=0; fi
mkdir "$CJTUI_020_OUTPUT"
export CJTUI_SESSION_NATIVE="$CJTUI_020_OUTPUT/native.tsv"
case "$3" in close|callback-close) export CJTUI_SESSION_CLOSE_FAIL=1;; *) export CJTUI_SESSION_CLOSE_FAIL=0;; esac
here=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
python "$here/host_probe.py" "$CJTUI_020_OUTPUT/host-before.json"
# Ambient script endpoint only. Application child proof comes from native
# snapshots before open/after each close, required by host_verify.py.
stty -g > "$CJTUI_020_OUTPUT/outer-termios-before"
stty size > "$CJTUI_020_OUTPUT/geometry"
sha256sum "$CJTUI_020_BINARY" > "$CJTUI_020_OUTPUT/binary.sha256"
date -u +%FT%TZ > "$CJTUI_020_OUTPUT/start.utc"
command='printf "%s\n" "$$" > "$CJTUI_020_OUTPUT/pid"; exec "$CJTUI_020_BINARY"'
set +e
script --quiet --return --flush --log-out "$CJTUI_020_OUTPUT/wire.bin" --log-in "$CJTUI_020_OUTPUT/input.bin" --log-timing "$CJTUI_020_OUTPUT/timing" --command "$command"
result=$?
set -e
printf '%s\n' "$result" > "$CJTUI_020_OUTPUT/direct.exit"
stty -g > "$CJTUI_020_OUTPUT/outer-termios-after"
cmp "$CJTUI_020_OUTPUT/outer-termios-before" "$CJTUI_020_OUTPUT/outer-termios-after"
python "$here/host_probe.py" "$CJTUI_020_OUTPUT/host-after.json"
if [[ $result == 0 ]]; then
    python "$here/host_verify.py" --output "$CJTUI_020_OUTPUT" --case "$CJTUI_020_CASE"
fi
exit "$result"

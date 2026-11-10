#!/usr/bin/env bash
# Private real-host child entry; no X server, clipboard, mux or SSH setup here.
set -euo pipefail
if [[ $# -lt 2 || $# -gt 4 ]]; then
    echo 'usage: host-consumer.sh /absolute/normal-consumer /absolute/NEW-dir [Direct|TmuxPassthrough|ScreenPassthrough] [auto|declared]' >&2
    exit 2
fi
binary=$(realpath "$1")
artifacts=$2
route=${3:-Direct}
stack=${4:-auto}
case "$route" in Direct|TmuxPassthrough|ScreenPassthrough) ;; *) exit 2;; esac
case "$stack" in auto) declare_stack=0;; declared) declare_stack=1;; *) exit 2;; esac
[[ -x "$binary" && "$artifacts" = /* && -t 0 && -t 1 ]]
mkdir "$artifacts"
date -u '+%Y-%m-%dT%H:%M:%SZ' > "$artifacts/started.utc"
printf '%s\n' "$binary" > "$artifacts/binary.path"
sha256sum "$binary" > "$artifacts/binary.sha256"
printf 'TERM=%s\nCOLORTERM=%s\nTMUX=%s\nSTY=%s\nroute=%s\nstack=%s\n' "${TERM:-}" "${COLORTERM:-}" "${TMUX:-}" "${STY:-}" "$route" "$stack" > "$artifacts/environment.txt"
tty > "$artifacts/tty"
stty size > "$artifacts/grid"
stty -g > "$artifacts/before"
set +e
CJTUI_SESSION_CASE="${CJTUI_SESSION_HOST_SCENARIO:-host}" CJTUI_SESSION_ROUTE="$route" CJTUI_SESSION_DECLARE_STACK="$declare_stack" CJTUI_SESSION_RESULTS="$artifacts/results.tsv" CJTUI_SESSION_NATIVE="$artifacts/native.tsv" CJTUI_SESSION_WIRE="$artifacts/wire.bin" CJTUI_SESSION_ALL_WIRE="$artifacts/all-wire.bin" "$binary"
status=$?
set -e
stty -g > "$artifacts/after"
printf '%s\n' "$status" > "$artifacts/exit"
date -u '+%Y-%m-%dT%H:%M:%SZ' > "$artifacts/finished.utc"
exit "$status"

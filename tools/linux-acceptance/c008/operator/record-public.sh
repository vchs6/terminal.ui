#!/usr/bin/env bash
# External recorder; run INSIDE the actual owned host, after root admission.
set -euo pipefail
[[ ${C008_ROOT_ACTUAL_GO:-} == 1 ]] || { echo 'NOTEXECUTED: root actual GO required' >&2; exit 2; }
: "${C008_147_ADMISSION:?}" "${C008_PROVENANCE:?}" "${C008_BINARY:?}" "${C008_OUT:?}" "${C008_SOURCE:?}"
[[ -f $C008_147_ADMISSION && -f $C008_PROVENANCE && -x $C008_BINARY && -d $C008_SOURCE ]]
[[ $C008_BINARY = /* && $C008_OUT = /* && $C008_SOURCE = /* ]]
mkdir "$C008_OUT"
export TASK066_FIXTURE=$C008_BINARY TASK066_INNER_STATE=$C008_OUT/inner-state.txt
export TASK066_INNER_RUNNER=$C008_SOURCE/tests/terminals/inner-recorder.sh
export TASK066_OUTER_RAW=$C008_OUT/outer-state.txt TASK066_INNER_RAW=$C008_OUT/ansi.raw
[[ -f $TASK066_INNER_RUNNER ]]
operator_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
export C008_SESSION_DIR=$(dirname -- "$C008_OUT")
export C008_HOST_PROBE="$C008_SOURCE/tests/session_lifecycle/host_probe.py"
export C008_PID_RECORDER="$operator_dir/owned-process.py"
python3 "$operator_dir/derive-inner-evidence.py" "$C008_OUT/inner-evidence-recorder.sh"
export TASK066_INNER_RUNNER="$C008_OUT/inner-evidence-recorder.sh"
printf '%s\n' "${C008_HOST_ID:?}" > "$C008_OUT/host-label.txt"
date -u +%FT%TZ > "$C008_OUT/start.utc"
sha256sum "$C008_BINARY" "$C008_147_ADMISSION" "$C008_PROVENANCE" "$TASK066_INNER_RUNNER" > "$C008_OUT/inputs.sha256"
# No TERM override, protocol response, clipboard read, or success oracle.
record() { printf '%s_size=%s\n%s_termios=%s\n' "$1" "$(stty size)" "$1" "$(stty -g)" >> "$TASK066_OUTER_RAW"; }
record ready
printf 'TERM=%s\nCOLORTERM=%s\ntty=%s\n' "${TERM-}" "${COLORTERM-}" "$(tty)" >> "$TASK066_OUTER_RAW"
set +e
script --quiet --flush --return --log-out "$TASK066_INNER_RAW" --log-in "$C008_OUT/input.raw" --log-timing "$C008_OUT/timing" --command '/bin/sh "$TASK066_INNER_RUNNER"'
status=$?
set -e
record exit
printf '%s\n' "$status" > "$C008_OUT/direct.exit"
date -u +%FT%TZ > "$C008_OUT/end.utc"
exit "$status"

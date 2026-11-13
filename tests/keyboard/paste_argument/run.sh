#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
cjpm build
status=0
for selected in c1-byte-budget ctrl-text; do
    if CJTUI_KEYBOARD_ARGUMENT_CASE="$selected" ./target/release/bin/main; then result=0; else result=$?; status=1; fi
    printf '%s actual exit=%s\n' "$selected" "$result"
done
if [[ -n "${CJTUI_KEYBOARD_ARGUMENT_ARTIFACTS:-}" ]]; then
    output=$CJTUI_KEYBOARD_ARGUMENT_ARTIFACTS
else
    parent=$(mktemp -d)
    output=$parent/native
fi
if python3 native_pty.py --binary target/release/bin/main --output "$output"; then result=0; else result=$?; status=1; fi
printf 'paste-native actual driver exit=%s output=%s\n' "$result" "$output"
exit "$status"

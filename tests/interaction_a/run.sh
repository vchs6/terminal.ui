#!/usr/bin/env bash
set -euo pipefail
here=$(cd "$(dirname "$0")" && pwd)
output=${CJTUI_INTERACTION_A_OUTPUT:-/tmp/cjtui-interaction-a}
mkdir -p "$output"
if [[ ${1:-} == --fixtures-only ]]; then
    python3 "$here/fixtures/selftest.py" --output "$output/native-selftest"
    exit 0
fi
(cd "$here" && cjpm build)
# Direct binary exit is authoritative. Do not replace with cjpm run.
TERM=dumb COLORTERM= timeout 90s "$here/target/release/bin/main" </dev/null
if [[ ${1:-} == --device ]]; then
    python3 "$here/fixtures/device.py" --binary "$here/target/release/bin/main" --output "$output/device"
fi

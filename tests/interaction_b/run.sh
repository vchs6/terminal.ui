#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/../.."
output=${CJTUI_VIEWPORT_EVIDENCE:-/tmp/cjtui-viewport-evidence}
if [[ ${1:-} == --fixture-controls ]]; then
    python3 tests/interaction_b/device_sequences.py --self-test
    exit 0
fi
if [[ ${1:-} == --prerequisites ]]; then
    (cd tests/interaction_b/prerequisites && cjpm build)
    tests/interaction_b/prerequisites/target/release/bin/main
    exit 0
fi
(cd tests/interaction_b && cjpm build)
if [[ ${1:-} == --review-regressions ]]; then
    status=0
    for name in I01 I02 I03 I04 I05 I06 I07; do
        if CJTUI_VIEWPORT_REVIEW="$name" timeout 60s tests/interaction_b/target/release/bin/main </dev/null; then :; else status=1; fi
    done
    exit "$status"
elif [[ ${1:-} == --device ]]; then
    python3 tests/interaction_b/pty_driver.py --binary tests/interaction_b/target/release/bin/main --output "$output/basic"
    python3 tests/interaction_b/device_sequences.py --binary tests/interaction_b/target/release/bin/main --output "$output/sequences"
elif [[ ${1:-} == --resource ]]; then
    time_bin=${CJTUI_TIME_BIN:-/usr/bin/time}
    CJTUI_VIEWPORT_CASE=resource TERM=dumb COLORTERM= "$time_bin" -v timeout 60s tests/interaction_b/target/release/bin/main </dev/null
else
    TERM=dumb COLORTERM= timeout 60s tests/interaction_b/target/release/bin/main </dev/null
fi

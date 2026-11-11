#!/usr/bin/env bash
set -euo pipefail
here=$(cd "$(dirname "$0")" && pwd)
output=${CJTUI_INTERACTION_A_OUTPUT:-/tmp/cjtui-interaction-a}
mkdir -p "$output"
if [[ ${1:-} == --fixtures-only ]]; then
    python3 "$here/fixtures/selftest.py" --output "$output/native-selftest"
    exit 0
fi
if [[ ${1:-} == --changed-fixtures-only ]]; then
    python3 "$here/fixtures/final_selftest.py" --output "$output/changed-fixtures"
    exit 0
fi
# Current, actual 080/084/088/152 consumer and current-only device error helper.
if [[ ${1:-} != --review-regressions ]]; then
cp "$here/src/device_failure.cj" "$here/prerequisites/src/device_failure.cj"
if [[ -f "$here/cangjie-repo.toml" ]]; then cp "$here/cangjie-repo.toml" "$here/prerequisites/cangjie-repo.toml"; fi
(cd "$here/prerequisites" && cjpm build)
"$here/prerequisites/target/release/bin/main"
if [[ ${1:-} == --prerequisites ]]; then exit 0; fi
fi
if [[ ${1:-} == --matrix || ${1:-} == --review-regressions ]]; then
    # Isolated ordinary consumer copy: same formal Cj bytes, manifest only
    # adjusts its library path and links the existing test-only clock seam.
    wrapped="$here/.wrapped"
    mkdir -p "$wrapped/src"
    cp "$here/src/"*.cj "$wrapped/src/"
    cc -std=c11 -Wall -Wextra -Werror -O2 -c "$here/native/clock_wrap.c" -o "$output/clock-wrap.o"
    python3 - "$here" "$wrapped" "$output" <<'PY'
from pathlib import Path
import sys
here,wrapped,output=map(Path,sys.argv[1:])
manifest=(here/'cjpm.toml').read_text().replace('path = "../.."','path = "../../.."').replace('link-option = ""','link-option = "'+str((output/'clock-wrap.o').resolve())+' --wrap=cjt_monotonic_ms"')
(wrapped/'cjpm.toml').write_text(manifest)
config=here/'cangjie-repo.toml'
if config.exists():(wrapped/config.name).write_bytes(config.read_bytes())
PY
    (cd "$wrapped" && cjpm build)
    if [[ ${1:-} == --review-regressions ]]; then
        review_args=()
        if [[ ${2:-} == --clock-transition-only ]]; then review_args+=(--clock-transition-only); fi
        python3 "$here/fixtures/review_regressions.py" --binary "$wrapped/target/release/bin/main" --output "$output/review-regressions" "${review_args[@]}"
    else
        python3 "$here/fixtures/matrix.py" --binary "$wrapped/target/release/bin/main" --output "$output/matrix"
    fi
    exit 0
fi
(cd "$here" && cjpm build)
# Direct binary exit is authoritative. Never cjpm run or a declaration library.
TERM=dumb COLORTERM= timeout 90s "$here/target/release/bin/main" </dev/null
if [[ ${1:-} == --device ]]; then
    python3 "$here/fixtures/device.py" --binary "$here/target/release/bin/main" --output "$output/device"
fi

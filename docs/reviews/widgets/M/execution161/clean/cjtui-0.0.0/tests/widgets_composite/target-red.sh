#!/usr/bin/env bash
set -euo pipefail
here=$(cd "$(dirname "$0")" && pwd)
source /workspace/work/validation/sdk/cangjie/envsetup.sh
export CANGJIE_STDX_PATH=${CANGJIE_STDX_PATH:-/workspace/work/linux-build-recon/stdx-env}
export CJTUI_UCD_ARCHIVE=${CJTUI_UCD_ARCHIVE:-/workspace/work/validation/replay-dependencies/UCD-17.0.0.zip}
output=${CJTUI_COMPOSITE_RED_OUTPUT:?set a new directory for immutable raw compiler evidence}
mkdir -p "$output"
(cd "$here/prerequisite" && cjpm build && TERM=dumb COLORTERM= timeout 90s target/release/bin/main </dev/null)
set +e
(cd "$here/missing_targets" && cjpm build) >"$output/compiler.log" 2>&1
status=$?
set -e
printf '%s\n' "$status" >"$output/compiler.exit"
if [[ $status -ne 1 ]]; then printf 'Expected actual compiler exit1, got %s\n' "$status" >&2; exit 1; fi
python3 "$here/classify_red.py" "$output/compiler.log" "$here/missing_targets/src/main.cj"

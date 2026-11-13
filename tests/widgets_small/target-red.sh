#!/usr/bin/env bash
# Five isolated ordinary CJPM consumers. No symbol gate, stub or generated API.
set -euo pipefail
here=$(cd "$(dirname "$0")" && pwd)
source /workspace/work/validation/sdk/cangjie/envsetup.sh
export CANGJIE_STDX_PATH=${CANGJIE_STDX_PATH:-/workspace/work/linux-build-recon/stdx-env}
export CJTUI_UCD_ARCHIVE=${CJTUI_UCD_ARCHIVE:-/workspace/work/validation/replay-dependencies/UCD-17.0.0.zip}
(cd "$here/prerequisite" && cjpm build && TERM=dumb COLORTERM= timeout 90s target/release/bin/main </dev/null)
output=${CJTUI_SMALL_RED_OUTPUT:?set a new output directory for raw compiler logs}
mkdir -p "$output"
for name in label button checkbox radio progress; do
    symbol=${name^}
    set +e
    (cd "$here/red_$name" && cjpm build) >"$output/$name.stdout" 2>"$output/$name.stderr"
    status=$?
    set -e
    printf '%s\n' "$status" >"$output/$name.exit"
    if [[ $status -ne 1 ]]; then printf 'Expected compiler RED=1 for %s, got %s\n' "$symbol" "$status" >&2; exit 1; fi
    rg -q "'$symbol' is not accessible in package 'cjtui'" "$output/$name.stderr"
    printf 'GENUINE_MISSING_API_RED %s compiler_exit=%s\n' "$symbol" "$status"
done

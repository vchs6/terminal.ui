#!/usr/bin/env bash
set -euo pipefail
root=$(cd "$(dirname "$0")/../../.." && pwd)
artifacts=$(mktemp -d "${CJTUI_RUNTIME_ARTIFACTS:-${TMPDIR:-/tmp}}/cjtui-runtime-macros.XXXXXX")
printf 'Runtime macro artifacts: %s\n' "$artifacts"
sharedTarget="$root/tests/runtime/macros/target"
# This positive gate is mandatory. An absent macro package cannot pass negatives.
(cd "$root/tests/runtime/macros/positive" && cjpm build --target-dir "$sharedTarget")
TERM=dumb COLORTERM= timeout 45s "$sharedTarget/release/bin/main" </dev/null
while IFS=$'\t' read -r fixture location concept; do
    directory="$root/tests/runtime/macros/negative/$fixture"
    if (cd "$directory" && cjpm build --target-dir "$sharedTarget") >"$artifacts/$fixture.stdout" 2>"$artifacts/$fixture.stderr"; then
        echo "FAIL: $fixture compiled; expected a diagnostic" >&2
        exit 1
    else
        status=$?
        printf '%s\n' "$status" >"$artifacts/$fixture.exit"
    fi
    sed -E 's/\x1B\[[0-9;]*[mK]//g' "$artifacts/$fixture.stderr" >"$artifacts/$fixture.diagnostics"
    # Require an actual source-located compiler diagnostic for this forbidden
    # construct; resolution/network/link errors cannot satisfy the assertion.
    if ! rg -q "${location}:[0-9]+:[0-9]+" "$artifacts/$fixture.diagnostics" ||
       ! rg -qi "$concept" "$artifacts/$fixture.diagnostics" ||
       rg -qi 'cannot find package|cannot open file|Failed to connect|failed to resolve|linker command failed' "$artifacts/$fixture.diagnostics"; then
        cat "$artifacts/$fixture.stderr" >&2
        echo "FAIL: $fixture did not produce its source-located contract diagnostic" >&2
        exit 1
    fi
    echo "PASS: macro diagnostic $fixture"
done <"$root/tests/runtime/macros/negative/cases.tsv"

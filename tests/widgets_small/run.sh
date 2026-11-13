#!/usr/bin/env bash
set -euo pipefail
here=$(cd "$(dirname "$0")" && pwd)
source /workspace/work/validation/sdk/cangjie/envsetup.sh
export CANGJIE_STDX_PATH=${CANGJIE_STDX_PATH:-/workspace/work/linux-build-recon/stdx-env}
export CJTUI_UCD_ARCHIVE=${CJTUI_UCD_ARCHIVE:-/workspace/work/validation/replay-dependencies/UCD-17.0.0.zip}
node "$here/oracle.mjs"
if [[ ${1:-} == --oracle ]]; then exit 0; fi
if [[ $# -ne 0 ]]; then printf 'usage: %s [--oracle]\n' "$0" >&2; exit 64; fi
# Formal upstream admission is bound by input-manifest.json, not a text gate.
# This ordinary public consumer must build and exit zero before target evidence.
(cd "$here/prerequisite" && cjpm build && TERM=dumb COLORTERM= timeout 90s target/release/bin/main </dev/null)
cd "$here"
cjpm build
TERM=dumb COLORTERM= timeout 90s "$here/target/release/bin/main" </dev/null
(cd "$here/device" && cjpm build)
pty_output=${CJTUI_SMALL_PTY_OUTPUT:-$(mktemp -d /tmp/cjtui-small-pty.XXXXXX)}
printf 'PTY artifacts: %s\n' "$pty_output"
python3 "$here/pty.py" --binary "$here/device/target/release/bin/main" --output "$pty_output"
# Only reached after normal API/behavior builds: absence is never accepted as a
# forbidden-Bool-overload rejection. Preserve the real compiler exit and output.
for name in checkbox radio; do
    log="$here/target/negative-${name}.log"
    set +e
    (cd "$here/negative_${name}_bool" && cjpm build) >"$log" 2>&1
    status=$?
    set -e
    cat "$log"
    if [[ $status -ne 1 ]] || rg -q "not accessible|cannot import|package.*not found" "$log"; then
        printf 'Invalid Bool constructor evidence for %s, compiler exit=%s\n' "$name" "$status" >&2
        exit 1
    fi
    python3 - "$log" <<'PYNEG'
import pathlib, re, sys
text = re.sub(r'\x1b\[[0-9;]*m', '', pathlib.Path(sys.argv[1]).read_text())
assert not re.search(r'error:.*(?:unexpected|expected token|unterminated|not accessible)', text, re.I), text
assert re.search(r'error:.*(?:type mismatch|no matching|not a subtype|cannot convert|incompatible|expected type)', text, re.I), text
assert 'Bool' in text, text
PYNEG
done

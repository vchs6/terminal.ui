#!/usr/bin/env bash
set -euo pipefail
here=$(cd "$(dirname "$0")" && pwd)
source /workspace/work/validation/sdk/cangjie/envsetup.sh
export CANGJIE_STDX_PATH=${CANGJIE_STDX_PATH:-/workspace/work/linux-build-recon/stdx-env}
export CJTUI_UCD_ARCHIVE=${CJTUI_UCD_ARCHIVE:-/workspace/work/validation/replay-dependencies/UCD-17.0.0.zip}
mode=${1:-formal}
if [[ "$mode" == self-test ]]; then
    python3 "$here/oracle.py" --self-test
    python3 "$here/pty_selftest.py"
    python3 "$here/pty_mode_selftest.py"
    python3 "$here/pty_fence_selftest.py"
    python3 - "$here" <<'PYCHECK'
from pathlib import Path
import sys
for path in Path(sys.argv[1]).glob("*.py"):
    compile(path.read_text(), str(path), "exec")
print("PYTHON_SYNTAX_PASS")
PYCHECK
    exit 0
fi
if [[ "$mode" != formal ]]; then printf 'usage: %s [formal|self-test]\n' "$0" >&2; exit 64; fi
# The fixed manifest records accepted inputs. No synthetic gate or target-file
# presence test is used: actual ordinary builds decide the outcome.
(cd "$here/prerequisite" && cjpm build && TERM=dumb COLORTERM= timeout 90s target/release/bin/main </dev/null)
(cd "$here" && cjpm build && TERM=dumb COLORTERM= timeout 90s target/release/bin/main </dev/null)
(cd "$here/device" && cjpm build)
output=${CJTUI_COMPOSITE_PTY_OUTPUT:-$(mktemp -d /tmp/cjtui-composite-pty.XXXXXX)}
python3 "$here/pty.py" --binary "$here/device/target/release/bin/main" --output "$output"

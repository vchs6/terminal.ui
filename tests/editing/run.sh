#!/usr/bin/env bash
set -euo pipefail
here=$(cd "$(dirname "$0")" && pwd)
if [[ ${1:-} == --selftest ]]; then
    node "$here/fixtures/handshake.mjs" --selftest
    node "$here/pty.mjs" --selftest
    python3 "$here/fixtures/oracle.py"
    exit 0
fi
(cd "$here" && cjpm build)
TERM=dumb COLORTERM= timeout 90s "$here/target/release/bin/main" </dev/null

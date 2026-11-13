#!/usr/bin/env bash
set -euo pipefail
here=$(cd "$(dirname "$0")" && pwd)
if [[ ${1:-} == --selftest ]]; then
    node "$here/fixtures/handshake.mjs" --selftest
    node "$here/pty.mjs" --selftest
    python3 "$here/fixtures/oracle.py"
    exit 0
fi
if [[ ${1:-} == --prerequisites ]]; then
    (cd "$here/prerequisites" && cjpm build)
    TERM=dumb COLORTERM= timeout 60s "$here/prerequisites/target/release/bin/main" </dev/null
    exit 0
fi
if [[ ${1:-} == --red ]]; then
    (cd "$here/missing_api" && cjpm build)
    exit 0
fi
(cd "$here" && cjpm build)
TERM=dumb COLORTERM= timeout 180s "$here/target/release/bin/main" </dev/null
artifacts=${CJTUI_EDITING_ARTIFACTS:-$(mktemp -d)}
mkdir -p "$artifacts"
cc -std=c11 -shared -fPIC "$here/../keyboard/native/pipe_remap.c" -ldl -o "$artifacts/input_pipe.so"
node "$here/pty.mjs" "$here/target/release/bin/main" "$artifacts/pty" "$artifacts/input_pipe.so"

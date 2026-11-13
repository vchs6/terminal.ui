#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
(cd upstream && cjpm build && ./target/release/bin/main)
cjpm build
# Preserve actual executable exit, never use CJPM run as the verdict.
./target/release/bin/main
bash ./check-api.sh
(cd formal_dispatch && cjpm build && ./target/release/bin/main)
if [[ "${1:-}" == "--pty" ]]; then
    (cd device && cjpm build)
    node pty.mjs device/target/release/bin/main
    exec bash native/run.sh --pty
fi
exec bash native/run.sh

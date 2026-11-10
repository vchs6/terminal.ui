#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
cjpm build
# CJPM run can mask the program exit; invoke the actual compiled consumer.
./target/release/bin/main
bash ./check-api.sh
if [[ "${1:-}" == "--pty" ]]; then
    (cd device && cjpm build)
    exec node pty.mjs device/target/release/bin/main "${@:2}"
fi

#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
cjpm build
case "${CJTUI_K115_CASE:?select K115-01 through K115-05}" in
 K115-05) exec python3 native_pty.py --binary target/release/bin/main --output "${CJTUI_K115_ARTIFACTS:?new absolute artifact directory}";;
 *) exec ./target/release/bin/main;;
esac

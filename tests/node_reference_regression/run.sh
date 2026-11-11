#!/usr/bin/env bash
set -euo pipefail
here=$(cd "$(dirname "$0")" && pwd)
(cd "$here" && cjpm build)
status=0
for mode in controls guard; do
    if TERM=dumb COLORTERM= timeout 60s "$here/target/release/bin/main" "$mode" </dev/null; then :; else status=1; fi
done
exit "$status"

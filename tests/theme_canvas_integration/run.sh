#!/usr/bin/env bash
set -euo pipefail
here=$(cd "$(dirname "$0")" && pwd)
(cd "$here" && cjpm build)
status=0
cases=(finite control subtree)
if [[ ${1:-all} != all ]]; then cases=("$1"); fi
for mode in "${cases[@]}"; do
    case "$mode" in finite|control|subtree) ;; *) echo "unknown case: $mode" >&2; exit 2 ;; esac
    if TERM=dumb COLORTERM= timeout 60s "$here/target/release/bin/main" "$mode" </dev/null; then
        :
    else
        status=1
    fi
done
exit "$status"

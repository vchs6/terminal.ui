#!/usr/bin/env bash
set -uo pipefail
source /workspace/work/linux-build-recon/env.sh
for slug in negative-key negative-decode; do
    cd "/workspace/work/theme-key-budget-review/$slug"
    date -u +%FT%TZ > "../raw/$slug.started.utc"
    cjpm build > "../raw/$slug.stdout" 2> "../raw/$slug.stderr"
    result=$?
    printf '%s\n' "$result" > "../raw/$slug.exit"
    date -u +%FT%TZ > "../raw/$slug.finished.utc"
done

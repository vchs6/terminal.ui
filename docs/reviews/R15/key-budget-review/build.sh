#!/usr/bin/env bash
set -uo pipefail
cd /workspace/work/theme-key-budget-review
source /workspace/work/linux-build-recon/env.sh
{ date -u +%FT%TZ; cjc --version; cjpm --version; } > raw/sdk.txt 2>&1
cd probe
date -u +%FT%TZ > ../raw/build.started.utc
cjpm build > ../raw/build.stdout 2> ../raw/build.stderr
result=$?
printf '%s\n' "$result" > ../raw/build.exit
date -u +%FT%TZ > ../raw/build.finished.utc
exit "$result"

#!/usr/bin/env bash
set -uo pipefail
source /workspace/work/linux-build-recon/env.sh
export CJTUI_UCD_ARCHIVE=/workspace/work/terminal.ui/.cjtui-build/UCD-17.0.0.zip
cd /workspace/work/theme-review/probe
{ date -u +%FT%TZ; cjc --version; cjpm --version; } > ../raw/final/probe-sdk.txt
date -u +%FT%TZ > ../raw/final/probe-build.started.utc
cjpm build -i > ../raw/final/probe-build.stdout 2> ../raw/final/probe-build.stderr
result=$?
printf '%s\n' "$result" > ../raw/final/probe-build.exit
date -u +%FT%TZ > ../raw/final/probe-build.finished.utc
if [[ "$result" != 0 ]]; then exit "$result"; fi
date -u +%FT%TZ > ../raw/final/probe-run.started.utc
./target/release/bin/main > ../raw/final/probe-run.stdout 2> ../raw/final/probe-run.stderr
result=$?
printf '%s\n' "$result" > ../raw/final/probe-run.exit
date -u +%FT%TZ > ../raw/final/probe-run.finished.utc
exit "$result"

#!/usr/bin/env bash
set -uo pipefail
source /workspace/work/linux-build-recon/env.sh
export CJTUI_UCD_ARCHIVE=/workspace/work/terminal.ui/.cjtui-build/UCD-17.0.0.zip
cd /workspace/work/viewport-review/probe
{ date -u +%FT%TZ; cjc --version; cjpm --version; } > ../raw/final-sdk.txt
date -u +%FT%TZ > ../raw/final-build.started.utc
cjpm build > ../raw/final-build.stdout 2> ../raw/final-build.stderr
result=$?;printf '%s\n' "$result" > ../raw/final-build.exit
date -u +%FT%TZ > ../raw/final-build.finished.utc
if [[ "$result" != 0 ]];then exit "$result";fi
date -u +%FT%TZ > ../raw/final-run.started.utc
./target/release/bin/main > ../raw/final-run.stdout 2> ../raw/final-run.stderr
result=$?;printf '%s\n' "$result" > ../raw/final-run.exit
date -u +%FT%TZ > ../raw/final-run.finished.utc
exit "$result"

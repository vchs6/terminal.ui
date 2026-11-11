#!/usr/bin/env bash
set -uo pipefail
source /workspace/work/linux-build-recon/env.sh
export CJTUI_UCD_ARCHIVE=/workspace/work/terminal.ui/.cjtui-build/UCD-17.0.0.zip
cd /workspace/work/viewport-review/probe
{ date -u +%FT%TZ; cjc --version; cjpm --version; } > ../raw/extended-sdk.txt
date -u +%FT%TZ > ../raw/extended-build.started.utc
cjpm build > ../raw/extended-build.stdout 2> ../raw/extended-build.stderr
result=$?;printf '%s\n' "$result" > ../raw/extended-build.exit
date -u +%FT%TZ > ../raw/extended-build.finished.utc
if [[ "$result" != 0 ]];then exit "$result";fi
date -u +%FT%TZ > ../raw/extended-run.started.utc
./target/release/bin/main > ../raw/extended-run.stdout 2> ../raw/extended-run.stderr
result=$?;printf '%s\n' "$result" > ../raw/extended-run.exit
date -u +%FT%TZ > ../raw/extended-run.finished.utc
exit "$result"

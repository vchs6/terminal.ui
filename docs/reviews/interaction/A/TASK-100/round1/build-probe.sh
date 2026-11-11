#!/usr/bin/env bash
set -uo pipefail
source /workspace/work/linux-build-recon/env.sh
export CJTUI_UCD_ARCHIVE=/workspace/work/terminal.ui/.cjtui-build/UCD-17.0.0.zip
cd /workspace/work/interaction-review/round1/probe
{ date -u +%FT%TZ; cjc --version; cjpm --version; } > ../raw/sdk.txt
cc -c clock_wrap.c -o clock-wrap.o > ../raw/clock-build.stdout 2> ../raw/clock-build.stderr
result=$?; printf '%s\n' "$result" > ../raw/clock-build.exit
if [[ "$result" != 0 ]]; then exit "$result"; fi
date -u +%FT%TZ > ../raw/build.started.utc
cjpm build > ../raw/build.stdout 2> ../raw/build.stderr
result=$?; printf '%s\n' "$result" > ../raw/build.exit
date -u +%FT%TZ > ../raw/build.finished.utc
exit "$result"

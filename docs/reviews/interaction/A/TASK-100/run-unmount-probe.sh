#!/usr/bin/env bash
set -uo pipefail
source /workspace/work/linux-build-recon/env.sh
export CJTUI_UCD_ARCHIVE=/workspace/work/terminal.ui/.cjtui-build/UCD-17.0.0.zip
cd /workspace/work/interaction-review/probe
{ date -u +%FT%TZ; cjc --version; cjpm --version; } > ../raw/unmount-sdk.txt
cc -c clock_wrap.c -o clock-wrap.o > ../raw/unmount-clock-build.stdout 2> ../raw/unmount-clock-build.stderr
result=$?; printf '%s\n' "$result" > ../raw/unmount-clock-build.exit
if [[ "$result" != 0 ]]; then exit "$result"; fi
date -u +%FT%TZ > ../raw/unmount-build.started.utc
cjpm build > ../raw/unmount-build.stdout 2> ../raw/unmount-build.stderr
result=$?; printf '%s\n' "$result" > ../raw/unmount-build.exit
date -u +%FT%TZ > ../raw/unmount-build.finished.utc
if [[ "$result" != 0 ]]; then exit "$result"; fi
date -u +%FT%TZ > ../raw/unmount-run.started.utc
./target/release/bin/main > ../raw/unmount-run.stdout 2> ../raw/unmount-run.stderr
result=$?; printf '%s\n' "$result" > ../raw/unmount-run.exit
date -u +%FT%TZ > ../raw/unmount-run.finished.utc
exit "$result"

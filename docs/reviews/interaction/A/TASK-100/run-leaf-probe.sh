#!/usr/bin/env bash
set -uo pipefail
source /workspace/work/linux-build-recon/env.sh
export CJTUI_UCD_ARCHIVE=/workspace/work/terminal.ui/.cjtui-build/UCD-17.0.0.zip
cd /workspace/work/interaction-review/probe
{ date -u +%FT%TZ; cjc --version; cjpm --version; } > ../raw/leaf-sdk.txt
cc -c clock_wrap.c -o clock-wrap.o > ../raw/leaf-clock-build.stdout 2> ../raw/leaf-clock-build.stderr
result=$?; printf '%s\n' "$result" > ../raw/leaf-clock-build.exit
if [[ "$result" != 0 ]]; then exit "$result"; fi
date -u +%FT%TZ > ../raw/leaf-build.started.utc
cjpm build > ../raw/leaf-build.stdout 2> ../raw/leaf-build.stderr
result=$?; printf '%s\n' "$result" > ../raw/leaf-build.exit
date -u +%FT%TZ > ../raw/leaf-build.finished.utc
if [[ "$result" != 0 ]]; then exit "$result"; fi
date -u +%FT%TZ > ../raw/leaf-run.started.utc
./target/release/bin/main > ../raw/leaf-run.stdout 2> ../raw/leaf-run.stderr
result=$?; printf '%s\n' "$result" > ../raw/leaf-run.exit
date -u +%FT%TZ > ../raw/leaf-run.finished.utc
exit "$result"

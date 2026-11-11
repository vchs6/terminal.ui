#!/usr/bin/env bash
set -uo pipefail
source /workspace/work/linux-build-recon/env.sh
export CJTUI_UCD_ARCHIVE=/workspace/work/terminal.ui/.cjtui-build/UCD-17.0.0.zip
cd /workspace/work/theme-review/probe
{ date -u +%FT%TZ; cjc --version; cjpm --version; } > ../raw/probe-sdk.txt
date -u +%FT%TZ > ../raw/probe-build.started.utc
cjpm build > ../raw/probe-build.stdout 2> ../raw/probe-build.stderr
result=$?
printf '%s\n' "$result" > ../raw/probe-build.exit
date -u +%FT%TZ > ../raw/probe-build.finished.utc
if [[ "$result" != 0 ]]; then exit "$result"; fi
date -u +%FT%TZ > ../raw/probe-run.started.utc
./target/release/bin/main > ../raw/probe-run.stdout 2> ../raw/probe-run.stderr
result=$?
printf '%s\n' "$result" > ../raw/probe-run.exit
date -u +%FT%TZ > ../raw/probe-run.finished.utc
exit "$result"

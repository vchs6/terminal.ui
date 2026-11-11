#!/usr/bin/env bash
set -uo pipefail
source /workspace/work/linux-build-recon/env.sh
export CJTUI_UCD_ARCHIVE=/workspace/work/terminal.ui/.cjtui-build/UCD-17.0.0.zip
cd /workspace/work/viewport-review/round1/probe
cp cangjie-repo.toml /tmp/viewport-review-round1-source/cangjie-repo.toml
{ date -u +%FT%TZ; cjc --version; cjpm --version; } > ../raw/sdk.txt
date -u +%FT%TZ > ../raw/build.started.utc
cjpm build > ../raw/build.stdout 2> ../raw/build.stderr
result=$?;printf '%s\n' "$result" > ../raw/build.exit
date -u +%FT%TZ > ../raw/build.finished.utc
if [[ "$result" != 0 ]];then exit "$result";fi
date -u +%FT%TZ > ../raw/run.started.utc
./target/release/bin/main > ../raw/run.stdout 2> ../raw/run.stderr
result=$?;printf '%s\n' "$result" > ../raw/run.exit
date -u +%FT%TZ > ../raw/run.finished.utc
exit "$result"

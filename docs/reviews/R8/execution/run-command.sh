#!/usr/bin/env bash
set -uo pipefail
id=$1
wd=$2
command=$3
base=/workspace/work/first-slice-execution
log="$base/logs/$id.log"
start=$(date -u +%FT%TZ)
printf 'cwd=%s\ncommand=%s\nstarted=%s\n' "$wd" "$command" "$start" > "$log"
(cd "$wd" && source /workspace/work/validation/sdk/cangjie/envsetup.sh && export CJTUI_UCD_ARCHIVE=/workspace/work/validation/replay-dependencies/UCD-17.0.0.zip && bash -c "$command") >> "$log" 2>&1
rc=$?
end=$(date -u +%FT%TZ)
printf '\nexit_code=%s\nended=%s\n' "$rc" "$end" >> "$log"
node - "$base/commands.jsonl" "$id" "$wd" "$command" "$start" "$end" "$rc" "$log" <<'JS'
const fs=require('fs'); const [file,id,cwd,command,started,ended,rc,log]=process.argv.slice(2);fs.appendFileSync(file,JSON.stringify({id,cwd,command,started,ended,exit_code:Number(rc),log})+'\n');
JS
cat "$log"
exit "$rc"

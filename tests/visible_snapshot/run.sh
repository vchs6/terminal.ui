#!/usr/bin/env bash
set -euo pipefail
root=$(cd "$(dirname "$0")/../.." && pwd)
tests="$root/tests/visible_snapshot"
output=${CJTUI_VISIBLE_SNAPSHOT_FILES:-$(mktemp -d "${TMPDIR:-/tmp}/cjtui-visible-snapshot.XXXXXXXX")}
mkdir -p "$output/existing-directory" "$output/denied"
output=$(cd "$output" && pwd)
[[ $(id -u) != 0 ]] || { echo 'INFRASTRUCTURE: use unprivileged user for actual unwritable-directory case' >&2; exit 2; }
[[ -c /dev/full ]] || { echo 'INFRASTRUCTURE: /dev/full unavailable' >&2; exit 2; }
chmod 500 "$output/denied"
export CJTUI_VISIBLE_SNAPSHOT_FILES="$output"
export CJTUI_VISIBLE_SNAPSHOT_DENIED="$output/denied/out"
[[ ! -w "$output/denied" ]] || { echo 'INFRASTRUCTURE: directory remains writable' >&2; exit 2; }
node "$tests/oracle_selftest.mjs"
node --input-type=module - "$tests" "$output" <<'JS'
import {writeFile} from 'node:fs/promises';
import {pathToFileURL} from 'node:url';
import {join} from 'node:path';
const {fixtures} = await import(pathToFileURL(join(process.argv[2], 'manual_fixtures.mjs')));
for (const name of fixtures.keys()) {
  for (const suffix of ['txt', 'ansi', 'mono.ansi']) {
    await writeFile(join(process.argv[3], `${name}.${suffix}`), Buffer.alloc(4096, 0x7a));
  }
}
JS
(cd "$tests" && cjpm build)
cc -std=c11 -Wall -Wextra -Werror "$tests/short_write_launcher.c" -o "$output/short-write-launcher"
binary="$tests/target/release/bin/main"
"$binary" | tee "$output/consumer.log"
CJTUI_VISIBLE_SNAPSHOT_SHORT_ONLY=1 "$output/short-write-launcher" "$binary" | tee "$output/short-write.log"
node "$tests/verify_files.mjs" "$output"
printf 'Actual file artifacts: %s\n' "$output"

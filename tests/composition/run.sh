#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/../.."
(cd tests/composition && cjpm build)
if [[ -n "${CJTUI_COMPOSITION_ARTIFACTS:-}" ]]; then
  mkdir -p "$CJTUI_COMPOSITION_ARTIFACTS"
  artifacts=$(mktemp -d "$CJTUI_COMPOSITION_ARTIFACTS/run.XXXXXXXX")
else
  artifacts=$(mktemp -d "${TMPDIR:-/tmp}/cjtui-composition.XXXXXXXX")
fi
export CJTUI_COMPOSITION_ARTIFACTS="$artifacts"
mkdir "$artifacts/existing-directory"
node --input-type=module - "$artifacts" <<'JS'
import { writeFile } from 'node:fs/promises';
import { join } from 'node:path';
const directory = process.argv[2];
for (const name of ['plain-replaced.txt', 'ansi-default.txt', 'ansi-true.txt', 'ansi-basic8.txt', 'ansi-mono.txt',
  'transparent-plain.txt', 'transparent-ansi.txt', 'empty-plain.txt', 'empty-ansi.txt', 'zero-width-plain.txt', 'zero-width-ansi.txt']) {
  await writeFile(join(directory, name), Buffer.alloc(1024, 0x7a));
}
await writeFile(join(directory, 'budget-sentinel.txt'), 'preserve-before-budget-validation');
JS
if [[ -c /dev/full ]]; then export CJTUI_COMPOSITION_DEV_FULL=1; else export CJTUI_COMPOSITION_DEV_FULL=0; fi
printf 'Composition artifacts: %s\n' "$artifacts"
TERM=dumb COLORTERM='' timeout 30s tests/composition/target/release/bin/main
node tests/composition/verify-files.mjs "$artifacts"
bash tests/composition/application/run.sh

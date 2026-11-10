import assert from 'node:assert/strict';
import { readFile, access } from 'node:fs/promises';
import { join } from 'node:path';

const directory = process.argv[2];
if (!directory) throw new Error('usage: node verify-files.mjs ARTIFACT_DIRECTORY');
const reset = '\x1b[0m';
// Literal standard CUP/SGR bytes and hand-derived grid. Never call product export.
const plain = '中CD\n e\u0301  ';
const colored = sgr => reset + '\x1b[1;1H中CD\x1b[2;1H ' + reset + sgr + 'e\u0301' + reset + '  ' + reset;
const expected = new Map([
  ['plain-created.txt', plain],
  ['plain-replaced.txt', plain],
  ['ansi-default.txt', colored('\x1b[38;2;255;0;0m')],
  ['ansi-true.txt', colored('\x1b[38;2;255;0;0m')],
  ['ansi-basic8.txt', colored('\x1b[31m')],
  ['ansi-mono.txt', reset + '\x1b[1;1H中CD\x1b[2;1H e\u0301  ' + reset],
  ['transparent-plain.txt', '  '],
  ['transparent-ansi.txt', reset + '\x1b[1;1H  ' + reset],
  ['empty-plain.txt', ''],
  ['empty-ansi.txt', ''],
  ['zero-width-plain.txt', '\n\n\n'],
  ['zero-width-ansi.txt', ''],
  ['budget-sentinel.txt', 'preserve-before-budget-validation'],
]);
for (const [name, text] of expected) {
  const bytes = await readFile(join(directory, name));
  assert.deepEqual(bytes, Buffer.from(text, 'utf8'), `${name}: exact UTF-8 bytes, BOM/truncation/LF/reset policy`);
  console.log(`PASS: ${name}: exact independently authored UTF-8 bytes`);
}
for (const name of ['missing-parent', 'budget-created.txt']) {
  await assert.rejects(access(join(directory, name)), { code: 'ENOENT' }, `${name}: must not be created`);
  console.log(`PASS: ${name}: not created`);
}

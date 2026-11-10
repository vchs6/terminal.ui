#!/usr/bin/env node
// A second callback changes only this uncolored row after the preceding render.
import assert from 'node:assert/strict';
import { readFile } from 'node:fs/promises';
const [path, offsetText, bold, widthText, mode = 'updates', timeoutText = '15000'] = process.argv.slice(2);
const offset = Number(offsetText), width = Number(widthText), timeout = Number(timeoutText);
assert(path && Number.isSafeInteger(offset) && offset >= 0 && ['true', 'false'].includes(bold) &&
  Number.isSafeInteger(width) && width >= 11 && ['updates', 'quiet'].includes(mode) && Number.isFinite(timeout) && timeout > 0,
  'usage: wait-fence.mjs RAW OFFSET BOLD COLUMNS [updates|quiet] [TIMEOUT_MS]');
const expected = Buffer.from('\x1b[0m\x1b[3;1H' + (bold === 'true' ? '\x1b[0m\x1b[1mEVENT-FENCE\x1b[0m' : 'EVENT-FENCE') + ' '.repeat(width - 11) + '\x1b[0m');
const deadline = Date.now() + timeout;
while (Date.now() < deadline) {
  let raw;
  try { raw = await readFile(path); } catch (error) { if (error.code !== 'ENOENT') throw error; raw = Buffer.alloc(0); }
  const at = raw.indexOf(expected, offset);
  if (at >= 0) {
    assert(mode !== 'quiet' || at === offset, 'no-op emitted bytes before transport fence');
    console.log(JSON.stringify({ startOffset: offset, fenceStart: at, fenceEnd: at + expected.length,
      precedingBytes: at - offset, fenceBytes: expected.length, bold: bold === 'true', columns: width,
      observedAtUtc: new Date().toISOString() }));
    process.exit(0);
  }
  await new Promise(resolve => setTimeout(resolve, 10));
}
console.error('timeout: recorded complete fence row');
process.exitCode = 1;

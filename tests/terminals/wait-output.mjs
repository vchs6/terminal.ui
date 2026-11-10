#!/usr/bin/env node
// Positive-update barrier for unmodified examples, which expose no fixture ack.
import assert from 'node:assert/strict';
import { createHash } from 'node:crypto';
import { readFile, writeFile } from 'node:fs/promises';
const [path, start, timeout = '15000', deltaPath] = process.argv.slice(2);
const offset = Number(start), milliseconds = Number(timeout);
assert(path && Number.isSafeInteger(offset) && offset >= 0 && Number.isFinite(milliseconds) && milliseconds > 0,
  'usage: wait-output.mjs RAW START_OFFSET [TIMEOUT_MS] [DELTA_PATH]');
const deadline = Date.now() + milliseconds;
let previous = -1, stableSince = Date.now();
while (Date.now() < deadline) {
  let raw;
  try { raw = await readFile(path); }
  catch (error) { if (error.code !== 'ENOENT') throw error; raw = Buffer.alloc(0); }
  if (raw.length !== previous) { previous = raw.length; stableSince = Date.now(); }
  const delta = raw.subarray(offset);
  const rows = [...delta.toString('utf8').matchAll(/\x1b\[([1-9][0-9]*);1H/g)];
  if (delta.length && rows.length && delta.subarray(-4).equals(Buffer.from('\x1b[0m')) && Date.now() - stableSince >= 100) {
    if (deltaPath) await writeFile(deltaPath, delta);
    console.log(JSON.stringify({ startOffset: offset, endOffset: raw.length, byteCount: delta.length,
      completeRows: rows.length, rows: rows.map(value => Number(value[1])),
      sha256: createHash('sha256').update(delta).digest('hex'), observedAtUtc: new Date().toISOString(),
      evidence: 'positive CUP output ending in SGR0, stable for 100ms; no silent-event claim' }));
    process.exit(0);
  }
  await new Promise(resolve => setTimeout(resolve, 10));
}
console.error('timeout: positive complete terminal output');
process.exitCode = 1;

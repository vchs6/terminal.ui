#!/usr/bin/env node
import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import { fileURLToPath } from 'node:url';

// Sanity-check manually written fixtures only. No cjtui import or model.
const fixtures = JSON.parse(readFileSync(new URL('./expected.json', import.meta.url), 'utf8'));
assert.equal(fixtures.frames.length, 10);
assert.equal(fixtures.events.length, 8);
assert.equal(fixtures.errors.length, 10);
const names = [...fixtures.frames, ...fixtures.events, ...fixtures.errors].map(row => row.case);
assert.equal(new Set(names).size, names.length, 'unique fixture names');
for (const item of fixtures.frames) {
  const lines = item.plain.split('\n');
  assert.equal(lines.length, item.height, item.case);
  for (const line of lines) assert.equal([...line].length, item.width, item.case);
}
assert.equal(fixtures.frames.find(item => item.case === 'progress-half').plain, '==========----------');
assert.deepEqual(fixtures.events.find(item => item.case === 'checkbox-rejected').requests, [true]);
assert.equal(fixtures.errors.find(item => item.case === 'progress-NaN').code, 'InvalidProperty');
console.log('PASS hand-authored fixture shape and anchors');

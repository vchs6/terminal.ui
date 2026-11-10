#!/usr/bin/env node
import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
const [capFile, rawFile] = process.argv.slice(2);
assert(capFile && rawFile, 'usage: verify-sgr.mjs CAPABILITIES RAW');
const fields = Object.fromEntries(readFileSync(capFile, 'utf8').trim().split(';').map(x => x.split('=')));
const raw = readFileSync(rawFile);
for (const text of ['AUTO RGB 1,128,254', 'Unicode:', '中文', 'EVENT-FENCE', 'Resize edge:']) assert(raw.includes(Buffer.from(text)), 'missing scene text: ' + text);
const sgr = [];
for (let i = 0; i < raw.length; i++) {
  if (raw[i] !== 27 || raw[i + 1] !== 91) continue;
  let end = i + 2;
  while (end < raw.length && ((raw[end] >= 48 && raw[end] <= 57) || raw[end] === 59)) end++;
  if (raw[end] !== 109) continue;
  const value = raw.subarray(i + 2, end).toString('ascii');
  sgr.push(value === '' ? [0] : value.split(';').map(Number));
  i = end;
}
assert(sgr.length, 'no SGR bytes in actual inner TTY');
const attributes = new Map([[1, 'supportsBold'], [2, 'supportsDim'], [3, 'supportsItalic'], [4, 'supportsUnderline'], [7, 'supportsInverse'], [9, 'supportsStrikethrough']]);
const ncvBlocked = new Map([[2, 4], [4, 2], [16, 2], [32, 1]]);
let named = 0, indexed = 0, rgb = 0, extended = 0;
for (const values of sgr) for (let i = 0; i < values.length; i++) {
  const code = values[i];
  if (code === 0) continue;
  if (attributes.has(code)) {
    assert.notEqual(fields[attributes.get(code)], 'false', 'unsupported SGR' + code);
    if (ncvBlocked.get(Number(fields.ncv)) === code) assert.fail('NCV forbids SGR' + code);
    continue;
  }
  if ((code >= 30 && code <= 37) || (code >= 90 && code <= 97) || (code >= 40 && code <= 47) || (code >= 100 && code <= 107)) { named++; continue; }
  if (code === 38 || code === 48) {
    extended++;
    const kind = values[++i], count = kind === 2 ? 3 : kind === 5 ? 1 : 0;
    assert(count, 'unsupported SGR kind ' + kind);
    const channels = values.slice(i + 1, i + 1 + count);
    assert.equal(channels.length, count, 'truncated extended SGR');
    assert(channels.every(value => value >= 0 && value <= 255), 'invalid SGR channel');
    if (kind === 2) rgb++; else indexed++;
    i += count;
    continue;
  }
  assert.fail('undeclared SGR' + code);
}
switch (fields.colorMode) {
  case 'Monochrome': assert.equal(named + extended, 0, 'Monochrome emitted color'); break;
  case 'Basic8': case 'Basic16': assert.equal(extended, 0, 'Basic emitted extended color'); assert(named > 0, 'Basic omitted named color'); break;
  case 'Indexed256': assert.equal(rgb, 0, 'Indexed256 emitted RGB'); assert(indexed > 0, 'Indexed256 omitted indexed color'); break;
  case 'TrueColor':
    assert(sgr.some(value => value.join(';') === '38;2;1;128;254'), 'TrueColor omitted exact foreground');
    assert(sgr.some(value => value.join(';') === '48;2;250;0;0'), 'TrueColor omitted exact background');
    break;
  default: assert.fail('unknown colorMode ' + fields.colorMode);
}
console.log('PASS SGR profile=' + fields.colorMode + ' sequences=' + sgr.length + ' named=' + named + ' indexed=' + indexed + ' rgb=' + rgb);

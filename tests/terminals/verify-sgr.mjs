#!/usr/bin/env node
import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
const [capFile, rawFile, host] = process.argv.slice(2);
assert(capFile && rawFile && host, 'usage: verify-sgr.mjs CAPABILITIES RAW HOST_PROFILE');
const expectedHosts = {
  'xterm-default': { mode: 'Basic8', source: 'terminfo', pairs: ['36|41', '31|41', '37|41'] },
  'xterm-256color': { mode: 'Indexed256', source: 'terminfo', pairs: ['38;5;33|101', '91|101', '38;5;255|101'] },
  'xfce-vte': { mode: 'TrueColor', source: 'terminfo+COLORTERM', pairs: ['38;2;1;128;254|48;2;250;0;0', '38;2;250;0;0|48;2;250;0;0', '38;2;238;238;238|48;2;250;0;0'] },
};
const expected = expectedHosts[host]; assert(expected, 'unknown host profile ' + host);
const fields = Object.create(null);
for (const field of readFileSync(capFile, 'utf8').trim().split(';')) {
  const separator = field.indexOf('='); assert(separator > 0, 'malformed diagnostic field');
  const key = field.slice(0, separator); assert(!(key in fields), 'duplicate diagnostic ' + key);
  fields[key] = field.slice(separator + 1);
}
const attributes = new Map([[1, 'supportsBold'], [2, 'supportsDim'], [3, 'supportsItalic'], [4, 'supportsUnderline'], [7, 'supportsInverse'], [9, 'supportsStrikethrough']]);
for (const key of ['colorKnown', 'terminfoKnown', ...attributes.values()]) assert(['true', 'false'].includes(fields[key]), 'missing/invalid boolean ' + key);
assert.equal(fields.colorKnown, 'true', 'real-host colors must have confirmed provenance');
assert.equal(fields.terminfoKnown, 'true', 'real-host terminfo must be known');
assert.equal(fields.source, expected.source, 'expected host capability source');
assert.equal(fields.colorMode, expected.mode, 'expected host color mode');
assert.equal(fields.reason, '', 'host capability detection must succeed');
assert(/^-?\d+$/.test(fields.ncv ?? ''), 'missing/invalid ncv');
const ncv = Number(fields.ncv); assert(Number.isSafeInteger(ncv) && ncv >= -1, 'ncv range');
const raw = readFileSync(rawFile);
for (const text of ['AUTO RGB 1,128,254', 'Unicode:', '中文', 'EVENT-FENCE', 'Resize edge:']) assert(raw.includes(Buffer.from(text)), 'missing scene text: ' + text);
let fg = 'default', bg = 'default', active = new Set(), named = 0, indexed = 0, rgb = 0, sequences = 0;
const observedPairs = new Set();
function validateText(text) {
  if (!text) return;
  if (ncv > 0 && (fg !== 'default' || bg !== 'default')) {
    const mask = BigInt(ncv), modeled = 2n | 4n | 16n | 32n;
    if ((mask & ~modeled) !== 0n) assert.equal(active.size, 0, 'unknown NCV bit removes all colored attributes');
    for (const [bit, sgr] of [[2n, 4], [4n, 7], [16n, 2], [32n, 1]]) {
      if ((mask & bit) !== 0n) assert(!active.has(sgr), 'NCV forbids colored SGR' + sgr);
    }
  }
  if (text.includes('AUTO RGB 1,128,254')) {
    const pair = fg + '|' + bg;
    assert(expected.pairs.includes(pair), 'unexpected nominal RGB sample projection ' + pair);
    observedPairs.add(pair);
  }
}
for (const token of raw.toString('utf8').matchAll(/\x1b\[([0-9;]*)([A-Za-z])|([^\x1b]+)/g)) {
  if (token[3] !== undefined) { validateText(token[3]); continue; }
  if (token[2] !== 'm') continue;
  sequences++;
  const values = token[1] === '' ? [0] : token[1].split(';').map(Number);
  for (let i = 0; i < values.length; i++) {
    const code = values[i];
    if (code === 0) { fg = 'default'; bg = 'default'; active = new Set(); continue; }
    if (attributes.has(code)) {
      assert.equal(fields[attributes.get(code)], 'true', 'unsupported SGR' + code); active.add(code); continue;
    }
    if ((code >= 30 && code <= 37) || (code >= 90 && code <= 97) || (code >= 40 && code <= 47) || (code >= 100 && code <= 107)) {
      if (fields.colorMode === 'Basic8') assert(code < 90, 'Basic8 emitted bright SGR' + code);
      if ((code >= 30 && code <= 37) || (code >= 90 && code <= 97)) fg = String(code); else bg = String(code);
      named++; continue;
    }
    if (code === 38 || code === 48) {
      const kind = values[++i], count = kind === 2 ? 3 : kind === 5 ? 1 : 0;
      assert(count, 'unsupported extended SGR kind');
      const channels = values.slice(i + 1, i + 1 + count);
      assert.equal(channels.length, count, 'truncated extended SGR');
      assert(channels.every(value => Number.isInteger(value) && value >= 0 && value <= 255), 'invalid SGR channel');
      assert(!['Basic8', 'Basic16', 'Monochrome'].includes(fields.colorMode), 'basic/monochrome emitted extended color');
      if (fields.colorMode === 'Indexed256') assert.equal(kind, 5, 'Indexed256 emitted RGB');
      const color = [code, kind, ...channels].join(';');
      if (code === 38) fg = color; else bg = color;
      if (kind === 2) rgb++; else indexed++;
      i += count; continue;
    }
    assert.fail('undeclared SGR' + code);
  }
}
assert(sequences, 'no SGR bytes in actual inner TTY');
for (const pair of expected.pairs) assert(observedPairs.has(pair), 'missing RGB cycle sample ' + pair);
console.log('PASS SGR host=' + host + ' profile=' + fields.colorMode + ' sequences=' + sequences + ' named=' + named + ' indexed=' + indexed + ' rgb=' + rgb);

import assert from 'node:assert/strict';
import { execFile } from 'node:child_process';
import { mkdtemp, writeFile, rm } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { fileURLToPath } from 'node:url';
import { promisify } from 'node:util';
import test from 'node:test';
const exec = promisify(execFile);
const verifier = fileURLToPath(new URL('verify-sgr.mjs', import.meta.url));
const base = { colorMode: 'Basic8', colorKnown: 'true', terminfoKnown: 'true', source: 'terminfo', reason: '', ncv: '-1',
  supportsBold: 'true', supportsDim: 'true', supportsItalic: 'true', supportsUnderline: 'true', supportsInverse: 'true', supportsStrikethrough: 'true' };
const sample = codes => `\x1b[0m\x1b[1;1H${codes}AUTO RGB 1,128,254\x1b[0m`;
const basic = sample('\x1b[36m\x1b[41m') + sample('\x1b[31m\x1b[41m') + sample('\x1b[37m\x1b[41m') + 'Unicode: 中文 EVENT-FENCE Resize edge:';
async function verify(fields, raw, profile = 'xterm-default') {
  const directory = await mkdtemp(join(tmpdir(), 'cjtui-sgr-'));
  try {
    const cap = join(directory, 'cap.txt'), bytes = join(directory, 'raw');
    await writeFile(cap, Object.entries(fields).map(([key, value]) => `${key}=${value}`).join(';'));
    await writeFile(bytes, raw);
    return await exec(process.execPath, [verifier, cap, bytes, profile]);
  } finally { await rm(directory, { recursive: true }); }
}
async function rejects(fields, raw, profile) { await assert.rejects(verify(fields, raw, profile), error => error.code === 1); }
test('accepts frozen Basic8 host and three nominal sample mappings', async () => { await verify(base, basic); });
test('rejects Basic8 bright foreground and background', async () => {
  await rejects(base, basic + sample('\x1b[91m'));
  await rejects(base, basic + sample('\x1b[101m'));
});
test('rejects unknown provenance, missing fields, invalid booleans and host mismatch', async () => {
  await rejects({ ...base, source: 'unknown', terminfoKnown: 'false', colorKnown: 'false' }, basic);
  const missing = { ...base }; delete missing.supportsBold; await rejects(missing, basic);
  await rejects({ ...base, supportsDim: 'yes' }, basic);
  await rejects({ ...base, reason: 'terminfo-entry-unavailable' }, basic);
  await rejects(base, basic, 'xterm-256color');
});
test('rejects wrong nominal sample projection even inside supported color class', async () => {
  await rejects(base, basic.replace('\x1b[36m', '\x1b[34m'));
});
test('applies combined NCV bits in colored context and preserves legal uncolored attributes', async () => {
  await rejects({ ...base, ncv: '18' }, basic + sample('\x1b[31m\x1b[4m'));
  await rejects({ ...base, ncv: '36' }, basic + sample('\x1b[31m\x1b[7m'));
  await rejects({ ...base, ncv: '19' }, basic + sample('\x1b[31m\x1b[3m'));
  await verify({ ...base, ncv: '18' }, basic + '\x1b[0m\x1b[4mUNCOLORED\x1b[0m');
  await verify({ ...base, ncv: '4' }, basic + '\x1b[0m\x1b[31m\x1b[2mDIM-ALLOWED\x1b[0m');
});
test('rejects unsupported attribute and missing expected foreground/background mapping', async () => {
  await rejects({ ...base, supportsBold: 'false' }, basic + '\x1b[1mBOLD\x1b[0m');
  await rejects(base, basic.replaceAll('\x1b[41m', '\x1b[42m'));
});
test('accepts indexed and direct profiles with literal expected mappings', async () => {
  const indexed = sample('\x1b[38;5;33m\x1b[101m') + sample('\x1b[91m\x1b[101m') + sample('\x1b[38;5;255m\x1b[101m') + 'Unicode: 中文 EVENT-FENCE Resize edge:';
  await verify({ ...base, colorMode: 'Indexed256' }, indexed, 'xterm-256color');
  const rgb = [sample('\x1b[38;2;1;128;254m\x1b[48;2;250;0;0m'), sample('\x1b[38;2;250;0;0m\x1b[48;2;250;0;0m'), sample('\x1b[38;2;238;238;238m\x1b[48;2;250;0;0m')].join('') + 'Unicode: 中文 EVENT-FENCE Resize edge:';
  await verify({ ...base, colorMode: 'TrueColor', source: 'terminfo+COLORTERM' }, rgb, 'xfce-vte');
});

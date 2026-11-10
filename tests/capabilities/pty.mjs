#!/usr/bin/env node
// A synthetic terminfo branch suite. Real-host visual evidence belongs to TASK-066.
import assert from 'node:assert/strict';
import { spawn, spawnSync } from 'node:child_process';
import { mkdtemp, mkdir, readFile, writeFile } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import { join, resolve } from 'node:path';

const root = resolve(process.cwd());
const binary = resolve(process.env.CJTUI_CAPABILITY_BIN ?? 'tests/capabilities/session/target/release/bin/main');
const terminfo = resolve(process.env.CJTUI_CAPABILITY_TERMINFO ?? 'tests/capabilities/generated-terminfo');
const artifacts = resolve(process.env.CJTUI_CAPABILITY_ARTIFACTS ?? await mkdtemp(join(tmpdir(), 'cjtui-capabilities-')));
await mkdir(artifacts, { recursive: true });
const sleep = milliseconds => new Promise(resolve => setTimeout(resolve, milliseconds));
const quote = text => `'${text.replaceAll("'", "'\\''")}'`;
const read = async path => { try { return await readFile(path, 'utf8'); } catch { return ''; } };
async function until(predicate, name, milliseconds = 8000) {
  const deadline = Date.now() + milliseconds;
  while (Date.now() < deadline) { if (await predicate()) return; await sleep(10); }
  throw new Error(`timeout: ${name}`);
}
function parseReport(text) {
  const result = Object.create(null);
  for (const line of text.trim().split('\n')) {
    const index = line.indexOf('=');
    assert(index > 0, `report line ${JSON.stringify(line)}`);
    result[line.slice(0, index)] = line.slice(index + 1);
  }
  return result;
}
async function runCase(name, environment, action = '') {
  const directory = join(artifacts, name); await mkdir(directory, { recursive: true });
  const report = join(directory, 'profile.txt');
  const wrapper = join(directory, 'session.sh');
  await writeFile(wrapper, '#!/bin/sh\nstty rows 5 cols 24\nstty -g > "$2/before"\ntty > "$2/tty"\n"$1" < /dev/tty &\np=$!\necho "$p" > "$2/pid"\nwait "$p"\nstatus=$?\nstty -g > "$2/after"\nexit "$status"\n');
  const childEnvironment = { ...process.env, ...environment, TERMINFO: terminfo, CJTUI_CAPABILITY_REPORT: report };
  for (const [key, value] of Object.entries(childEnvironment)) if (value === null) delete childEnvironment[key];
  const child = spawn('script', ['--quiet', '--return', '--flush', '--command', `sh ${quote(wrapper)} ${quote(binary)} ${quote(directory)}`, '/dev/null'], {
    stdio: ['pipe', 'pipe', 'pipe'],
    env: childEnvironment
  });
  let raw = Buffer.alloc(0), stderr = '', finished = false, code, signal, processError;
  child.stdout.on('data', bytes => { raw = Buffer.concat([raw, bytes]); });
  child.stderr.on('data', bytes => { stderr += bytes.toString(); });
  child.on('error', error => { processError = error; finished = true; });
  child.on('exit', (value, valueSignal) => { code = value; signal = valueSignal; finished = true; });
  try {
    await until(async () => Number((await read(join(directory, 'pid'))).trim()) > 0, `${name} pid`);
    await until(() => raw.includes(Buffer.from('COLOR')), `${name} first frame`);
    if (action) child.stdin.write(action);
    child.stdin.write('p');
    await until(async () => (await read(report)).includes('colorMode='), `${name} profile after render`);
    child.stdin.write('q');
    await until(() => finished, `${name} q exit`);
    if (processError) throw processError;
    assert.equal(code, 0, `${name}: direct application exit`); assert.equal(signal, null, `${name}: no forced signal`);
    const before = (await read(join(directory, 'before'))).trim(), after = (await read(join(directory, 'after'))).trim();
    assert(before && after, `${name}: termios evidence exists`); assert.equal(after, before, `${name}: exact termios restoration`);
    const profile = parseReport(await read(report));
    await writeFile(join(directory, 'session.raw'), raw); await writeFile(join(directory, 'stderr.txt'), stderr);
    await writeFile(join(directory, 'result.json'), JSON.stringify({ name, code, signal, profile }, null, 2));
    return { profile, raw: raw.toString('utf8') };
  } catch (error) {
    await writeFile(join(directory, 'session.raw'), raw); await writeFile(join(directory, 'stderr.txt'), stderr);
    await writeFile(join(directory, 'result.json'), JSON.stringify({ name, code, signal, error: error.message }, null, 2));
    throw error;
  } finally {
    if (!finished) child.kill('SIGKILL');
    child.stdin.destroy();
  }
}
function profile(result, expected, name) {
  for (const [key, value] of Object.entries(expected)) assert.equal(result.profile[key], String(value), `${name}: ${key}`);
}
let failures = 0;
try {
  for (const [command, argument] of [['script', '--version'], ['stty', '--version'], ['tic', '-V']]) assert.equal(spawnSync(command, [argument]).status, 0, `${command} available`);
  const cases = [
    ['eight', { TERM: 'cap-8' }, { colorMode: 'Basic8', colorKnown: true, terminfoKnown: true, source: 'terminfo', reason: '', noColorVideo: -1 }],
    ['mono', { TERM: 'cap-mono' }, { colorMode: 'Monochrome', colorKnown: true, terminfoKnown: true, source: 'terminfo', reason: '', noColorVideo: -1 }],
    ['sixteen', { TERM: 'cap-16' }, { colorMode: 'Basic16', colorKnown: true, terminfoKnown: true, source: 'terminfo', reason: '' }],
    ['indexed', { TERM: 'cap-256' }, { colorMode: 'Indexed256', colorKnown: true, terminfoKnown: true, source: 'terminfo', reason: '' }],
    ['direct', { TERM: 'cap-direct' }, { colorMode: 'TrueColor', colorKnown: true, terminfoKnown: true, source: 'terminfo', reason: '' }],
    ['terminfo-colorterm', { TERM: 'cap-16', COLORTERM: 'truecolor' }, { colorMode: 'TrueColor', colorKnown: true, terminfoKnown: true, source: 'terminfo+COLORTERM', reason: '' }],
    ['unknown', { TERM: 'cap-unknown' }, { colorMode: 'Monochrome', colorKnown: false, terminfoKnown: false, source: 'unknown', reason: 'terminfo-entry-unavailable' }],
    ['colorterm-only', { TERM: 'cap-unknown', COLORTERM: '24BIT' }, { colorMode: 'TrueColor', colorKnown: true, terminfoKnown: false, source: 'COLORTERM', reason: 'terminfo-entry-unavailable' }],
    ['unset', { TERM: null, COLORTERM: 'truecolor' }, { colorMode: 'Monochrome', colorKnown: false, terminfoKnown: false, source: 'unknown', reason: 'term-unset' }],
    ['dumb', { TERM: 'dumb', COLORTERM: 'truecolor' }, { colorMode: 'Monochrome', colorKnown: false, terminfoKnown: false, source: 'unknown', reason: 'term-dumb' }],
    ['invalid', { TERM: 'bad;term', COLORTERM: 'truecolor' }, { colorMode: 'Monochrome', colorKnown: false, terminfoKnown: false, source: 'unknown', reason: 'term-invalid' }],
  ];
  for (const [name, environment, expected] of cases) {
    const result = await runCase(name, environment); profile(result, expected, name);
    if (name === 'eight') { assert(result.raw.includes('\x1b[31mCOLOR'), 'Basic8 maps BrightRed to the nominal eight-color red'); assert(!result.raw.includes('\x1b[91mCOLOR'), 'Basic8 does not emit bright SGR'); }
    if (name === 'sixteen') assert(result.raw.includes('\x1b[91mCOLOR'), 'Basic16 retains BrightRed');
    if (name === 'indexed') assert(result.raw.includes('\x1b[38;5;33m'), 'Indexed256 maps RGB through the nominal indexed palette');
    if (name === 'direct' || name === 'colorterm-only') assert(result.raw.includes('\x1b[38;2;1;128;254m'), `${name} emits direct RGB`);
    if (name === 'direct') {
      profile(result, { bold: true, dim: true, italic: true, underline: true, inverse: true, strikethrough: true }, 'direct known SGR capabilities');
      for (const sgr of ['1', '2', '3', '4', '7', '9']) assert(result.raw.includes(`\x1b[${sgr}m`), `direct accepts known SGR${sgr}`);
    }
    if (name === 'mono') {
      assert(!/\x1b\[(?:3[0-7]|9[0-7]|38;|4[0-7]|10[0-7]|48;)m/.test(result.raw), 'known monochrome omits colors');
      for (const sgr of ['1', '2', '3', '4', '7', '9']) assert(result.raw.includes(`\x1b[${sgr}m`), `known monochrome retains supported non-color SGR${sgr}`);
    }
    if (name === 'colorterm-only') {
      for (const sgr of ['1', '2', '3', '4', '7', '9']) assert(!result.raw.includes(`\x1b[${sgr}m`), `COLORTERM-only has no attribute support evidence for SGR${sgr}`);
    }
    if (['unknown', 'unset', 'dumb', 'invalid'].includes(name)) assert(!/\x1b\[(?:3[0-7]|9[0-7]|38;|4[0-7]|10[0-7]|48;|[123479])m/.test(result.raw), `${name} emits no unsupported color or video SGR`);
  }
  const ncv18 = await runCase('ncv18', { TERM: 'cap-ncv18' }); profile(ncv18, { colorMode: 'Basic8', noColorVideo: 18, dim: true, underline: true }, 'ncv18');
  for (const sgr of ['1', '3', '7', '9']) assert(ncv18.raw.includes(`\x1b[${sgr}m`), `ncv18 retains SGR${sgr}`);
  for (const sgr of ['2', '4']) assert(!ncv18.raw.includes(`\x1b[${sgr}m`), `ncv18 removes color-conflicting SGR${sgr}`);
  const ncvUnknown = await runCase('ncv-unknown', { TERM: 'cap-ncv-unknown' }); profile(ncvUnknown, { colorMode: 'Basic8', noColorVideo: 19 }, 'ncv unknown bit');
  for (const sgr of ['1', '2', '3', '4', '7', '9']) assert(!ncvUnknown.raw.includes(`\x1b[${sgr}m`), `unknown ncv bit conservatively removes SGR${sgr}`);
  const nonSgr = await runCase('non-sgr', { TERM: 'cap-nonsgr' }); profile(nonSgr, { colorMode: 'Basic8', bold: false }, 'non-SGR capability');
  assert(!nonSgr.raw.includes('\x1b[99m'), 'terminfo strings are never forwarded to the device'); assert(!nonSgr.raw.includes('\x1b[1m'), 'unsafe bold capability is not treated as standard SGR1');
  const override = await runCase('override-auto', { TERM: 'cap-direct', CJTUI_CAPABILITY_OVERRIDE: '1' }, { colorMode: 'TrueColor' }, 'a');
  assert(override.raw.includes('\x1b[31mCOLOR'), 'explicit Basic8 override changes first device projection'); assert(override.raw.includes('\x1b[91mCOLOR'), 'colorModeAuto restores the fixed automatic profile during the session');
  const isolated = await runCase('isolation', { TERM: 'cap-256', CJTUI_CAPABILITY_SEED: '1' }); profile(isolated, { colorMode: 'Indexed256', seededColors: 16, baseColors: 16 }, 'private terminfo namespace isolation');
  const loaderFail = await runCase('loader-fail', { TERM: 'cap-256', CJTUI_CAP_TEST_DLMOPEN_FAIL: '1' }); profile(loaderFail, { colorMode: 'Monochrome', colorKnown: false, terminfoKnown: false, source: 'unknown', reason: 'terminfo-library-unavailable' }, 'optional loader failure');
  console.log(`PASS synthetic capability branches: artifacts=${artifacts}`);
} catch (error) { failures++; console.error(`FAIL capabilities: ${error.stack}`); }
if (failures) process.exitCode = 1;

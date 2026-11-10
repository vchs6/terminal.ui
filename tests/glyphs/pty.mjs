#!/usr/bin/env node
import assert from 'node:assert/strict';
import { spawn } from 'node:child_process';
import { mkdtemp, mkdir, readFile, writeFile } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import { join, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

const root = fileURLToPath(new URL('../..', import.meta.url));
const binary = resolve(root, 'tests/glyphs/session/target/release/bin/main');
const artifacts = resolve(process.env.CJTUI_GLYPH_ARTIFACTS ?? await mkdtemp(join(tmpdir(), 'glyph-pty-')));
await mkdir(artifacts, { recursive: true });
const delay = ms => new Promise(resolve => setTimeout(resolve, ms));
const quote = value => `'${value.replaceAll("'", "'\\''")}'`;
const read = async path => { try { return await readFile(path, 'utf8'); } catch { return ''; } };
async function until(predicate, label) {
  const end = Date.now() + 10000;
  while (Date.now() < end) { if (await predicate()) return; await delay(10); }
  throw Error(`timeout ${label}`);
}
function report(text) {
  return Object.fromEntries(text.trim().split('\n').map(line => {
    const split = line.indexOf('='); assert(split > 0, `report ${line}`);
    return [line.slice(0, split), line.slice(split + 1)];
  }));
}
function rows(bytes) {
  const text = bytes.toString('utf8');
  return [...text.matchAll(/\x1b\[(\d+);1H([^\x1b]*(?:\x1b\[[0-9;]*m[^\x1b]*)*)/gu)]
    .map(match => ({ row: Number(match[1]), text: match[2].replaceAll(/\x1b\[[0-9;]*m/gu, '') }));
}
class Session {
  async start(name, scenario, mode = 'Auto', term = 'dumb') {
    this.name = name; this.scenario = scenario; this.directory = join(artifacts, name);
    await mkdir(this.directory, { recursive: true });
    this.path = join(this.directory, 'report.txt'); this.tracePath = join(this.directory, 'syscalls.txt');
    this.capturePath = join(this.directory, 'stdout-write.raw');
    this.raw = Buffer.alloc(0); this.stderr = ''; this.serial = 0; this.finished = false;
    const wrapper = join(this.directory, 'session.sh');
    await writeFile(wrapper, '#!/bin/sh\nstty rows 6 cols 32\nstty -g > "$2/before"\n"$1" < /dev/tty &\np=$!\necho "$p" > "$2/pid"\nwait "$p"\nr=$?\nstty -g > "$2/after"\nexit "$r"\n');
    this.child = spawn('script', ['--quiet', '--return', '--flush', '--command',
      `sh ${quote(wrapper)} ${quote(binary)} ${quote(this.directory)}`, '/dev/null'], {
      stdio: ['pipe', 'pipe', 'pipe'], env: { ...process.env, TERM: term, COLORTERM: '',
        CJTUI_GLYPH_MODE: mode, CJTUI_GLYPH_REPORT: this.path,
        CJTUI_GLYPH_TEST_NATIVE: scenario, CJTUI_GLYPH_TEST_TRACE: this.tracePath,
        CJTUI_GLYPH_TEST_CAPTURE: this.capturePath }
    });
    this.child.stdout.on('data', value => { this.raw = Buffer.concat([this.raw, value]); });
    this.child.stderr.on('data', value => { this.stderr += value; });
    this.child.on('error', error => { this.error = error; this.finished = true; });
    this.child.on('close', (code, signal) => { this.code = code; this.signal = signal; this.finished = true; });
    await until(async () => rows(Buffer.from(await read(this.capturePath))).some(row => row.row === 6), `${name} initial complete frame`);
    return this.sync();
  }
  async sync(action = '') {
    this.serial++;
    this.child.stdin.write(action + 'p');
    await until(async () => (await read(this.path)).includes(`serial=${this.serial}\n`), `${this.name} UI fence`);
    // Input callback p is reached after the next safe refresh following action.
    return report(await read(this.path));
  }
  async delta(action) {
    const before = (await readFile(this.capturePath)).length;
    const state = await this.sync(action);
    return { state, bytes: (await readFile(this.capturePath)).subarray(before) };
  }
  async close() {
    this.child.stdin.write('q');
    await until(() => this.finished, `${this.name} exit`);
    if (this.error) throw this.error;
    assert.equal(this.code, 0, `${this.name} direct application exit`);
    assert.equal(this.signal, null);
    assert.deepEqual(this.raw, await readFile(this.capturePath), 'PTY stream equals successfully written actual stdout bytes');
    assert.equal((await read(join(this.directory, 'after'))).trim(),
      (await read(join(this.directory, 'before'))).trim(), `${this.name} termios restored`);
    const retained = report(await read(this.path));
    assert.equal(retained.serial, String(this.serial), 'diagnostic retained after run cleanup');
    await this.persist();
  }
  async persist() {
    await writeFile(join(this.directory, 'stdout.raw'), this.raw);
    await writeFile(join(this.directory, 'stderr.txt'), this.stderr);
    await writeFile(join(this.directory, 'result.json'), JSON.stringify({ code: this.code, signal: this.signal,
      scenario: this.scenario, report: await read(this.path) }, null, 2));
  }
  async abort() {
    await this.persist();
    if (!this.finished) this.child.kill('SIGKILL');
    this.child.stdin.destroy();
  }
}
const known = { nativeVt: 'true', mapKnown: 'true', entryCount: '104', source: 'linux-vt-unimap', reason: '', nativeError: '0' };
const unknown = { nativeVt: 'false', mapKnown: 'false', entryCount: '0', source: 'unknown', nativeError: '0' };
const failedMap = { nativeVt: 'true', mapKnown: 'false', entryCount: '0', source: 'linux-vt-unavailable' };
function expectProfile(actual, expected, label) {
  for (const [key, value] of Object.entries(expected)) assert.equal(actual[key], value, `${label} ${key}`);
}
const original = 'é e\u0301 中文 😀 ✈\ufe0f 👩‍💻 …';
// G012/A003 hand golden: model-consistent clusters stay raw; VS16 and ZWJ
// disagreement becomes the same two stored columns. Offline/Unicode stays raw.
const conservative = 'é e\u0301 中文 😀 ?? ?? …';
const projected = 'é ? ???? ?? ?? ?? …';
const ascii = '? ? ???? ?? ?? ?? ?';
const cases = [
  ['real-pty-auto', 'real', 'Auto', { ...unknown, reason: 'not-concrete-linux-vt' }, conservative],
  ['real-pty-term-linux', 'real', 'Auto', { ...unknown, reason: 'not-concrete-linux-vt' }, conservative, 'linux'],
  ['real-pty-unicode', 'real', 'Unicode', { ...unknown, reason: 'not-concrete-linux-vt' }, original],
  ['real-pty-ascii', 'real', 'Ascii', { ...unknown, reason: 'not-concrete-linux-vt' }, ascii],
  ['mapped', 'mapped', 'Auto', known, projected],
  ['minor63', 'minor63', 'Auto', known, projected],
  ['max-duplicates', 'max', 'Auto', { ...known, entryCount: '65535' }, projected],
  ['mapped-unicode-override', 'mapped', 'Unicode', known, original],
  ['mapped-ascii-override', 'mapped', 'Ascii', known, ascii],
  ['empty-map', 'empty', 'Auto', { ...known, entryCount: '0', reason: 'ascii-fallback-unavailable' }, ' '.repeat(19)],
  ['question-missing', 'no-question', 'Auto', { ...known, reason: 'ascii-fallback-unavailable' }, 'é ' + ' '.repeat(16) + '…'],
  ['border-fallback-missing', 'no-border', 'Auto', known, projected],
  ['map-read-fail', 'map-fail', 'Auto', { ...failedMap, reason: 'map-query-failed', nativeError: '13' }, ascii],
  ['allocation-fail', 'alloc-fail', 'Auto', { ...failedMap, reason: 'map-allocation-failed', nativeError: '0' }, ascii],
  ['allocation-fail-unicode', 'alloc-fail', 'Unicode', { ...failedMap, reason: 'map-allocation-failed', nativeError: '0' }, original],
  ['fstat-fail', 'fstat-fail', 'Auto', { ...unknown, reason: 'vt-query-failed', nativeError: '5' }, conservative],
  ['vt-query-fail', 'vt-fail', 'Auto', { ...unknown, reason: 'vt-query-failed', nativeError: '13' }, conservative],
  ['kd-query-fail', 'kd-fail', 'Auto', { ...unknown, reason: 'vt-query-failed', nativeError: '5' }, conservative],
  ['graphics', 'graphics', 'Auto', { ...unknown, reason: 'not-text-mode' }, conservative],
  ...['alias-tty0', 'alias-console', 'alias-tty', 'minor64', 'regular'].map(scenario =>
    [scenario, scenario, 'Auto', { ...unknown, reason: 'not-concrete-linux-vt' }, conservative]),
  ['not-tty', 'not-tty', 'Auto', { ...unknown, reason: 'not-tty' }, conservative]
];
let active;
try {
  for (const [name, scenario, mode, expected, content, term] of cases) {
    active = new Session();
    const state = await active.start(name, scenario, mode, term);
    expectProfile(state, expected, name); assert.equal(state.mode, mode);
    const second = rows(await readFile(active.capturePath)).find(row => row.row === 2);
    assert(second, `${name} content row exists`);
    assert.equal(second.text, content + ' '.repeat(13), `${name} full 32-column content row`);
    const border = rows(await readFile(active.capturePath)).find(row => row.row === 3);
    const unicodeBorder = mode === 'Unicode' || (mode === 'Auto' && expected.nativeVt === 'false');
    const expectedBorder = unicodeBorder ? '╭───╮' : scenario === 'empty' ? '     ' :
      scenario === 'no-border' ? '?????' : '+---+';
    assert.equal(border?.text, expectedBorder + ' '.repeat(27), `${name} actual shared border fallback`);
    const trace = await read(active.tracePath);
    assert(!/ioctl fd=(?!1\b)/u.test(trace), `${name} glyph probes actual stdout only`);
    if (expected.nativeVt === 'false') assert(!trace.includes('unimap capacity='), `${name} unknown identity never reads map`);
    if (expected.nativeVt === 'true') {
      assert.equal((trace.match(/fstat fd=1\n/gu) ?? []).length, 1, `${name} concrete identity from actual stdout`);
      assert.equal((trace.match(/allocate bytes=262140\n/gu) ?? []).length, 1, `${name} single bounded allocation`);
      if (scenario === 'alloc-fail') {
        assert(!trace.includes('unimap capacity='), `${name} allocation failure never reads map`);
      } else {
        assert.equal((trace.match(/unimap capacity=65535\n/gu) ?? []).length, 1, `${name} bounded one map read`);
        assert.equal((trace.match(/free pairs\n/gu) ?? []).length, 1, `${name} temporary pairs freed even on query failure`);
      }
    }
    if (name === 'mapped') {
      const mounted = state.mounted;
      assert.equal((await active.delta('v')).bytes.length, 0, '中→文 projected equality is byte-silent');
      assert.equal((await active.delta('t')).bytes.length, 0, '中→?? raw continuation shape equality is byte-silent');
      const narrow = await active.delta('n');
      assert.deepEqual(rows(narrow.bytes), [{ row: 1, text: 'A' + ' '.repeat(31) }], 'wide→narrow complete row clears stale cells');
      const switched = await active.delta('a');
      assert(rows(switched.bytes).some(row => row.row === 2 && row.text === ascii + ' '.repeat(13)), 'setter alone wakes actual run and updates profile');
      assert(Number(switched.state.measures) > Number(narrow.state.measures), 'setter invalidates layout policy cache');
      assert.equal(switched.state.mounted, mounted, 'setter preserves runtime node identities/count');
      const unchanged = await active.delta('a');
      assert.equal(unchanged.bytes.length, 0, 'same selected mode setter does no output');
      assert.equal(unchanged.state.frames, switched.state.frames, 'same mode setter does not dirty layout cache');
      assert(rows((await active.delta('u')).bytes).some(row => row.row === 2 && row.text === original + ' '.repeat(13)), 'Unicode switch reprojects original logical source');
      assert(rows((await active.delta('o')).bytes).some(row => row.row === 2 && row.text === projected + ' '.repeat(13)), 'Auto restored after explicit overrides');
    }
    if (name === 'real-pty-ascii') {
      assert.equal((await active.delta('v')).bytes.length, 0, 'real PTY Ascii equivalent glyph diff');
      assert.equal((await active.delta('b')).bytes.length, 0, 'real PTY simultaneous equivalent color and glyph diff');
    }
    if (name === 'real-pty-auto') {
      const mounted = state.mounted;
      assert.deepEqual(rows((await active.delta('z')).bytes), [{ row: 1, text: '??' + ' '.repeat(30) }],
        'G012 unknown Auto projects ZWJ as exactly two columns');
      assert.equal((await active.delta('h')).bytes.length, 0, 'ZWJ to VS16 equal projected columns is silent');
      assert.equal((await active.delta('t')).bytes.length, 0, 'VS16 to literal question cells is silent');
      assert.equal((await active.delta('z')).bytes.length, 0, 'literal questions to wide ZWJ is silent');
      const explicit = await active.delta('u');
      assert(rows(explicit.bytes).some(row => row.row === 1 && row.text === '👩‍💻' + ' '.repeat(30)),
        'explicit Unicode restores raw ZWJ on unknown PTY');
      assert(rows(explicit.bytes).some(row => row.row === 2 && row.text === original + ' '.repeat(13)),
        'explicit Unicode keeps original VS16 and ZWJ');
      const restored = await active.delta('o');
      assert(rows(restored.bytes).some(row => row.row === 1 && row.text === '??' + ' '.repeat(30)),
        'Auto restores conservative profile using previous Unicode baseline');
      assert(rows(restored.bytes).some(row => row.row === 2 && row.text === conservative + ' '.repeat(13)),
        'Auto conservative source row returns');
      assert(Number(restored.state.measures) > Number(explicit.state.measures), 'Auto setter invalidates layout cache');
      assert.equal(restored.state.mounted, mounted, 'G012 mode changes preserve mounted identity count');
      const unchanged = await active.delta('o');
      assert.equal(unchanged.bytes.length, 0, 'same Auto setter emits zero bytes');
      assert.equal(unchanged.state.frames, restored.state.frames, 'same Auto setter does not dirty layout');
    }
    await active.close();
    expectProfile(report(await read(active.path)), expected, `${name} retained diagnostic after headless/offline export`);
    assert((await read(active.path + '.snapshot')).includes(original), `${name} last run/device override never pollutes default offline snapshot`);
    const finalTrace = await read(active.tracePath);
    if (expected.mapKnown === 'true') assert.equal((finalTrace.match(/unimap capacity=/gu) ?? []).length, 1,
      `${name} mode, snapshot and cell refresh never redetect map`);
    active = null;
    console.log(`PASS ${name}`);
  }
  console.log(`PASS glyph PTY/syscall branch suite; artifacts=${artifacts}`);
} finally { if (active) await active.abort(); }

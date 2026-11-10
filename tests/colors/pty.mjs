#!/usr/bin/env node
// Public consumers and the actual examples/colors executable in real Linux PTYs.
import assert from 'node:assert/strict';
import { spawn, spawnSync } from 'node:child_process';
import { mkdir, mkdtemp, readFile, writeFile } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import { resolve, join } from 'node:path';
import { StringDecoder } from 'node:string_decoder';

const artifacts = resolve(process.env.CJTUI_COLOR_ARTIFACTS ?? await mkdtemp(join(tmpdir(), 'cjtui-colors-')));
await mkdir(artifacts, { recursive: true });
const delay = ms => new Promise(resolve => setTimeout(resolve, ms));
const quote = text => `'${text.replaceAll("'", "'\\''")}'`;
const read = async path => { try { return await readFile(path, 'utf8'); } catch { return ''; } };
async function until(predicate, name, ms = 9000) {
  const deadline = Date.now() + ms;
  while (Date.now() < deadline) { if (await predicate()) return; await delay(10); }
  throw new Error(`timeout: ${name}`);
}
function width(text) {
  let count = 0;
  for (const { segment } of new Intl.Segmenter('en', { granularity: 'grapheme' }).segment(text)) {
    const cp = segment.codePointAt(0);
    if (/^\p{Mark}+$/u.test(segment)) continue;
    const wide = /\p{Extended_Pictographic}|\p{Regional_Indicator}/u.test(segment) ||
      (cp >= 0x1100 && (cp <= 0x115f || cp === 0x2329 || cp === 0x232a ||
       (cp >= 0x2e80 && cp <= 0xa4cf && cp !== 0x303f) ||
       (cp >= 0xac00 && cp <= 0xd7a3) || (cp >= 0xf900 && cp <= 0xfaff) ||
       (cp >= 0xfe10 && cp <= 0xfe19) || (cp >= 0xfe30 && cp <= 0xfe6f) ||
       (cp >= 0xff00 && cp <= 0xff60) || (cp >= 0xffe0 && cp <= 0xffe6) || cp >= 0x20000));
    count += wide ? 2 : 1;
  }
  return count;
}
const freshStyle = () => ({ fg: 'default', bg: 'default', attributes: [] });
class Screen {
  constructor(w, h) { this.decoder = new StringDecoder('utf8'); this.pending = ''; this.style = freshStyle(); this.updates = []; this.resize(w, h); }
  resize(w, h) { this.w = w; this.h = h; this.rows = Array.from({ length: h }, () => ({ text: ' '.repeat(w), cells: [] })); this.row = null; this.text = ''; this.cells = []; }
  flush() {
    if (this.row === null) return;
    assert.equal(width(this.text), this.w, `complete row ${this.row + 1}: ${JSON.stringify(this.text)}`);
    this.rows[this.row] = { text: this.text, cells: this.cells };
    this.updates.push({ row: this.row + 1, text: this.text, cells: this.cells });
    this.row = null; this.text = ''; this.cells = [];
  }
  sgr(parameters) {
    const ns = parameters.split(';').map(Number);
    for (let i = 0; i < ns.length; i++) {
      const n = ns[i];
      if (n === 0) this.style = freshStyle();
      else if ([1, 2, 3, 4, 7, 9].includes(n)) { if (!this.style.attributes.includes(n)) this.style.attributes.push(n); }
      else if ((n >= 30 && n <= 37) || (n >= 90 && n <= 97)) this.style.fg = `named:${n}`;
      else if ((n >= 40 && n <= 47) || (n >= 100 && n <= 107)) this.style.bg = `named:${n}`;
      else if (n === 38 || n === 48) {
        const key = n === 38 ? 'fg' : 'bg', kind = ns[++i];
        assert([2, 5].includes(kind), 'standard indexed or RGB selection');
        const channels = ns.slice(i + 1, i + 1 + (kind === 2 ? 3 : 1));
        assert.equal(channels.length, kind === 2 ? 3 : 1);
        assert(channels.every(v => Number.isInteger(v) && v >= 0 && v <= 255));
        this.style[key] = `${kind === 2 ? 'rgb' : 'indexed'}:${channels.join(',')}`; i += channels.length;
      } else assert.fail(`unsupported SGR ${n}: output must use reset0 and declared six attributes/colors`);
    }
    // End-of-row SGR0 is the transport barrier; no timing guess marks row completion.
    if (parameters === '0' && this.row !== null && width(this.text) === this.w) this.flush();
  }
  feed(bytes) {
    this.pending += this.decoder.write(bytes);
    while (this.pending.length) {
      if (this.pending.startsWith('\x1b')) {
        const m = /^\x1b\[([0-9;]*)([A-Za-z])/.exec(this.pending);
        if (!m) { if (/^\x1b(?:\[[0-9;]*)?$/.test(this.pending)) return; throw new Error(`unsupported escape/OSC ${JSON.stringify(this.pending.slice(0, 40))}`); }
        this.pending = this.pending.slice(m[0].length);
        if (m[2] === 'm') this.sgr(m[1]);
        else {
          assert.equal(m[2], 'H', 'public example outputs only CUP and SGR'); this.flush();
          const [row, col] = m[1].split(';').map(Number);
          assert.equal(col, 1, 'complete rows start at column1');
          assert(row >= 1 && row <= this.h, `row ${row} inside actual height${this.h}`);
          this.row = row - 1;
        }
      } else {
        const end = this.pending.indexOf('\x1b'), text = end < 0 ? this.pending : this.pending.slice(0, end);
        assert(this.row !== null, 'text follows CUP');
        assert(!/[\x00-\x1f\x7f-\x9f]/u.test(text), 'no scrolling controls or injected output');
        this.text += text;
        // SGR segments preserve the complete style for each text segment.
        for (const { segment } of new Intl.Segmenter('en', { granularity: 'grapheme' }).segment(text)) this.cells.push({ text: segment, ...structuredClone(this.style) });
        this.pending = end < 0 ? '' : this.pending.slice(end);
      }
    }
  }
  snapshot() { assert.equal(this.pending, '', 'no incomplete escape'); assert.equal(this.row, null, 'row completed by reset'); return structuredClone(this.rows); }
}
class Session {
  constructor(name, binary, w, h) { this.name = name; this.binary = resolve(binary); this.w = w; this.h = h; this.raw = Buffer.alloc(0); this.stderr = ''; this.screen = new Screen(w, h); this.finished = false; this.lastBytes = 0; }
  async start() {
    this.dir = join(artifacts, this.name); await mkdir(this.dir, { recursive: true });
    const wrapper = join(this.dir, 'session.sh');
    await writeFile(wrapper, `#!/bin/sh\nstty rows ${this.h} cols ${this.w}\nstty -g > "$2/before"\ntty > "$2/tty"\n"$1" < /dev/tty &\np=$!\necho "$p" > "$2/pid"\nwait "$p"\nstatus=$?\nstty -g > "$2/after"\nexit "$status"\n`);
    this.child = spawn('script', ['--quiet', '--return', '--flush', '--command', `sh ${quote(wrapper)} ${quote(this.binary)} ${quote(this.dir)}`, '/dev/null'], {
      stdio: ['pipe', 'pipe', 'pipe'], env: { ...process.env, TERM: 'xterm-256color', COLORTERM: 'truecolor', CJTUI_COLOR_HANDSHAKE: this.dir }
    });
    this.child.stdout.on('data', bytes => { this.raw = Buffer.concat([this.raw, bytes]); this.lastBytes = Date.now(); try { this.screen.feed(bytes); } catch (e) { this.error ??= e; } });
    this.child.stderr.on('data', bytes => { this.stderr += bytes.toString(); });
    this.child.on('error', e => { this.error ??= e; this.finished = true; });
    this.child.on('exit', (code, signal) => { this.code = code; this.signal = signal; this.finished = true; });
    await until(async () => { this.pid = Number((await read(join(this.dir, 'pid'))).trim()); return this.pid > 0; }, `${this.name} pid`);
  }
  async wait(predicate, name) { await until(() => { if (this.error) throw this.error; assert(!this.finished, `application exited before ${name}: ${this.code}; ${this.stderr}`); return predicate(); }, name); }
  async settle(previous, name) {
    await this.wait(() => this.screen.updates.length > previous && Date.now() - this.lastBytes >= 100 && this.screen.row === null && this.screen.pending === '', name);
    return this.screen.snapshot();
  }
  async resize(w, h) {
    const before = this.screen.updates.length; this.screen.snapshot(); this.screen.resize(w, h);
    const tty = (await read(join(this.dir, 'tty'))).trim();
    const r = spawnSync('stty', ['-F', tty, 'rows', `${h}`, 'cols', `${w}`], { encoding: 'utf8' });
    assert.equal(r.status, 0, r.stderr); process.kill(this.pid, 'SIGWINCH');
    return this.settle(before, `resize ${w}x${h}`);
  }
  async stop() {
    this.child.stdin.write('q'); await until(() => this.finished, `${this.name} q exit`);
    assert.equal(this.code, 0, 'direct binary successful exit'); assert.equal(this.signal, null);
    const before = (await read(join(this.dir, 'before'))).trim(), after = (await read(join(this.dir, 'after'))).trim();
    assert(before && after, 'termios snapshots exist'); assert.equal(after, before, 'exact termios restored');
  }
  async save() {
    await writeFile(join(this.dir, 'session.raw'), this.raw); await writeFile(join(this.dir, 'stderr.txt'), this.stderr);
    await writeFile(join(this.dir, 'result.json'), JSON.stringify({ code: this.code, signal: this.signal, error: this.error?.message, updates: this.screen.updates }, null, 2));
    if (!this.finished) { if (this.pid) { try { process.kill(this.pid, 'SIGKILL'); } catch {} } this.child?.kill('SIGKILL'); }
    this.child?.stdin.destroy();
  }
}
const rowBytes = (row, text, codes = '', w = 32) => `\x1b[0m\x1b[${row};1H${codes ? `\x1b[0m${codes}${text}\x1b[0m` : text}${' '.repeat(w - width(text))}\x1b[0m`;
async function fixture() {
  const s = new Session('public-fixture', process.env.CJTUI_COLOR_FIXTURE_BIN ?? 'tests/colors/session/target/release/bin/main', 32, 6);
  let serial = 0;
  try {
    await s.start(); await s.settle(0, 'fixture first complete frame');
    assert(s.raw.toString().includes('\x1b[91mRGB-DYNAMIC'), 'explicit default Basic16 wins over truecolor environment');
    // Every action is followed by a distinct second public onKey event. The file proves the
    // prior render ran. The complete changed fence row proves all its bytes traversed the PTY.
    async function action(key, expected, name) {
      const offset = s.raw.length, update = s.screen.updates.length;
      serial++; s.child.stdin.write(key + 'h');
      await s.wait(() => s.screen.updates.slice(update).some(v => v.row === 4), `${name}: fence row transport barrier`);
      await until(async () => (await read(join(s.dir, `ack-${serial}`))) === 'ack', `${name}: second callback acknowledgement`);
      assert(!s.error, s.error?.message);
      const fence = rowBytes(4, 'EVENT-FENCE', serial % 2 ? '\x1b[1m' : '');
      assert.equal(s.raw.subarray(offset).toString(), expected + fence, name);
      await writeFile(join(s.dir, `action-${serial}-${key}.raw`), s.raw.subarray(offset));
    }
    await action('x', '', '250→249 red projects to same Basic16; no color row update');
    await action('i', '', 'Basic16→Indexed256 same bright-red projection; no unconditional repaint');
    await action('r', rowBytes(3, 'RGB-DYNAMIC', '\x1b[38;2;249;0;0m'), 'TrueColor changes only actual RGB line; plain/named lines silent');
    await action('y', rowBytes(3, 'RGB-DYNAMIC', '\x1b[38;2;250;0;0m'), 'TrueColor channel change updates');
    await action('m', rowBytes(2, 'NAMED-UNCHANGED') + rowBytes(3, 'RGB-DYNAMIC'), 'Monochrome removes colors, preserves plain line');
    await action('x', '', 'Monochrome only color change silent');
    const attrs = '\x1b[1m\x1b[2m\x1b[3m\x1b[4m\x1b[7m\x1b[9m';
    await action('t', rowBytes(3, 'RGB-DYNAMIC', attrs), 'Monochrome attribute change updates all six');
    await action('f', rowBytes(3, 'RGB-DYNAMIC'), 'explicit false resets six attributes with reset0');
    await action('b', rowBytes(2, 'NAMED-UNCHANGED', '\x1b[31m') + rowBytes(3, 'RGB-DYNAMIC', '\x1b[91m'), 'Basic16 restores both effective colors');
    await action('n', rowBytes(3, 'RGB-DYNAMIC', '\x1b[31m'), 'named color changes dynamic row');
    await action('a', '', 'Indexed1 aliases named Red without invalid refresh');
    await action('r', '', 'Basic16→TrueColor indexed basic alias and uncolored/named lines silent');
    await action('d', rowBytes(3, 'RGB-DYNAMIC'), 'explicit Default clears current foreground');
    await action('b', '', 'TrueColor→Basic16 with only default/named colors silent');
    await s.stop(); console.log('PASS colors fixture: 14 handshake-acknowledged actions, exact row bytes, termios restored');
  } finally { await s.save(); }
}
const cells = rows => rows.flatMap(row => row.cells);
const text = rows => rows.map(row => row.text).join('\n');
const selections = rows => cells(rows).flatMap(c => [c.fg, c.bg]);
async function example() {
  const s = new Session('actual-example', process.env.CJTUI_COLOR_EXAMPLE_BIN ?? 'examples/colors/target/release/bin/main', 100, 40);
  try {
    await s.start(); const initial = await s.settle(0, 'actual colors first frame');
    assert(selections(initial).some(c => /^named:9[0-7]$/.test(c)), 'actual example includes bright colors');
    assert(!selections(initial).some(c => /^(indexed|rgb):/.test(c)), 'initial Basic16 regardless of TERM/COLORTERM');
    async function key(k, name) { const before = s.screen.updates.length; s.child.stdin.write(k); return s.settle(before, name); }
    const indexed = await key('c', 'c→Indexed256');
    assert(selections(indexed).some(c => c.startsWith('indexed:')), 'first c exposes indexed colors');
    assert(!selections(indexed).some(c => c.startsWith('rgb:')), 'Indexed256 contains no RGB selection');
    const rgb = await key('c', 'c→TrueColor');
    assert(selections(rgb).some(c => c.startsWith('rgb:')), 'second c exposes truecolor');
    const mono = await key('c', 'c→Monochrome');
    assert(selections(mono).every(c => c === 'default'), 'third c removes all foreground/background selections');
    const styled = await key('t', 't toggles actual example six attributes');
    for (const n of [1, 2, 3, 4, 7, 9]) {
      const count = rows => cells(rows).filter(c => c.text.trim() && c.attributes.includes(n)).reduce((sum, c) => sum + width(c.text), 0);
      assert.notEqual(count(styled), count(mono), `t changes attribute SGR${n} on visible example text`);
    }
    const unstyled = await key('t', 't restores six attributes');
    assert.deepEqual(unstyled, mono, 'second t restores exact monochrome text and style');
    const basic = await key('c', 'c→Basic16 completes cycle');
    assert.deepEqual(basic, initial, 'fourth c restores initial complete screen');
    await s.resize(31, 12); await s.resize(8, 4);
    const restored = await s.resize(100, 40);
    assert.deepEqual(restored, initial, 'resize back restores actual full example with modes unchanged');
    for (const [name, value] of Object.entries({ initial, indexed, rgb, mono, styled, restored })) await writeFile(join(s.dir, `${name}.json`), JSON.stringify(value, null, 2));
    await s.stop(); console.log('PASS actual colors example: Basic16→Indexed256→TrueColor→Monochrome→Basic16, all six t attributes, resize and exact termios');
  } finally { await s.save(); }
}
let failures = 0;
for (const command of ['script', 'stty']) assert.equal(spawnSync(command, ['--version']).status, 0, `${command} available`);
const selected = process.argv.slice(2);
for (const name of selected) assert(['fixture', 'example'].includes(name), `unknown test ${name}`);
for (const [name, run] of [['fixture', fixture], ['example', example]]) if (!selected.length || selected.includes(name)) {
  try { await run(); } catch (error) { failures++; console.error(`FAIL colors ${name}: ${error.stack}`); }
}
console.log(`Color PTY artifacts=${artifacts}; failures=${failures}`);
if (failures) process.exitCode = 1;

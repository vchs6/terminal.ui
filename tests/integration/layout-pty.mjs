#!/usr/bin/env node
// Actual public layout example in a Linux PTY. This is test support, not a backend.
import assert from 'node:assert/strict';
import { spawn, spawnSync } from 'node:child_process';
import { mkdtemp, readFile, writeFile, mkdir } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import { resolve, join } from 'node:path';
import { StringDecoder } from 'node:string_decoder';

const binary = resolve(process.argv[2] ?? 'examples/layout/target/release/bin/main');
const artifacts = resolve(process.env.CJTUI_LAYOUT_PTY_ARTIFACTS ?? await mkdtemp(join(tmpdir(), 'cjtui-layout-pty-')));
await mkdir(artifacts, { recursive: true });
const delay = ms => new Promise(resolve => setTimeout(resolve, ms));
const quote = s => `'${s.replaceAll("'", "'\\''")}'`;
const read = async path => { try { return await readFile(path, 'utf8'); } catch { return ''; } };
async function until(predicate, name, ms = 7000) {
  const end = Date.now() + ms;
  while (Date.now() < end) { if (await predicate()) return; await delay(25); }
  throw new Error(`timeout: ${name}`);
}
// The example stream uses the already supported CUP and SGR subset. Each test row
// update must cover the complete row, making residual-cell checks unambiguous.
const segmenter = new Intl.Segmenter('en', { granularity: 'grapheme' });
function columns(text) {
  let count = 0;
  for (const { segment } of segmenter.segment(text)) {
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
class Screen {
  constructor(width, height) { this.resize(width, height); this.pending = ''; this.decoder = new StringDecoder('utf8'); this.updates = 0; this.row = null; this.text = ''; }
  resize(width, height) { this.width = width; this.height = height; this.rows = Array(height).fill(' '.repeat(width)); }
  flush() {
    if (this.row === null) return;
    assert.equal(columns(this.text), this.width, `complete actual-width row ${this.row + 1}: ${JSON.stringify(this.text)}`);
    this.rows[this.row] = this.text;
    this.row = null; this.text = ''; this.updates++;
  }
  feed(bytes) {
    this.pending += this.decoder.write(bytes);
    while (this.pending.length) {
      if (this.pending[0] === '\x1b') {
        const match = /^\x1b\[([0-9;]*)([A-Za-z])/.exec(this.pending);
        if (!match) { if (/^\x1b(?:\[[0-9;]*)?$/.test(this.pending)) break; throw new Error(`unsupported output: ${JSON.stringify(this.pending.slice(0, 32))}`); }
        this.pending = this.pending.slice(match[0].length);
        if (match[2] === 'm') continue;
        assert.equal(match[2], 'H', 'example emits supported absolute row positioning');
        this.flush();
        const parts = match[1].split(';').map(Number);
        assert.equal(parts.length, 2, 'explicit row and column');
        assert.equal(parts[1], 1, 'existing Linux backend writes complete rows from column one');
        assert(parts[0] >= 1 && parts[0] <= this.height, `actual row bounds ${parts[0]} <= ${this.height}`);
        this.row = parts[0] - 1;
      } else {
        const end = this.pending.indexOf('\x1b');
        const text = end < 0 ? this.pending : this.pending.slice(0, end);
        assert(this.row !== null, 'text follows addressed position');
        assert(!/[\x00-\x1f\x7f-\x9f]/u.test(text), 'no raw output controls/newline scrolling');
        this.text += text;
        this.pending = end < 0 ? '' : this.pending.slice(end);
      }
    }
  }
  settle() { this.flush(); assert.equal(this.pending, '', 'no incomplete ANSI remains after completed repaint'); return this.rows.join('\n'); }
}
const decorated = text => /[╭╮╰╯]/u.test(text) && text.includes('░');
const noDecoration = text => !/[┌┐└┘─│╭╮╰╯╔╗╚╝═║░]/u.test(text);
const dir = await mkdtemp(join(tmpdir(), 'cjtui-layout-session-'));
const wrapper = join(dir, 'session.sh');
await writeFile(wrapper, '#!/bin/sh\nstty rows 14 cols 48\nstty -g > "$2/before"\ntty > "$2/tty"\n"$1" < /dev/tty &\np=$!\necho "$p" > "$2/pid"\nwait "$p"\nstatus=$?\nstty -g > "$2/after"\nexit "$status"\n');
const child = spawn('script', ['--quiet', '--return', '--flush', '--command', `sh ${quote(wrapper)} ${quote(binary)} ${quote(dir)}`, '/dev/null'], { stdio: ['pipe', 'pipe', 'pipe'], env: { ...process.env, TERM: 'xterm-256color' } });
let raw = Buffer.alloc(0), stderr = '', finished = false, exitCode, exitSignal, parseError, pid;
const screen = new Screen(48, 14);
child.stdout.on('data', bytes => { raw = Buffer.concat([raw, bytes]); try { screen.feed(bytes); } catch (error) { parseError ??= error; } });
child.stderr.on('data', bytes => { stderr += bytes.toString(); });
child.on('error', error => { parseError ??= error; finished = true; });
child.on('exit', (code, signal) => { exitCode = code; exitSignal = signal; finished = true; });
async function settled(name, predicate) {
  await until(() => { if (parseError) throw parseError; return predicate(); }, name);
  await delay(250);
  if (parseError) throw parseError;
  return screen.settle();
}
async function save(name, text) { await writeFile(join(artifacts, `${name}.txt`), text); }
async function toggle(name) {
  const before = raw.length;
  child.stdin.write('d');
  return settled(name, () => raw.length > before);
}
async function resize(width, height) {
  const before = raw.length;
  screen.settle(); screen.resize(width, height);
  const tty = (await read(join(dir, 'tty'))).trim();
  const changed = spawnSync('stty', ['-F', tty, 'rows', `${height}`, 'cols', `${width}`], { encoding: 'utf8' });
  assert.equal(changed.status, 0, changed.stderr);
  process.kill(pid, 'SIGWINCH');
  return settled(`resize ${width}x${height}`, () => raw.length > before);
}
try {
  for (const command of ['script', 'stty']) assert.equal(spawnSync(command, ['--version']).status, 0, `${command} available`);
  await until(async () => { pid = Number((await read(join(dir, 'pid'))).trim()); return pid > 0; }, 'actual example PID');
  const initial = await settled('first decorated frame', () => raw.length > 0);
  assert(decorated(initial), 'initial actual example contains rounded corners and exposed shadow');
  await save('01-initial-48x14', initial);
  const idle = raw.length; await delay(250); assert.equal(raw.length, idle, 'idle does not emit screen updates');
  const off = await toggle('decoration disabled');
  assert(noDecoration(off), 'd clears every previous border/shadow cell in actual screen');
  await save('02-disabled-48x14', off);
  const restored = await toggle('decoration restored');
  assert.equal(restored, initial, 'second d restores complete initial screen without stale cells');
  await save('03-restored-48x14', restored);
  await save('04-resize-23x9', await resize(23, 9));
  const tiny = await resize(8, 4);
  await save('05-resize-8x4', tiny);
  const tinyVisible = !noDecoration(tiny);
  const tinyOff = tinyVisible ? await toggle('tiny decoration disabled') : (child.stdin.write('d'), await delay(350), screen.settle());
  assert(noDecoration(tinyOff), 'tiny frame clears decoration too');
  await save('06-disabled-8x4', tinyOff);
  const tinyRestored = tinyVisible ? await toggle('tiny decoration restored') : (child.stdin.write('d'), await delay(350), screen.settle());
  assert.equal(tinyRestored, tiny, 'tiny decoration round trip is deterministic');
  const enlarged = await resize(48, 14);
  assert.equal(enlarged, initial, 'resize back restores complete original geometry');
  await save('07-resize-back-48x14', enlarged);
  child.stdin.write('q');
  await until(() => finished, 'q stops actual example');
  assert.equal(exitCode, 0, 'example exits normally');
  assert.equal(exitSignal, null, 'no forced signal');
  const before = (await read(join(dir, 'before'))).trim(), after = (await read(join(dir, 'after'))).trim();
  assert(before && after, 'actual termios captured before and after');
  assert.equal(after, before, 'application restores exact termios');
  await writeFile(join(artifacts, 'termios.txt'), `before=${before}\nafter=${after}\n`);
  console.log(`PASS layout PTY: exit=0, d clears/restores, 48x14→23x9→8x4→48x14, termios restored; artifacts=${artifacts}`);
} catch (error) {
  console.error(`FAIL layout PTY: ${error.stack}; exit=${exitCode}, signal=${exitSignal}, artifacts=${artifacts}`);
  process.exitCode = 1;
} finally {
  await writeFile(join(artifacts, 'session.raw'), raw);
  await writeFile(join(artifacts, 'stderr.txt'), stderr);
  if (!finished) { if (pid) { try { process.kill(pid, 'SIGKILL'); } catch {} } child.kill('SIGKILL'); }
  child.stdin.destroy();
}

#!/usr/bin/env node
// Linux PTY facility is util-linux script; this never substitutes product behavior.
import { spawn, spawnSync } from 'node:child_process';
import { mkdtemp, readFile, rm, writeFile } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import { resolve, join } from 'node:path';
import assert from 'node:assert/strict';

const binary = resolve(process.argv[2] ?? 'tests/integration/fixture/target/release/bin/main');
const modes = ['q', 'ctrl-c', 'sigint', 'sigterm', 'resize', 'exception', 'osc-ctrl-c', 'utf8-ctrl-c', 'utf8-fragmented', 'sos-ignore'];
const selectedModes = process.argv.slice(3);
const delay = ms => new Promise(r => setTimeout(r, ms));
const quote = s => `'${s.replaceAll("'", "'\\''")}'`;
async function until(predicate, what, ms = 5000) {
  const end = Date.now() + ms;
  while (Date.now() < end) { if (await predicate()) return; await delay(25); }
  throw new Error(`timeout: ${what}`);
}
async function read(path) { try { return await readFile(path, 'utf8'); } catch { return ''; } }
async function session(mode) {
  const collectEvents = mode === 'utf8-fragmented' || mode === 'sos-ignore';
  const dir = await mkdtemp(join(tmpdir(), 'cjtui-pty-'));
  const wrapper = join(dir, 'session.sh');
  await writeFile(wrapper, `#!/bin/sh\nstty rows 5 cols 24\nstty -g > "$2/before"\ntty > "$2/tty"\n"$1" < /dev/tty &\np=$!\necho "$p" > "$2/pid"\nwait "$p"\nstatus=$?\nstty -g > "$2/after"\nexit "$status"\n`);
  const child = spawn('script', ['--quiet', '--return', '--flush', '--command', `sh ${quote(wrapper)} ${quote(binary)} ${quote(dir)}`, '/dev/null'], { stdio: ['pipe', 'pipe', 'pipe'], env: { ...process.env, TERM: 'xterm-256color', CJTUI_TEST_EVENTS: collectEvents ? '1' : '0' } });
  let output = Buffer.alloc(0), stderr = '';
  child.stdout.on('data', b => { output = Buffer.concat([output, b]); });
  child.stderr.on('data', b => { stderr += b.toString(); });
  let finished = false, code, signal;
  child.on('exit', (c, s) => { finished = true; code = c; signal = s; });
  let pid;
  try {
    await until(async () => { pid = Number((await read(join(dir, 'pid'))).trim()); return pid > 0; }, 'application PID');
    await until(() => output.includes(Buffer.from('cjtui')), `first frame (${mode}); stderr=${stderr}`);
    assert(output.includes(Buffer.from('\x1b[')), 'TTY frame must use ANSI');
    // Completed initial frame must settle; no-change frames must not emit updates.
    await delay(150);
    const idleStart = output.length;
    await delay(180);
    assert.equal(output.length, idleStart, 'idle frame sends no screen updates');
    if (mode === 'resize') {
      const offset = output.length;
      const tty = (await read(join(dir, 'tty'))).trim();
      const resized = spawnSync('stty', ['-F', tty, 'rows', '3', 'cols', '8'], { encoding: 'utf8' });
      assert.equal(resized.status, 0, resized.stderr);
      process.kill(pid, 'SIGWINCH');
      await until(() => output.length > offset && output.subarray(offset).includes(Buffer.from('01234567')), 'resize repaint at actual dimensions');
      const repaint = output.subarray(offset).toString();
      assert(!repaint.includes('0123456789'), 'resize must clip to eight actual columns');
      child.stdin.write('q');
    } else if (mode === 'osc-ctrl-c' || mode === 'utf8-ctrl-c') {
      // Leave the input parser inside an unfinished sequence before cancellation.
      // Payload intentionally contains neither fixture action key (q/e).
      const prefix = mode === 'osc-ctrl-c' ? Buffer.from('\x1b]0;xyzxyz') : Buffer.from([0xc2]);
      child.stdin.write(prefix);
      await delay(60);
      assert(!finished, `${mode}: application remains active before Ctrl-C`);
      console.log(`SEND PTY ${mode}: prefix=${prefix.toString('hex')}, then Ctrl-C=03`);
      child.stdin.write(Buffer.from([0x03]));
    } else if (mode === 'utf8-fragmented') {
      const bytes = Buffer.from('中');
      for (let i = 0; i < bytes.length; i++) {
        child.stdin.write(bytes.subarray(i, i + 1));
        if (i + 1 < bytes.length) await delay(160);
      }
      console.log(`SEND PTY ${mode}: ${bytes.toString('hex')}, one byte per write, 160ms apart; then q`);
      await delay(200);
      child.stdin.write('q');
    } else if (mode === 'sos-ignore') {
      const sequence = Buffer.from('\x1bXsecret\x1b\\');
      child.stdin.write(sequence);
      console.log(`SEND PTY ${mode}: ${sequence.toString('hex')}; then q`);
      await delay(200);
      child.stdin.write('q');
    } else if (mode === 'ctrl-c') { child.stdin.write('\x03'); }
    else if (mode === 'sigint') { process.kill(pid, 'SIGINT'); }
    else if (mode === 'sigterm') { process.kill(pid, 'SIGTERM'); }
    else if (mode === 'exception') { child.stdin.write('e'); }
    else { child.stdin.write('q'); }
    await until(() => finished, `clean termination (${mode})`);
    const before = (await read(join(dir, 'before'))).trim();
    const after = (await read(join(dir, 'after'))).trim();
    assert(before && after, 'both termios snapshots recorded');
    assert.equal(after, before, `restore termios (${mode})`);
    assert.equal(signal, null, 'script must exit without forced signal');
    if (mode === 'q' || mode === 'resize') assert.equal(code, 0, 'normal stop succeeds');
    if (mode === 'osc-ctrl-c' || mode === 'utf8-ctrl-c') assert.equal(code, 0, 'Ctrl-C cancellation returns normally despite incomplete input');
    if (collectEvents) {
      assert.equal(code, 0, 'event collection fixture stops normally on q');
      const events = [...output.toString('utf8').matchAll(/CJTUI_TEST_EVENT:([a-z-]+):([^\r\n]*)/g)].map(match => ({ code: match[1], text: match[2] }));
      console.log(`OBSERVED PTY ${mode}: ${JSON.stringify(events)}`);
      const expected = mode === 'utf8-fragmented' ? [{ code: 'text', text: '中' }, { code: 'text', text: 'q' }] : [{ code: 'text', text: 'q' }];
      assert.deepEqual(events, expected, mode === 'utf8-fragmented' ? 'fragmented UTF-8 produces one complete text event without byte fragments or loss' : 'SOS control and payload produce no fabricated key/text events; subsequent q remains usable');
    }
    if (mode === 'exception') assert.notEqual(code, 0, 'callback exception reported to caller');
    console.log(`PASS PTY ${mode}: exit=${code}, termios restored, bytes=${output.length}`);
  } catch (error) {
    console.error(`PTY failure (${mode}): finished=${finished}, exit=${code}, signal=${signal}, before=${(await read(join(dir, 'before'))).trim()}, after=${(await read(join(dir, 'after'))).trim()}, stderr=${stderr}`);
    throw error;
  } finally {
    if (!finished) { if (pid) { try { process.kill(pid, 'SIGKILL'); } catch {} } child.kill('SIGKILL'); }
    child.stdin.destroy();
    await rm(dir, { recursive: true, force: true });
  }
}
async function nonTTY() {
  const child = spawn(binary, [], { stdio: ['pipe', 'pipe', 'pipe'] });
  let bytes = Buffer.alloc(0), done = false, error;
  child.stdout.on('data', b => { bytes = Buffer.concat([bytes, b]); });
  child.stderr.on('data', b => { bytes = Buffer.concat([bytes, b]); });
  child.on('error', e => { error = e; done = true; });
  child.on('exit', () => { done = true; });
  child.stdin.end();
  try {
    await until(() => done, 'non-TTY returns promptly');
    if (error) throw error;
    assert(!bytes.includes(0x1b), 'non-TTY emits no ESC to stdout or stderr');
    console.log('PASS non-TTY: no ESC');
  } finally { if (!done) child.kill('SIGKILL'); }
}
try {
  for (const command of ['script', 'stty']) {
    assert.equal(spawnSync(command, ['--version']).status, 0, `${command} required`);
  }
  await nonTTY();
  for (const mode of selectedModes) assert(modes.includes(mode), `unknown PTY mode: ${mode}`);
  for (const mode of selectedModes.length ? selectedModes : modes) await session(mode);
} catch (e) { console.error(`FAIL integration: ${e.stack}`); process.exitCode = 1; }

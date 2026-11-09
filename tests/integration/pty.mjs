#!/usr/bin/env node
// Linux PTY facility is util-linux script; this never substitutes product behavior.
import { spawn, spawnSync } from 'node:child_process';
import { mkdtemp, readFile, rm, writeFile } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import { resolve, join } from 'node:path';
import assert from 'node:assert/strict';

const binary = resolve(process.argv[2] ?? 'tests/integration/fixture/target/release/bin/main');
const delay = ms => new Promise(r => setTimeout(r, ms));
const quote = s => `'${s.replaceAll("'", "'\\''")}'`;
async function until(predicate, what, ms = 5000) {
  const end = Date.now() + ms;
  while (Date.now() < end) { if (await predicate()) return; await delay(25); }
  throw new Error(`timeout: ${what}`);
}
async function read(path) { try { return await readFile(path, 'utf8'); } catch { return ''; } }
async function session(mode) {
  const dir = await mkdtemp(join(tmpdir(), 'cjtui-pty-'));
  const wrapper = join(dir, 'session.sh');
  await writeFile(wrapper, `#!/bin/sh\nstty rows 5 cols 24\nstty -g > "$2/before"\ntty > "$2/tty"\n"$1" < /dev/tty &\np=$!\necho "$p" > "$2/pid"\nwait "$p"\nstatus=$?\nstty -g > "$2/after"\nexit "$status"\n`);
  const child = spawn('script', ['--quiet', '--return', '--flush', '--command', `sh ${quote(wrapper)} ${quote(binary)} ${quote(dir)}`, '/dev/null'], { stdio: ['pipe', 'pipe', 'pipe'], env: { ...process.env, TERM: 'xterm-256color' } });
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
    if (mode === 'exception') assert.notEqual(code, 0, 'callback exception reported to caller');
    console.log(`PASS PTY ${mode}: exit=${code}, termios restored, bytes=${output.length}`);
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
  for (const mode of ['q', 'ctrl-c', 'sigint', 'sigterm', 'resize', 'exception']) await session(mode);
} catch (e) { console.error(`FAIL integration: ${e.stack}`); process.exitCode = 1; }

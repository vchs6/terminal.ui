#!/usr/bin/env node
import assert from 'node:assert/strict';
import { spawn, spawnSync } from 'node:child_process';
import { mkdir, mkdtemp, readFile, writeFile, open } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import { join, resolve } from 'node:path';

// Prepared subset only. No mock Application or alternate byte decoder.
const binary = resolve(process.argv[2] ?? 'tests/keyboard/device/target/release/bin/main');
const modes = ['paste', 'fairness', 'prevent', 'signal', 'signal-term', 'callback-throws', 'issue-throws'];
const selected = process.argv.slice(3);
for (const mode of selected) assert(modes.includes(mode), `unknown mode ${mode}`);
const root = process.env.CJTUI_KEYBOARD_ARTIFACTS ?? tmpdir();
await mkdir(root, { recursive: true });
const artifacts = await mkdtemp(join(root, 'cjtui-keyboard-pty-'));
const delay = ms => new Promise(resolve => setTimeout(resolve, ms));
const quote = value => `'${value.replaceAll("'", "'\\''")}'`;
const read = async path => { try { return await readFile(path, 'utf8'); } catch { return ''; } };
async function until(predicate, label) {
  const deadline = Date.now() + 15000;
  while (Date.now() < deadline) {
    if (await predicate()) return;
    await delay(10); // Watchdog polling; elapsed time never proves ordering.
  }
  throw new Error(`watchdog: ${label}`);
}

async function session(mode) {
  const directory = join(artifacts, mode);
  await mkdir(directory);
  assert.equal(spawnSync('mkfifo', [join(directory, 'release.fifo')]).status, 0);
  const wrapper = join(directory, 'session.sh');
  await writeFile(wrapper, '#!/bin/sh\nstty rows 5 cols 40\nstty -g > "$2/before"\n"$1" < /dev/tty &\np=$!\necho "$p" > "$2/pid"\nwait "$p"\nstatus=$?\nstty -g > "$2/after"\nexit "$status"\n');
  const child = spawn('script', ['--quiet', '--return', '--flush', '--command',
    `sh ${quote(wrapper)} ${quote(binary)} ${quote(directory)}`, '/dev/null'], {
    stdio: ['pipe', 'pipe', 'pipe'], env: { ...process.env, TERM: 'xterm-256color',
      CJTUI_KEYBOARD_HANDSHAKE: directory, CJTUI_KEYBOARD_MODE: mode }
  });
  let raw = Buffer.alloc(0), stderr = '', finished = false, code, signal, pid, processError;
  child.stdout.on('data', bytes => { raw = Buffer.concat([raw, bytes]); });
  child.stderr.on('data', bytes => { stderr += bytes.toString(); });
  child.on('error', error => { processError = error; finished = true; });
  child.on('close', (value, sig) => { code = value; signal = sig; finished = true; });
  try {
    await until(async () => { pid = Number((await read(join(directory, 'pid'))).trim()); return pid > 0; }, 'actual child pid');
    await until(() => raw.includes(Buffer.from('CJTUI_KEYBOARD_READY')), 'actual first frame');
    assert(raw.includes(Buffer.from('\x1b[')), 'Application.run draws into a real PTY');
    if (mode === 'paste') {
      child.stdin.write('\x1b[200~a\x03\x1b[A\nb\x1b[201~');
      await until(async () => (await read(join(directory, 'paste'))) === '1', 'single atomic paste callback');
      assert.equal(await read(join(directory, 'issue')), '');
      child.stdin.write('q');
    } else if (mode === 'fairness') {
      child.stdin.write('a');
      await until(async () => (await read(join(directory, 'gate-entered'))) === 'first-a', 'first byte callback entered');
      // The first callback is blocked on a FIFO while these bytes reach the PTY.
      await new Promise((resolve, reject) => child.stdin.write('a'.repeat(8192) + 'q', error => error ? reject(error) : resolve()));
      const gate = await open(join(directory, 'release.fifo'), 'w');
      await gate.writeFile('release'); await gate.close();
      await until(async () => (await read(join(directory, 'post'))).length > 0, 'queued post executes');
      const at = Number(await read(join(directory, 'post')));
      assert(at >= 1 && at <= 4096, `queued post progressed at ${at} input events`);
    } else if (mode === 'prevent') {
      child.stdin.write('\x03');
      await until(async () => (await read(join(directory, 'prevent'))) === 'alive', 'normal 03 reaches preventable UI event');
      assert(!finished); child.stdin.write('q');
    } else if (mode === 'signal' || mode === 'signal-term') {
      process.kill(pid, mode === 'signal' ? 'SIGINT' : 'SIGTERM');
    } else if (mode === 'callback-throws') {
      child.stdin.write('e');
    } else if (mode === 'issue-throws') {
      child.stdin.write('\x1b[99~');
    }
    await until(() => finished, 'direct child exits through cleanup');
    if (processError) throw processError;
    assert.equal(signal, null, 'forced termination never counts as cleanup');
    const before = (await read(join(directory, 'before'))).trim();
    assert(before); assert.equal((await read(join(directory, 'after'))).trim(), before, 'exact termios restoration');
    assert.equal(await read(join(directory, 'cleanup')), 'once', 'mount cleanup once');
    const failures = mode.endsWith('-throws');
    if (failures) {
      assert.notEqual(code, 0);
      assert((await read(join(directory, 'error'))).includes(mode === 'issue-throws' ? 'KEYBOARD_ISSUE_SENTINEL' : 'KEYBOARD_CALLBACK_SENTINEL'));
    } else { assert.equal(code, 0); assert.equal(await read(join(directory, 'returned')), 'normal'); }
    if (mode === 'signal' || mode === 'signal-term') {
      assert.equal(await read(join(directory, 'prevent')), '', 'external signal never becomes a preventable UI interrupt');
    }
    const enable = Buffer.from('\x1b[?2004h'), disable = Buffer.from('\x1b[?2004l');
    assert(raw.includes(enable) && raw.includes(disable), 'session enables and restores its requested 2004 mode');
    assert(raw.lastIndexOf(disable) > raw.indexOf(enable), 'cleanup disable follows enable');
    // I015 cursor mode query is not frozen: no private query assumption here.
    await writeFile(join(directory, 'result.json'), JSON.stringify({ mode, code, signal, passed: true, scope: 'root-level-device-subset' }, null, 2));
    console.log(`PASS prepared device subset ${mode}`);
  } catch (error) {
    await writeFile(join(directory, 'result.json'), JSON.stringify({ mode, code, signal, passed: false, error: error.message }, null, 2));
    throw error;
  } finally {
    await writeFile(join(directory, 'session.raw'), raw);
    await writeFile(join(directory, 'stderr.txt'), stderr);
    if (!finished) {
      if (pid) { try { process.kill(pid, 'SIGKILL'); } catch {} }
      child.kill('SIGKILL');
    }
    child.stdin.destroy();
  }
}

let failures = 0;
for (const mode of selected.length ? selected : modes) {
  try { await session(mode); } catch (error) { failures++; console.error(error.stack); }
}
console.log(`keyboard PTY subset artifacts=${artifacts}; failures=${failures}; full target-lock/EOF integration pending`);
if (failures) process.exitCode = 1;

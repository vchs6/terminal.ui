#!/usr/bin/env node
import assert from 'node:assert/strict';
import { spawn, spawnSync } from 'node:child_process';
import { mkdir, mkdtemp, readFile, writeFile } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import { join, resolve } from 'node:path';

const binary = resolve(process.argv[2] ?? 'tests/runtime/session/target/release/bin/main');
const modes = ['idle', 'callback', 'cleanup', 'callback-cleanup', 'callback-cleanup-close', 'mount', 'bind', 'hidden', 'prevent', 'ctrlc'];
const selected = process.argv.slice(3);
const parent = process.env.CJTUI_RUNTIME_ARTIFACTS ?? tmpdir();
await mkdir(parent, { recursive: true });
const artifacts = await mkdtemp(join(parent, 'cjtui-runtime-pty-'));
const delay = ms => new Promise(resolve => setTimeout(resolve, ms));
const quote = text => `'${text.replaceAll("'", "'\\''")}'`;
const read = async path => { try { return await readFile(path, 'utf8'); } catch { return ''; } };
async function until(predicate, name, ms = 7000) {
  const deadline = Date.now() + ms;
  while (Date.now() < deadline) {
    if (await predicate()) return;
    await delay(15);
  }
  throw new Error(`timeout: ${name}`);
}

async function session(mode) {
  const dir = join(artifacts, mode);
  await mkdir(dir, { recursive: true });
  const wrapper = join(dir, 'session.sh');
  await writeFile(wrapper, '#!/bin/sh\nstty rows 5 cols 24\nstty -g > "$2/before"\n"$1" < /dev/tty &\np=$!\necho "$p" > "$2/pid"\nwait "$p"\nstatus=$?\nstty -g > "$2/after"\nexit "$status"\n');
  const failClose = mode.endsWith('-close');
  const child = spawn('script', ['--quiet', '--return', '--flush', '--command',
    `sh ${quote(wrapper)} ${quote(binary)} ${quote(dir)}`, '/dev/null'], {
    stdio: ['pipe', 'pipe', 'pipe'],
    env: { ...process.env, TERM: 'xterm-256color', CJTUI_RUNTIME_MODE: mode,
      CJTUI_RUNTIME_HANDSHAKE: dir, CJTUI_TEST_CLOSE_FAIL: failClose ? '1' : '0',
      CJTUI_TEST_CLOSE_RECORD: join(dir, 'close-record.txt') }
  });
  let output = Buffer.alloc(0), stderr = '', finished = false, code, signal, pid, processError;
  child.stdout.on('data', bytes => { output = Buffer.concat([output, bytes]); });
  child.stderr.on('data', bytes => { stderr += bytes.toString(); });
  child.on('error', error => { processError = error; finished = true; });
  child.on('close', (value, sig) => { code = value; signal = sig; finished = true; });
  try {
    await until(async () => { pid = Number((await read(join(dir, 'pid'))).trim()); return pid > 0; }, `${mode} actual PID`);
    if (mode !== 'mount' && mode !== 'bind') {
      await until(() => output.includes(Buffer.from('CJTUI_RUNTIME_READY')), `${mode} first real frame`);
      assert(output.includes(Buffer.from('\x1b[')), 'real Application draws ANSI into the PTY');
      if (mode === 'idle') {
        child.stdin.write('a');
        await until(async () => (await read(join(dir, 'a'))).length > 0, 'first public stats acknowledgement');
        // A measured idle interval exercises at least three 100ms poll windows.
        // File acknowledgements, rather than this timer, order input processing.
        await delay(360);
        child.stdin.write('b');
        await until(async () => (await read(join(dir, 'b'))).length > 0, 'second public stats acknowledgement');
        const before = (await read(join(dir, 'a'))).split(',').map(Number);
        const after = (await read(join(dir, 'b'))).split(',').map(Number);
        assert.equal(before.length, 4);
        assert(before.every(Number.isFinite));
        assert.deepEqual(after, before, 'idle polls perform no build/measure/paint/frame work');
        child.stdin.write('q');
      } else if (mode === 'hidden') {
        child.stdin.write('h');
        await until(async () => (await read(join(dir, 'h'))).length > 0, 'hide callback acknowledgement');
        child.stdin.write('x');
        await until(async () => (await read(join(dir, 'x'))).length > 0, 'hidden legacy callback acknowledgement');
        const hidden = (await read(join(dir, 'h'))).split(',').map(Number);
        const next = (await read(join(dir, 'x'))).split(',').map(Number);
        assert.equal(hidden.length, 4);
        assert.deepEqual(next.slice(0, 3), hidden.slice(0, 3), 'hidden root creates no capture/bubble/new UI event');
        assert.equal(next[3], hidden[3] + 1, 'hidden root keeps legacy non-interrupt callback');
        child.stdin.write('\x03');
      } else if (mode === 'prevent') {
        child.stdin.write('\x03');
        await until(async () => (await read(join(dir, 'prevent'))).length > 0, 'new handler prevented interrupt');
        assert(!finished, 'preventDefault keeps the actual device session alive');
        const counts = (await read(join(dir, 'prevent'))).split(',').map(Number);
        assert.equal(counts[3], 0, 'legacy callback does not receive interrupt');
        child.stdin.write('q');
      } else if (mode === 'ctrlc') child.stdin.write('\x03');
      else child.stdin.write(mode.startsWith('callback') ? 'e' : 'q');
    }
    await until(() => finished, `${mode} cleanup and exit`);
    if (processError) throw processError;
    assert.equal(signal, null, 'forced termination is never successful cleanup');
    const before = (await read(join(dir, 'before'))).trim();
    const after = (await read(join(dir, 'after'))).trim();
    assert(before && after, 'real before/after termios snapshots exist');
    assert.equal(after, before, 'all runtime failure paths restore exact termios');
    assert.equal(await read(join(dir, 'close-record.txt')), `real_result=0 injected=${failClose ? 1 : 0}\n`,
      'exactly one actual product close succeeds before optional failure injection');
    const errorText = await read(join(dir, 'error'));
    const combined = output.toString('utf8') + stderr + errorText;
    const fails = ['callback', 'cleanup', 'mount', 'bind'].some(part => mode.includes(part));
    if (fails) assert.notEqual(code, 0, 'runtime errors reach direct binary exit');
    else assert.equal(code, 0, 'normal stop succeeds');
    if (mode.startsWith('callback')) assert(combined.includes('CJTUI_CALLBACK_SENTINEL'), 'primary callback failure survives cleanup/restore errors');
    if (mode === 'cleanup') assert(combined.includes('CJTUI_CLEANUP_SENTINEL'), 'cleanup-only primary failure survives close');
    if (mode === 'mount') assert(combined.includes('CJTUI_MOUNT_SENTINEL'), 'mount failure reaches the caller');
    if (mode === 'bind') assert(combined.includes('CJTUI_BIND_SENTINEL'), 'binding failure reaches the caller');
    if (failClose) assert(combined.includes('terminal restore failed'), 'restore failure remains explicit beside primary runtime error');
    else assert(!combined.includes('terminal restore failed'), 'successful close fabricates no restore failure');
    if (mode !== 'mount' && mode !== 'bind') assert.equal(await read(join(dir, 'cleanup')), '1', 'registered cleanup executes exactly once');
    assert(!combined.includes('legacy received interrupt'), 'legacy interrupt compatibility retained');
    await writeFile(join(dir, 'result.json'), JSON.stringify({ mode, code, signal, passed: true }, null, 2));
    console.log(`PASS runtime PTY ${mode}: exit=${code}; exact termios restored`);
  } catch (error) {
    await writeFile(join(dir, 'result.json'), JSON.stringify({ mode, code, signal, passed: false, error: error.message }, null, 2));
    throw error;
  } finally {
    await writeFile(join(dir, 'session.raw'), output);
    await writeFile(join(dir, 'stderr.txt'), stderr);
    if (!finished) {
      if (pid) { try { process.kill(pid, 'SIGKILL'); } catch {} }
      child.kill('SIGKILL');
    }
    child.stdin.destroy();
  }
}

let failures = 0;
try {
  for (const command of ['script', 'stty']) assert.equal(spawnSync(command, ['--version']).status, 0, `${command} available`);
  for (const mode of selected) assert(modes.includes(mode), `unknown mode: ${mode}`);
  for (const mode of selected.length ? selected : modes) {
    try { await session(mode); }
    catch (error) { failures++; console.error(`FAIL runtime PTY ${mode}: ${error.stack}`); }
  }
} catch (error) { failures++; console.error(error.stack); }
console.log(`Runtime PTY artifacts=${artifacts}; failures=${failures}`);
if (failures) process.exitCode = 1;

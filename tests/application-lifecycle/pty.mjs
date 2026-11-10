#!/usr/bin/env node
import assert from 'node:assert/strict';
import { spawn, spawnSync } from 'node:child_process';
import { mkdir, mkdtemp, readFile, writeFile } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import { resolve, join } from 'node:path';

const binary = resolve(process.argv[2] ?? 'tests/application-lifecycle/target/release/bin/main');
const modes = ['q-success', 'q-close-failure', 'callback-success', 'callback-close-failure', 'ctrl-c-success', 'resize-success'];
const selected = process.argv.slice(3);
const artifacts = resolve(process.env.CJTUI_LIFECYCLE_ARTIFACTS ?? await mkdtemp(join(tmpdir(), 'cjtui-lifecycle-')));
await mkdir(artifacts, { recursive: true });
const delay = ms => new Promise(resolve => setTimeout(resolve, ms));
const quote = text => `'${text.replaceAll("'", "'\\''")}'`;
const read = async path => { try { return await readFile(path, 'utf8'); } catch { return ''; } };
async function until(predicate, name, ms = 7000) {
  const deadline = Date.now() + ms;
  while (Date.now() < deadline) { if (await predicate()) return; await delay(25); }
  throw new Error(`timeout: ${name}`);
}
async function session(mode) {
  const dir = join(artifacts, mode); await mkdir(dir, { recursive: true });
  const failClose = mode.endsWith('close-failure');
  const callback = mode.startsWith('callback-');
  const wrapper = join(dir, 'session.sh');
  await writeFile(wrapper, '#!/bin/sh\nstty rows 5 cols 24\nstty -g > "$2/before"\ntty > "$2/tty"\n"$1" < /dev/tty &\np=$!\necho "$p" > "$2/pid"\nwait "$p"\nstatus=$?\nstty -g > "$2/after"\nexit "$status"\n');
  const child = spawn('script', ['--quiet', '--return', '--flush', '--command', `sh ${quote(wrapper)} ${quote(binary)} ${quote(dir)}`, '/dev/null'], {
    stdio: ['pipe', 'pipe', 'pipe'],
    env: { ...process.env, TERM: 'xterm-256color', CJTUI_TEST_CLOSE_FAIL: failClose ? '1' : '0', CJTUI_TEST_CLOSE_RECORD: join(dir, 'close-record.txt') }
  });
  let output = Buffer.alloc(0), stderr = '', finished = false, code, signal, pid, processError;
  child.stdout.on('data', bytes => { output = Buffer.concat([output, bytes]); });
  child.stderr.on('data', bytes => { stderr += bytes.toString(); });
  child.on('error', error => { processError = error; finished = true; });
  child.on('exit', (value, sig) => { code = value; signal = sig; finished = true; });
  try {
    await until(async () => { pid = Number((await read(join(dir, 'pid'))).trim()); return pid > 0; }, `${mode} PID`);
    await until(() => output.includes(Buffer.from('CJTUI_LIFECYCLE_READY')), `${mode} real first frame`);
    assert(output.includes(Buffer.from('\x1b[')), 'application draws into actual TTY');
    await delay(200);
    if (mode === 'resize-success') {
      const offset = output.length;
      const tty = (await read(join(dir, 'tty'))).trim();
      const changed = spawnSync('stty', ['-F', tty, 'rows', '3', 'cols', '8'], { encoding: 'utf8' });
      assert.equal(changed.status, 0, changed.stderr);
      process.kill(pid, 'SIGWINCH');
      await until(() => output.subarray(offset).includes(Buffer.from('01234567')), 'resize before normal cleanup');
      assert(!output.subarray(offset).includes(Buffer.from('0123456789')), 'resize honors actual width');
    }
    child.stdin.write(mode === 'ctrl-c-success' ? '\x03' : callback ? 'e' : 'q');
    await until(() => finished, `${mode} cleanup and exit`);
    if (processError) throw processError;
    assert.equal(signal, null, 'script did not need a forced termination signal');
    const before = (await read(join(dir, 'before'))).trim(), after = (await read(join(dir, 'after'))).trim();
    assert(before && after, 'both actual terminal snapshots exist');
    assert.equal(after, before, 'product real close restores exact termios even when failure is injected afterward');
    const record = await read(join(dir, 'close-record.txt'));
    assert.equal(record, `real_result=0 injected=${failClose ? 1 : 0}\n`, 'Application calls wrapped close exactly once; real restoration succeeds before injection');
    const text = output.toString('utf8') + stderr;
    if (callback || failClose) assert.notEqual(code, 0, 'failure reaches direct application process status');
    else assert.equal(code, 0, 'normal stop/cancellation succeeds');
    if (callback) assert(text.includes('CJTUI_CALLBACK_SENTINEL'), 'original callback exception remains explicitly observable');
    else assert(!text.includes('CJTUI_CALLBACK_SENTINEL'), 'normal stop fabricates no callback error');
    if (failClose) assert(text.includes('terminal restore failed'), 'restore failure remains explicitly observable');
    else assert(!text.includes('terminal restore failed'), 'successful close fabricates no restoration failure');
    console.log(`PASS lifecycle ${mode}: exit=${code}, real close=0, injected=${failClose ? 1 : 0}, exact termios restored`);
    await writeFile(join(dir, 'result.json'), JSON.stringify({ mode, code, signal, passed: true }, null, 2));
  } catch (error) {
    await writeFile(join(dir, 'result.json'), JSON.stringify({ mode, code, signal, passed: false, error: error.message }, null, 2));
    throw error;
  } finally {
    await writeFile(join(dir, 'session.raw'), output);
    await writeFile(join(dir, 'stderr.txt'), stderr);
    if (!finished) { if (pid) { try { process.kill(pid, 'SIGKILL'); } catch {} } child.kill('SIGKILL'); }
    child.stdin.destroy();
  }
}
let failures = 0;
try {
  for (const command of ['script', 'stty']) assert.equal(spawnSync(command, ['--version']).status, 0, `${command} available`);
  for (const mode of selected) assert(modes.includes(mode), `unknown mode: ${mode}`);
  for (const mode of selected.length ? selected : modes) {
    try { await session(mode); }
    catch (error) { failures++; console.error(`FAIL lifecycle ${mode}: ${error.stack}`); }
  }
} catch (error) { failures++; console.error(error.stack); }
console.log(`Lifecycle artifacts=${artifacts}; failures=${failures}`);
if (failures) process.exitCode = 1;

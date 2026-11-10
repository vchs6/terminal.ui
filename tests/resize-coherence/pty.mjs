#!/usr/bin/env node
import assert from 'node:assert/strict';
import { spawn, spawnSync } from 'node:child_process';
import { mkdir, mkdtemp, readFile, writeFile } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import { join, resolve } from 'node:path';
import { atomicResize, completeFrames, finalGrid, prepareTerminalSizeTool } from '../support/terminal_frames.mjs';

const binary = resolve(process.argv[2] ?? 'tests/resize-coherence/target/release/bin/main');
const modes = process.argv.slice(3).length ? process.argv.slice(3) : ['coherence', 'inflight'];
const parent = process.env.CJTUI_RESIZE_ARTIFACTS ?? tmpdir();
await mkdir(parent, { recursive: true });
const artifacts = await mkdtemp(join(parent, 'cjtui-resize-'));
const delay = ms => new Promise(resolve => setTimeout(resolve, ms));
const quote = text => `'${text.replaceAll("'", "'\\''")}'`;
const read = async path => { try { return await readFile(path, 'utf8'); } catch { return ''; } };
async function until(predicate, name) {
  const deadline = Date.now() + 7000;
  while (Date.now() < deadline) { if (await predicate()) return; await delay(10); }
  throw new Error(`timeout: ${name}`);
}
const wanted = ['CJTUI_CO', '01234567', '        '];
const old = ['CJTUI_COHERENCE_READY   ', '0123456789ABCDEFGHIJKLMN', '                        ', '                        ', '                        '];
async function session(mode) {
  const dir = join(artifacts, mode); await mkdir(dir);
  const wrapper = join(dir, 'session.sh');
  await writeFile(wrapper, '#!/bin/sh\nstty rows 5 cols 24\nstty -g > "$2/before"\ntty > "$2/tty"\n"$1" < /dev/tty &\np=$!\necho "$p" > "$2/pid"\nwait "$p"\nstatus=$?\nstty -g > "$2/after"\nexit "$status"\n');
  const child = spawn('script', ['--quiet', '--return', '--flush', '--command',
    `sh ${quote(wrapper)} ${quote(binary)} ${quote(dir)}`, '/dev/null'], {
    stdio: ['pipe', 'pipe', 'pipe'], env: { ...process.env, TERM: 'xterm-256color',
      CJTUI_RESIZE_MODE: mode, CJTUI_RESIZE_HANDSHAKE: dir,
      CJTUI_TEST_CLOSE_FAIL: '0', CJTUI_TEST_CLOSE_RECORD: join(dir, 'close-record.txt') }
  });
  let output = Buffer.alloc(0), stderr = '', finished = false, code, signal, pid;
  child.stdout.on('data', bytes => { output = Buffer.concat([output, bytes]); });
  child.stderr.on('data', bytes => { stderr += bytes.toString(); });
  child.on('close', (value, sig) => { code = value; signal = sig; finished = true; });
  try {
    await until(async () => { pid = Number((await read(join(dir, 'pid'))).trim()); return pid > 0; }, 'actual application PID');
    if (mode === 'coherence') {
      await until(() => finalGrid(output, old), 'complete initial 24x5 grid');
      await writeFile(join(dir, 'arm'), 'arm');
      await until(async () => (await read(join(dir, 'query-held'))).length > 0, 'successful old query held');
      assert.equal(await read(join(dir, 'query-held')), '24 5\n', 'gate holds a real old complete ioctl result');
    } else {
      await until(async () => (await read(join(dir, 'write-held'))).length > 0, 'already prepared old complete frame held before write');
    }
    const tty = (await read(join(dir, 'tty'))).trim();
    const readback = atomicResize(tty, 8, 3);
    await writeFile(join(dir, 'atomic-resize.json'), JSON.stringify({ old: [24, 5], target: [8, 3], successfulSets: 1, readback }));
    process.kill(pid, 'SIGWINCH');
    await writeFile(join(dir, 'release'), 'release');
    await until(() => finalGrid(output, wanted), 'complete final 8x3 grid including blank cells');
    await delay(180);
    assert(finalGrid(output, wanted), 'final grid remains settled across idle polls');
    child.stdin.write('q');
    await until(() => finished, 'normal quit and native close');
    assert.equal(code, 0); assert.equal(signal, null);
    const before = await read(join(dir, 'before')), after = await read(join(dir, 'after'));
    assert(before && after); assert.equal(after, before, 'exact termios restored');
    assert.equal(await read(join(dir, 'close-record.txt')), 'real_result=0 injected=0\n', 'one actual successful product close');
    const frames = completeFrames(output);
    await writeFile(join(dir, 'frames.json'), JSON.stringify(frames, null, 2));
    const queries = (await read(join(dir, 'queries.log'))).trim().split('\n').map(line => line.split(' ').map(Number));
    assert(queries.every(([, cols, rows]) => (cols === 24 && rows === 5) || (cols === 8 && rows === 3)),
      'every real ioctl result is one of the only two kernel pairs');
    const mixed = frames.filter(frame => !((frame.width === 24 && frame.height === 5) || (frame.width === 8 && frame.height === 3)));
    await writeFile(join(dir, 'observations.json'), JSON.stringify({ code, signal, finalSettled: true,
      pairs: frames.map(({ width, height }) => [width, height]), mixed }, null, 2));
    if (mode === 'inflight') assert(frames.some(frame => frame.width === 24 && frame.height === 5),
      'legal old coherent frame delivered after atomic resize is retained and accepted');
    assert.deepEqual(mixed, [], 'actual Application must never generate a pair absent from all real terminal states');
    console.log(`PASS resize ${mode}: pairs=${JSON.stringify(frames.map(({width,height}) => [width,height]))}; final settled; native restored`);
    await writeFile(join(dir, 'result.json'), JSON.stringify({ mode, code, passed: true }));
  } catch (error) {
    await writeFile(join(dir, 'result.json'), JSON.stringify({ mode, code, signal, passed: false, error: error.message }));
    throw error;
  } finally {
    await writeFile(join(dir, 'session.raw'), output); await writeFile(join(dir, 'stderr.txt'), stderr);
    if (!finished) { if (pid) { try { process.kill(pid, 'SIGKILL'); } catch {} } child.kill('SIGKILL'); }
    child.stdin.destroy();
  }
}
let failures = 0;
try {
  prepareTerminalSizeTool();
  for (const name of ['script', 'stty']) assert.equal(spawnSync(name, ['--version']).status, 0);
  for (const mode of modes) { assert(['coherence', 'inflight'].includes(mode));
    try { await session(mode); } catch (error) { failures++; console.error(`FAIL resize ${mode}: ${error.stack}`); }
  }
} catch (error) { failures++; console.error(error.stack); }
console.log(`Resize artifacts=${artifacts}; failures=${failures}`);
if (failures) process.exitCode = 1;

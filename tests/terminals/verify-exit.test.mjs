import assert from 'node:assert/strict';
import { execFile } from 'node:child_process';
import { mkdtemp, writeFile, rm } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { fileURLToPath } from 'node:url';
import { promisify } from 'node:util';
import test from 'node:test';
const exec = promisify(execFile);
const oracle = process.env.CJTUI_EXIT_ORACLE ?? fileURLToPath(new URL('verify-exit.mjs', import.meta.url));
async function verify(inner, outer, host, expected) {
  const directory = await mkdtemp(join(tmpdir(), 'cjtui-exit-'));
  const files = ['inner.txt', 'outer.txt', 'host-wait-status.txt'].map(name => join(directory, name));
  try {
    await Promise.all([writeFile(files[0], inner), writeFile(files[1], outer), writeFile(files[2], host + '\n')]);
    return await exec(process.execPath, [oracle, ...files, expected]);
  } finally { await rm(directory, { recursive: true }); }
}
const record = status => `ready_size=28 100\nexit_status=${status}\n`;
async function rejected(inner, outer, host, expected) {
  await assert.rejects(verify(inner, outer, host, expected), error => error.code === 1);
}
test('accepts recorded application exception when terminal host exits zero', async () => {
  const { stdout } = await verify(record(7), record(7), '0', 'nonzero');
  assert.equal(JSON.parse(stdout).applicationExitStatus, 7);
  assert.equal(JSON.parse(stdout).hostWaitStatus, 0);
});
test('rejects successful application as exception even when terminal host fails', async () => {
  await rejected(record(0), record(0), '7', 'nonzero');
});
test('accepts successful application independently of nonzero terminal host evidence', async () => {
  const { stdout } = await verify(record(0), record(0), '7', '0');
  assert.equal(JSON.parse(stdout).applicationExitStatus, 0);
  assert.equal(JSON.parse(stdout).hostWaitStatus, 7);
});
test('rejects application failure for normal q interrupt or ordinary example expectation', async () => {
  await rejected(record(7), record(7), '0', '0');
});
test('rejects inconsistent inner and outer application statuses', async () => {
  await rejected(record(7), record(0), '7', 'nonzero');
  await rejected(record(0), record(7), '0', '0');
});
test('rejects missing duplicate malformed and out-of-range recorder statuses', async () => {
  for (const bad of ['', 'exit_status=1\nexit_status=1\n', record('oops'), record(-1), record(256)]) {
    await rejected(bad, record(1), '1', 'nonzero');
    await rejected(record(1), bad, '1', 'nonzero');
  }
});
test('requires legal host wait evidence and explicit expected outcome', async () => {
  await rejected(record(0), record(0), 'oops', '0');
  await rejected(record(0), record(0), '256', '0');
  await rejected(record(0), record(0), '0', 'anything');
});

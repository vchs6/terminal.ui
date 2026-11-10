import assert from 'node:assert/strict';
import { execFile } from 'node:child_process';
import { mkdtemp, writeFile, appendFile, rm } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { fileURLToPath } from 'node:url';
import { promisify } from 'node:util';
import test from 'node:test';
const exec = promisify(execFile);
const observer = fileURLToPath(new URL('wait-fence.mjs', import.meta.url));
const on = '\x1b[0m\x1b[3;1H\x1b[0m\x1b[1mEVENT-FENCE\x1b[0m' + ' '.repeat(9) + '\x1b[0m';
const off = '\x1b[0m\x1b[3;1HEVENT-FENCE' + ' '.repeat(9) + '\x1b[0m';
async function withRaw(raw, run) {
  const directory = await mkdtemp(join(tmpdir(), 'cjtui-fence-'));
  const path = join(directory, 'raw');
  try { await writeFile(path, raw); await run(path); } finally { await rm(directory, { recursive: true }); }
}
test('accepts complete fence after prior business output and records its exact interval', async () => {
  await withRaw('prior' + on, async path => {
    const { stdout } = await exec(process.execPath, [observer, path, '0', 'true', '20', 'updates', '1000']);
    const result = JSON.parse(stdout);
    assert.equal(result.fenceStart, 5);
    assert.equal(result.fenceEnd, 5 + Buffer.byteLength(on));
  });
});
test('quiet interval accepts only intentional fence bytes', async () => {
  await withRaw(off, async path => { await exec(process.execPath, [observer, path, '0', 'false', '20', 'quiet', '1000']); });
  await withRaw('UNEXPECTED' + off, async path => {
    await assert.rejects(exec(process.execPath, [observer, path, '0', 'false', '20', 'quiet', '1000']), error => {
      assert.equal(error.code, 1); assert.match(error.stderr, /no-op emitted bytes before transport fence/); return true;
    });
  });
});
for (const [name, raw] of [['ack without device bytes', 'ack'], ['partial fence row', on.slice(0, -4)], ['old unchanged fence style', off]]) {
  test(`rejects ${name}`, async () => {
    await withRaw(raw, async path => {
      await assert.rejects(exec(process.execPath, [observer, path, '0', 'true', '20', 'updates', '180']), error => {
        assert.equal(error.code, 1); assert.match(error.stderr, /timeout: recorded complete fence row/); return true;
      });
    });
  });
}
test('waits for recorder to deliver full final reset', async () => {
  await withRaw(on.slice(0, -4), async path => {
    const observed = exec(process.execPath, [observer, path, '0', 'true', '20', 'updates', '1000']);
    await new Promise(resolve => setTimeout(resolve, 80)); await appendFile(path, '\x1b[0m');
    assert.equal(JSON.parse((await observed).stdout).fenceEnd, Buffer.byteLength(on));
  });
});

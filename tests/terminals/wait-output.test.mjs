import assert from 'node:assert/strict';
import { execFile } from 'node:child_process';
import { mkdtemp, writeFile, appendFile, rm } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { fileURLToPath } from 'node:url';
import { promisify } from 'node:util';
import test from 'node:test';
const exec = promisify(execFile);
const observer = fileURLToPath(new URL('wait-output.mjs', import.meta.url));
const row = '\x1b[0m\x1b[1;1HEXAMPLE   \x1b[0m';
async function withRaw(content, run) {
  const directory = await mkdtemp(join(tmpdir(), 'cjtui-wait-output-'));
  const path = join(directory, 'actual.raw');
  try { await writeFile(path, content); await run(path); }
  finally { await rm(directory, { recursive: true }); }
}
test('accepts new complete CUP row and reports exact byte range', async () => {
  await withRaw('header\n' + row, async path => {
    const { stdout } = await exec(process.execPath, [observer, path, '7', '1000']);
    const evidence = JSON.parse(stdout);
    assert.equal(evidence.startOffset, 7);
    assert.equal(evidence.endOffset, 7 + Buffer.byteLength(row));
    assert.equal(evidence.byteCount, Buffer.byteLength(row));
    assert.equal(evidence.completeRows, 1);
    assert.match(evidence.sha256, /^[a-f0-9]{64}$/);
  });
});
for (const [name, raw, offset] of [
  ['incomplete row', row.slice(0, -4), 0],
  ['no byte growth', row, Buffer.byteLength(row)],
  ['non-CUP noise', 'shell text\x1b[0m', 0],
]) test(`fails on ${name}`, async () => {
  await withRaw(raw, async path => {
    await assert.rejects(exec(process.execPath, [observer, path, String(offset), '180']), error => {
      assert.equal(error.code, 1);
      assert.match(error.stderr, /timeout: positive complete terminal output/);
      return true;
    });
  });
});
test('waits for delayed final reset before accepting output', async () => {
  await withRaw(row.slice(0, -4), async path => {
    const observed = exec(process.execPath, [observer, path, '0', '1000']);
    await new Promise(resolve => setTimeout(resolve, 80));
    await appendFile(path, '\x1b[0m');
    const { stdout } = await observed;
    assert.equal(JSON.parse(stdout).endOffset, Buffer.byteLength(row));
  });
});

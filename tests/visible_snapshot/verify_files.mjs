import assert from 'node:assert/strict';
import {readFile, stat, access} from 'node:fs/promises';
import {join} from 'node:path';
import {consumeAnsi, manualGrid} from './ansi_oracle.mjs';
import {fixtures} from './manual_fixtures.mjs';

const output = process.argv[2];
assert.ok(output, 'usage: node verify_files.mjs ARTIFACT_DIRECTORY');
for (const [name, fixture] of fixtures) {
  const plain = await readFile(join(output, `${name}.txt`));
  assert.deepEqual(plain, Buffer.from(fixture.rows.join('\n'), 'utf8'), `${name}: manual full UTF-8 plain golden`);
  assert.equal(plain.includes(0x1b), false, `${name}: no ESC`);
  const expected = manualGrid(fixture.rows, fixture.styles);
  const ansi = (await readFile(join(output, `${name}.ansi`))).toString('utf8');
  assert.deepEqual(consumeAnsi(ansi, fixture.width, fixture.rows.length), expected,
    `${name}: independent ANSI empty-screen consumption equals manual complete cells/styles`);
  const mono = (await readFile(join(output, `${name}.mono.ansi`))).toString('utf8');
  const monochrome = expected.map(row => row.map(cell => ({...cell, style: {...cell.style, fg: 'default', bg: 'default'}})));
  assert.deepEqual(consumeAnsi(mono, fixture.width, fixture.rows.length), monochrome, `${name}: offline monochrome keeps attributes and Unicode`);
}
for (const name of ['glyph', 'viewport', 'layers', 'decorated']) {
  const initial = ({glyph: 'default', viewport: 'right-clip', layers: 'holes', decorated: 'initial'})[name];
  for (const suffix of ['txt', 'ansi', 'mono.ansi']) {
    assert.deepEqual(await readFile(join(output, `${name}-old.${suffix}`)),
      await readFile(join(output, `${name}-${initial}.${suffix}`)), `${name}: old Frame bytes remain stable`);
  }
}
for (const name of ['short.txt', 'short.ansi']) assert.equal((await stat(join(output, name))).size, 32,
  `${name}: actual regular file accepted positive prefix before writer threw`);
for (const name of ['nul', 'nul\0suffix', 'missing-parent']) {
  if (name.includes('\0')) continue; // The forbidden path itself is not a legal fs query.
  await assert.rejects(access(join(output, name)), {code: 'ENOENT'}, `${name}: no truncated-path side effect`);
}
for (const name of ['consumer.log', 'short-write.log']) {
  assert.equal((await readFile(join(output, name))).includes(0x1b), false, `${name}: headless consumer emits no device controls`);
}
console.log(`PASS C003 independent actual file checks: ${fixtures.size} manual snapshots plus real error/short-write artifacts`);

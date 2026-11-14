import assert from 'node:assert/strict';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import { createHash } from 'node:crypto';
import { gunzipSync } from 'node:zlib';
import { spawnSync } from 'node:child_process';
import { test } from 'node:test';

// Expectations are declared here, independently of operator code and real review data.
const originals = [
  { path: 'docs/reviews/R11/README.md', mode: 0o644, keep: true, bytes: Buffer.from('# Literal round\n[Directory](./linked-empty/)\n[Image](./screen shot.png)\n') },
  { path: 'docs/reviews/R11/screen shot.png', mode: 0o644, keep: true, bytes: Buffer.from([137,80,78,71,13,10,26,10,0,255]) },
  { path: 'docs/reviews/R11/tool.sh', mode: 0o755, keep: true, bytes: Buffer.from('#!/bin/sh\nprintf literal\\n\n') },
  { path: 'docs/reviews/R11/raw/审查 evidence.bin', mode: 0o644, keep: false, bytes: Buffer.from([0,255,128,10,65,0]) },
  { path: 'docs/reviews/R11/raw/zero bytes.dat', mode: 0o600, keep: false, bytes: Buffer.alloc(0) },
  { path: 'docs/reviews/R11/raw/already.tar.gz', mode: 0o644, keep: false, bytes: Buffer.from([31,139,8,0,255,0,10,42]) },
  { path: 'docs/reviews/R11/linked-empty/only evidence.txt', mode: 0o644, keep: false, bytes: Buffer.from('directory survives without this original\n') },
];
const linkedDirectory = 'docs/reviews/R11/linked-empty';
// A retained tracked descendant is the approved durable-directory strategy.
// Keep the supplied declaration unchanged so the operator must derive this addition.
const effectiveKeep = file => file.keep || file.path === linkedDirectory + '/only evidence.txt';
const selfCheck = process.argv[2] === '--self-check';
const operator = selfCheck ? null : process.argv[2] && path.resolve(process.argv[2]);
if (!selfCheck && !operator) throw new Error('Usage: node operator-contract-v2.mjs /absolute/path/review-archive-pack.mjs | --self-check');
const sha = bytes => createHash('sha256').update(bytes).digest('hex');

function write(file, bytes, mode = 0o644) {
  fs.mkdirSync(path.dirname(file), { recursive: true });
  fs.writeFileSync(file, bytes); fs.chmodSync(file, mode);
}
function command(program, args, options = {}) {
  const result = spawnSync(program, args, { encoding: 'utf8', timeout: 20000, maxBuffer: 1024 * 1024, ...options });
  assert.ifError(result.error); return result;
}
function git(root, ...args) {
  const result = command('git', ['-C', root, '-c', 'user.name=Literal Fixture', '-c', 'user.email=fixture@example.invalid', ...args]);
  assert.equal(result.status, 0, `fixture Git ${args.join(' ')}: ${result.stderr}`); return result.stdout;
}
function fileState(root, names = originals.map(f => f.path)) {
  return names.map(name => {
    const file = path.join(root, name);
    if (!fs.existsSync(file)) return [name, 'absent'];
    const stat = fs.lstatSync(file);
    return stat.isSymbolicLink() ? [name, 'symlink', fs.readlinkSync(file)]
      : [name, stat.mode & 0o777, stat.size, sha(fs.readFileSync(file))];
  });
}
function fixture() {
  const home = fs.mkdtempSync(path.join(os.tmpdir(), 'archive-operator-contract-'));
  const root = path.join(home, 'literal repository'); fs.mkdirSync(root);
  const keepPath = path.join(home, 'KEEP manifest.json');
  const keep = { version: 1, keep: originals.filter(f => f.keep).map(f => f.path), keepDirectories: [linkedDirectory] };
  for (const file of originals) write(path.join(root, file.path), file.bytes, file.mode);
  write(path.join(root, 'docs/reviews/README.md'), '# Retained root index\n');
  write(path.join(root, 'src/product.txt'), 'outside review scope\n');
  write(keepPath, JSON.stringify(keep) + '\n');
  git(root, 'init', '--quiet', '--initial-branch=main'); git(root, 'add', '--all'); git(root, 'commit', '--quiet', '-m', 'Literal originals');
  const baseline = fileState(root);
  assert.ok(originals.reduce((n, f) => n + f.bytes.length, 0) < 1024 * 1024);
  return { home, root, keepPath, keep, baseline,
    saveKeep() { write(keepPath, JSON.stringify(keep) + '\n'); },
    cleanup() { fs.rmSync(home, { recursive: true, force: true }); } };
}
function isolated(name, fn) {
  test(name, () => { const f = fixture(); try { fn(f); } finally { f.cleanup(); } });
}
function invoke(f, action, success = true) {
  const result = command(process.execPath, [operator, '--root', f.root, '--group', 'R11', '--keep', f.keepPath, action], { cwd: f.home });
  if (success) assert.equal(result.status, 0, `${action}: ${result.stderr}\n${result.stdout}`);
  else {
    assert.notEqual(result.status, 0, `${action} accepted an unsafe state: ${result.stdout}`);
    assert.ok((result.stderr + result.stdout).trim(), 'rejection needs a diagnostic');
  }
  return result;
}
function fullArchive(f) {
  const catalog = JSON.parse(fs.readFileSync(path.join(f.root, 'docs/reviews/archive-v1/catalog.json'), 'utf8'));
  assert.equal(catalog.version, 1); const group = catalog.groups.R11; assert.ok(group);
  const compressed = fs.readFileSync(path.join(f.root, group.manifest.path));
  assert.equal(sha(compressed), group.manifest.sha256);
  const records = gunzipSync(compressed).toString('utf8').trim().split('\n').map(line => JSON.parse(line));
  const recordNames = records.map(r => r.path);
  assert.equal(new Set(recordNames).size, recordNames.length, 'one record per original');
  for (const shard of group.shards) {
    const shardPath = path.join(f.root, shard.path); assert.equal(sha(fs.readFileSync(shardPath)), shard.sha256);
    const list = command('tar', ['-tzf', shardPath]); assert.equal(list.status, 0, list.stderr);
    const names = list.stdout.trim().split('\n').filter(Boolean);
    assert.equal(new Set(names).size, names.length, 'duplicate tar members');
    for (const name of names) {
      assert.ok(name.startsWith('docs/reviews/R11/') && !name.split('/').includes('..'), `unsafe member ${name}`);
      assert.ok(records.some(r => r.member === name && r.shard === shard.path), `unlisted member ${name}`);
    }
  }
  for (const expected of originals) {
    const record = records.find(r => r.path === expected.path); assert.ok(record, `missing original ${expected.path}`);
    assert.equal(record.type, 'file'); assert.equal(record.member, expected.path); assert.equal(record.inline, effectiveKeep(expected));
    assert.equal(record.mode, expected.mode); assert.equal(record.size, expected.bytes.length); assert.equal(record.sha256, sha(expected.bytes));
    const shard = path.join(f.root, record.shard);
    const output = command('tar', ['-xOf', shard, '--', record.member], { encoding: null });
    assert.equal(output.status, 0, String(output.stderr)); assert.deepEqual(output.stdout, expected.bytes);
    const mode = command('tar', ['-tvf', shard, '--', record.member]); assert.equal(mode.status, 0, mode.stderr);
    assert.equal(mode.stdout.slice(0, 10), { 420: '-rw-r--r--', 493: '-rwxr-xr-x', 384: '-rw-------' }[expected.mode]);
  }
  return { catalog, records, group };
}
function originalsUnchanged(f, expected = f.baseline) { assert.deepEqual(fileState(f.root), expected, 'an original was deleted, changed, or chmodded'); }
function removedCorrectly(f) {
  for (const expected of originals) {
    const filename = path.join(f.root, expected.path);
    if (effectiveKeep(expected)) {
      assert.deepEqual(fs.readFileSync(filename), expected.bytes); assert.equal(fs.statSync(filename).mode & 0o777, expected.mode);
    } else assert.ok(!fs.existsSync(filename), `archive-only original remains ${expected.path}`);
  }
  assert.equal(fs.readFileSync(path.join(f.root, 'src/product.txt'), 'utf8'), 'outside review scope\n');
  assert.equal(fs.readFileSync(path.join(f.root, 'docs/reviews/README.md'), 'utf8'), '# Retained root index\n');
}

isolated('fixture contains committed independent literal bytes with archived Unicode, spaces, and mode boundaries', f => {
  originalsUnchanged(f); assert.equal(git(f.root, 'status', '--porcelain'), '');
  assert.equal(git(f.root, 'ls-files', 'docs/reviews/R11').trim().split('\n').length, originals.length);
});

if (!selfCheck) {
  isolated('pack preserves every original and archives all retained and archive-only bytes and modes', f => {
    const head = git(f.root, 'rev-parse', 'HEAD'); invoke(f, 'pack'); originalsUnchanged(f); fullArchive(f);
    assert.equal(git(f.root, 'rev-parse', 'HEAD'), head, 'operator changed Git history');
  });
  isolated('remove retains the effective keep set and replay safely verifies every archived original', f => {
    invoke(f, 'pack'); invoke(f, 'remove'); removedCorrectly(f); fullArchive(f);
    const after = fileState(f.root); invoke(f, 'remove'); assert.deepEqual(fileState(f.root), after); fullArchive(f);
  });
  for (const target of [originals[3], originals[0]]) {
    isolated(`changed ${target.keep ? 'retained' : 'archive-only'} original blocks every deletion`, f => {
      invoke(f, 'pack'); write(path.join(f.root, target.path), 'tampered original\n', target.mode);
      const before = fileState(f.root); invoke(f, 'remove', false); originalsUnchanged(f, before);
    });
  }
  isolated('changed archive blocks every deletion', f => {
    invoke(f, 'pack'); const { group } = fullArchive(f);
    fs.appendFileSync(path.join(f.root, group.shards[0].path), 'tampered shard');
    invoke(f, 'remove', false); originalsUnchanged(f);
  });
  isolated('changed keep declaration blocks every deletion', f => {
    invoke(f, 'pack'); f.keep.keep.push(originals[3].path); f.saveKeep();
    invoke(f, 'remove', false); originalsUnchanged(f);
  });
  isolated('untracked overlapping input refuses packing and preserves all original and unknown bytes', f => {
    const relative = 'docs/reviews/R11/raw/untracked 审查 note.txt', literal = 'user untracked work\n';
    write(path.join(f.root, relative), literal);
    const keepBefore = fs.readFileSync(f.keepPath);
    invoke(f, 'pack', false); originalsUnchanged(f);
    assert.equal(fs.readFileSync(path.join(f.root, relative), 'utf8'), literal);
    assert.deepEqual(fs.readFileSync(f.keepPath), keepBefore);
    assert.deepEqual(fs.readdirSync(f.home).sort(), ['KEEP manifest.json', 'literal repository']);
  });
  isolated('tracked symlink input is rejected without deleting originals or changing its external target', f => {
    const outside = path.join(f.home, 'external bytes'); write(outside, 'external untouched\n');
    const relative = 'docs/reviews/R11/raw/tracked-link'; fs.symlinkSync(outside, path.join(f.root, relative));
    git(f.root, 'add', relative); git(f.root, 'commit', '--quiet', '-m', 'Unsafe fixture input');
    invoke(f, 'pack', false); originalsUnchanged(f);
    assert.ok(fs.lstatSync(path.join(f.root, relative)).isSymbolicLink()); assert.equal(fs.readFileSync(outside, 'utf8'), 'external untouched\n');
  });
  isolated('symlink catalog parent is rejected before any outside write', f => {
    const outside = path.join(f.home, 'outside catalog'); fs.mkdirSync(outside); write(path.join(outside, 'sentinel'), 'unchanged\n');
    fs.symlinkSync(outside, path.join(f.root, 'docs/reviews/archive-v1'));
    invoke(f, 'pack', false); originalsUnchanged(f);
    assert.deepEqual(fs.readdirSync(outside), ['sentinel']); assert.equal(fs.readFileSync(path.join(outside, 'sentinel'), 'utf8'), 'unchanged\n');
  });
  isolated('linked directory remains present after staging, commit, and a fresh clone', f => {
    invoke(f, 'pack'); invoke(f, 'remove'); removedCorrectly(f);
    assert.ok(fs.statSync(path.join(f.root, linkedDirectory)).isDirectory());
    git(f.root, 'add', '--all'); git(f.root, 'commit', '--quiet', '-m', 'Archive fixture evidence');
    const clone = path.join(f.home, 'fresh clone'); git(f.root, 'clone', '--quiet', '--no-hardlinks', f.root, clone);
    assert.ok(fs.existsSync(path.join(clone, linkedDirectory)), 'linked directory was lost during Git checkout');
    assert.ok(fs.statSync(path.join(clone, linkedDirectory)).isDirectory());
    for (const expected of originals.filter(effectiveKeep)) assert.deepEqual(fs.readFileSync(path.join(clone, expected.path)), expected.bytes);
  });
  isolated('completed archive whose catalog publication was interrupted can publish catalog on restart', f => {
    invoke(f, 'pack'); const first = fullArchive(f);
    const hashes = first.group.shards.map(s => [s.path, s.sha256]);
    fs.unlinkSync(path.join(f.root, 'docs/reviews/archive-v1/catalog.json'));
    invoke(f, 'pack'); originalsUnchanged(f);
    assert.deepEqual(fullArchive(f).group.shards.map(s => [s.path, s.sha256]), hashes);
    invoke(f, 'remove'); removedCorrectly(f); fullArchive(f);
  });
  isolated('interrupted incomplete archive never permits deletion or changes pending originals', f => {
    write(path.join(f.root, 'docs/reviews/R11/.archive-v1/part-000001.tar.gz'), 'incomplete archive bytes\n');
    invoke(f, 'remove', false); originalsUnchanged(f);
    const restart = command(process.execPath, [operator, '--root', f.root, '--group', 'R11', '--keep', f.keepPath, 'pack'], { cwd: f.home });
    originalsUnchanged(f);
    if (restart.status === 0) fullArchive(f);
    else assert.ok((restart.stderr + restart.stdout).trim(), 'safe refusal must explain incomplete archive');
  });
}

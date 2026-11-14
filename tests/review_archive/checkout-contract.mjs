import assert from 'node:assert/strict';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import { createHash } from 'node:crypto';
import { gzipSync, gunzipSync } from 'node:zlib';
import { spawnSync } from 'node:child_process';
import { test } from 'node:test';

// Full archival modes differ deliberately from Git checkout modes.
const originals = [
  { path: 'docs/reviews/R11/private evidence.txt', bytes: Buffer.from('literal private evidence\n'), mode: 0o600, checkoutMode: 0o644, inline: true },
  { path: 'docs/reviews/R11/private tool.sh', bytes: Buffer.from('#!/bin/sh\nprintf literal\\n\n'), mode: 0o700, checkoutMode: 0o755, inline: true },
  { path: 'docs/reviews/R11/raw/archive-only.dat', bytes: Buffer.from([0,255,128,10,65]), mode: 0o600, inline: false },
];
const selfCheck = process.argv[2] === '--self-check';
const cli = selfCheck ? null : process.argv[2] && path.resolve(process.argv[2]);
const operator = selfCheck ? null : process.argv[3] && path.resolve(process.argv[3]);
if (!selfCheck && (!cli || !operator)) throw Error('Usage: node checkout-contract.mjs CLI.mjs OPERATOR.mjs | --self-check');
const hash = bytes => createHash('sha256').update(bytes).digest('hex');
function write(file, bytes, mode = 0o644) {
  fs.mkdirSync(path.dirname(file), { recursive: true }); fs.writeFileSync(file, bytes); fs.chmodSync(file, mode);
}
function run(program, args, options = {}) {
  const result = spawnSync(program, args, { encoding: 'utf8', timeout: 20000, maxBuffer: 1024 * 1024, ...options });
  assert.ifError(result.error); return result;
}
function success(result) { assert.equal(result.status, 0, `${result.stderr}\n${result.stdout}`); return result; }
function failure(result) {
  assert.notEqual(result.status, 0, `unsafe state accepted: ${result.stdout}`);
  assert.ok((result.stderr + result.stdout).trim(), 'rejection needs a diagnostic'); return result;
}
function git(root, ...args) {
  return success(run('git', ['-C', root, '-c', 'user.name=Literal Checkout Fixture', '-c', 'user.email=fixture@example.invalid', ...args])).stdout;
}
function fixture() {
  const home = fs.mkdtempSync(path.join(os.tmpdir(), 'archive-checkout-contract-'));
  const root = path.join(home, 'original repository'); fs.mkdirSync(root);
  for (const expected of originals) write(path.join(root, expected.path), expected.bytes, expected.mode);
  const keepPath = path.join(home, 'KEEP.json');
  write(keepPath, JSON.stringify({ version: 1, keep: originals.filter(f => f.inline).map(f => f.path), keepDirectories: [] }) + '\n');
  git(root, 'init', '--quiet', '--initial-branch=main'); git(root, 'config', 'core.filemode', 'true');
  git(root, 'add', '--all'); git(root, 'commit', '--quiet', '-m', 'Literal 0600 and 0700 originals');
  return { home, root, keepPath, cleanup: () => fs.rmSync(home, { recursive: true, force: true }) };
}
function operate(f, root, action) {
  return run(process.execPath, [operator, '--root', root, '--group', 'R11', '--keep', f.keepPath, action], { cwd: f.home });
}
function archiveCli(f, root, ...args) {
  return run(process.execPath, [cli, '--root', root, ...args], { cwd: f.home });
}
function migratedClone(f) {
  success(operate(f, f.root, 'pack'));
  for (const expected of originals) assert.equal(fs.statSync(path.join(f.root, expected.path)).mode & 0o777, expected.mode);
  success(operate(f, f.root, 'remove'));
  git(f.root, 'add', '--all'); git(f.root, 'commit', '--quiet', '-m', 'Migrate literal archives');
  const clone = path.join(f.home, 'fresh clone');
  // A child process fixes the clone umask without changing the test runner's state.
  const code = "process.umask(0o022); const r=require('node:child_process').spawnSync('git',process.argv.slice(1),{stdio:'inherit'}); if(r.error)throw r.error; process.exit(r.status??1);";
  success(run(process.execPath, ['-e', code, 'clone', '--quiet', '--no-hardlinks', f.root, clone]));
  for (const expected of originals.filter(f => f.inline)) {
    assert.equal(fs.statSync(path.join(clone, expected.path)).mode & 0o777, expected.checkoutMode);
    assert.deepEqual(fs.readFileSync(path.join(clone, expected.path)), expected.bytes);
  }
  assert.ok(!fs.existsSync(path.join(clone, originals[2].path)));
  return clone;
}
function inlineState(root) {
  return originals.filter(f => f.inline).map(f => {
    const file = path.join(root, f.path), stat = fs.lstatSync(file);
    return [f.path, stat.isFile(), stat.mode & 0o777, stat.size, hash(fs.readFileSync(file))];
  });
}
function isolated(name, fn) {
  test(name, () => { const f = fixture(); try { fn(f); } finally { f.cleanup(); } });
}
function tamperHeaderAndUpdateOuterHash(root) {
  const catalogPath = path.join(root, 'docs/reviews/archive-v1/catalog.json');
  const catalog = JSON.parse(fs.readFileSync(catalogPath, 'utf8'));
  let changed = false;
  for (const shard of catalog.groups.R11.shards) {
    const file = path.join(root, shard.path), tar = gunzipSync(fs.readFileSync(file));
    for (let offset = 0; offset + 512 <= tar.length;) {
      const header = tar.subarray(offset, offset + 512);
      const field = (start, end) => header.subarray(start, end).toString('utf8').replace(/\0.*$/s, '');
      const name = [field(345, 500), field(0, 100)].filter(Boolean).join('/');
      const size = parseInt(field(124, 136).trim() || '0', 8);
      assert.ok(Number.isSafeInteger(size) && size >= 0, 'fixture tar numeric size');
      if (name === originals[0].path) {
        assert.equal(parseInt(field(100, 108).trim(), 8), 0o600);
        header.write('0000644\0', 100, 8, 'ascii'); header.fill(32, 148, 156);
        const checksum = header.reduce((sum, byte) => sum + byte, 0);
        header.write(checksum.toString(8).padStart(6, '0') + '\0 ', 148, 8, 'ascii');
        changed = true; break;
      }
      offset += 512 + Math.ceil(size / 512) * 512;
    }
    if (changed) {
      const bytes = gzipSync(tar, { mtime: 0 }); write(file, bytes); shard.sha256 = hash(bytes); break;
    }
  }
  assert.ok(changed, 'expected literal member must exist in tar');
  write(catalogPath, JSON.stringify(catalog, null, 2) + '\n');
}

if (selfCheck) {
  isolated('literal Git fixture keeps original 0600/0700 modes and bounded inputs', f => {
    for (const expected of originals) {
      assert.equal(fs.statSync(path.join(f.root, expected.path)).mode & 0o777, expected.mode);
      assert.deepEqual(fs.readFileSync(path.join(f.root, expected.path)), expected.bytes);
    }
    assert.ok(originals.reduce((sum, f) => sum + f.bytes.length, 0) < 1024 * 1024);
    assert.equal(git(f.root, 'status', '--porcelain'), '');
  });
} else {
  isolated('fresh clone under umask022 normalizes inline 0600/0700 to 0644/0755 and verifies', f => {
    const clone = migratedClone(f), before = inlineState(clone);
    success(archiveCli(f, clone, 'verify', 'R11')); success(archiveCli(f, clone, 'verify'));
    assert.deepEqual(inlineState(clone), before);
  });
  isolated('inline user-executable classification changes are rejected in both directions', f => {
    const clone = migratedClone(f);
    for (const [expected, wrongMode] of [[originals[0], 0o744], [originals[1], 0o655]]) {
      const file = path.join(clone, expected.path); fs.chmodSync(file, wrongMode);
      const before = inlineState(clone); failure(archiveCli(f, clone, 'verify', 'R11'));
      assert.deepEqual(inlineState(clone), before); fs.chmodSync(file, expected.checkoutMode);
    }
  });
  isolated('archive header full mode stays strict when gzip and catalog SHA hashes are valid', f => {
    const clone = migratedClone(f); tamperHeaderAndUpdateOuterHash(clone);
    const before = inlineState(clone); failure(archiveCli(f, clone, 'verify', 'R11'));
    assert.deepEqual(inlineState(clone), before);
  });
  isolated('restore from normalized checkout recovers full original 0600/0700 modes without overwrite', f => {
    const clone = migratedClone(f), out = path.join(f.home, 'restored'); fs.mkdirSync(out);
    for (const [index, expected] of originals.filter(f => f.inline).entries()) {
      const destination = path.join(out, `${index} restored file`);
      success(archiveCli(f, clone, 'restore', expected.path, destination));
      assert.equal(fs.statSync(destination).mode & 0o777, expected.mode);
      assert.deepEqual(fs.readFileSync(destination), expected.bytes);
      failure(archiveCli(f, clone, 'restore', expected.path, destination));
      assert.equal(fs.statSync(destination).mode & 0o777, expected.mode);
      assert.deepEqual(fs.readFileSync(destination), expected.bytes);
    }
    assert.equal(fs.readdirSync(out).length, 2);
  });
  isolated('completed removal replays on normalized fresh clone without changing retained originals', f => {
    const clone = migratedClone(f), before = inlineState(clone);
    success(operate(f, clone, 'remove')); assert.deepEqual(inlineState(clone), before);
    assert.ok(!fs.existsSync(path.join(clone, originals[2].path)));
    assert.equal(git(clone, 'status', '--porcelain'), '');
  });
  isolated('present archive-only original retains strict full-mode preflight before any deletion', f => {
    success(operate(f, f.root, 'pack'));
    fs.chmodSync(path.join(f.root, originals[2].path), 0o644);
    const before = inlineState(f.root); failure(operate(f, f.root, 'remove'));
    assert.deepEqual(inlineState(f.root), before);
    assert.deepEqual(fs.readFileSync(path.join(f.root, originals[2].path)), originals[2].bytes);
    assert.equal(fs.statSync(path.join(f.root, originals[2].path)).mode & 0o777, 0o644);
  });
}

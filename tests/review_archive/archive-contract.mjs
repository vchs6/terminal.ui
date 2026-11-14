import assert from 'node:assert/strict';
import fs from 'node:fs';
import path from 'node:path';
import { spawnSync } from 'node:child_process';
import { gunzipSync } from 'node:zlib';
import { test } from 'node:test';
import { fixture, files, hash, snapshot, write } from './fixtures.mjs';

const selfCheck = process.argv[2] === '--self-check';
const cli = selfCheck ? null : process.argv[2] && path.resolve(process.argv[2]);
if (!selfCheck && !cli) throw new Error('Usage: node archive-contract.mjs /absolute/path/review-archive.mjs | --self-check');

function isolated(name, fn) {
  test(name, () => { const f = fixture(); try { fn(f); } finally { f.cleanup(); } });
}
function invoke(f, ...args) {
  const result = spawnSync(process.execPath, [cli, '--root', f.root, ...args], {
    cwd: f.home, encoding: 'utf8', timeout: 15000, maxBuffer: 1024 * 1024,
  });
  assert.ifError(result.error);
  return result;
}
function ok(f, ...args) {
  const r = invoke(f, ...args);
  assert.equal(r.status, 0, `${args.join(' ')} failed:\n${r.stderr}\n${r.stdout}`);
  return r;
}
function bad(f, ...args) {
  const r = invoke(f, ...args);
  assert.notEqual(r.status, 0, `${args.join(' ')} silently accepted invalid input: ${r.stdout}`);
  assert.ok((r.stderr + r.stdout).trim().length, 'rejection must provide a diagnostic');
  return r;
}
function row(f, logical = files[2].path) { return f.records.R11.find(r => r.path === logical); }
function restored(destination, expected) {
  const stat = fs.lstatSync(destination);
  assert.ok(stat.isFile(), 'restore must publish a regular file');
  assert.equal(stat.size, expected.bytes.length);
  assert.equal(stat.mode & 0o777, expected.mode);
  assert.deepEqual(fs.readFileSync(destination), expected.bytes);
  assert.equal(hash(fs.readFileSync(destination)), hash(expected.bytes));
}

isolated('fixture has independently declared bytes, safe members, complete manifests, and bounded size', f => {
  for (const group of ['R11', 'R12']) {
    const entry = f.catalog.groups[group];
    const manifest = fs.readFileSync(path.join(f.root, entry.manifest.path));
    assert.equal(hash(manifest), entry.manifest.sha256);
    assert.equal(gunzipSync(manifest).toString().trim().split('\n').length, group === 'R11' ? 5 : 1);
    const shard = fs.readFileSync(path.join(f.root, entry.shards[0].path));
    assert.equal(hash(shard), entry.shards[0].sha256);
    for (const expected of files.filter(x => x.path.split('/')[2] === group)) {
      const result = spawnSync('tar', ['-xOf', path.join(f.root, entry.shards[0].path), '--', expected.path], { maxBuffer: 1024 * 1024 });
      assert.equal(result.status, 0); assert.deepEqual(result.stdout, expected.bytes);
      assert.equal(fs.existsSync(path.join(f.root, expected.path)), expected.inline);
    }
  }
});

if (!selfCheck) {
  isolated('list, resolve, and verify preserve the fixture and expose all rounds', f => {
    const before = snapshot(f.root);
    const listed = JSON.parse(ok(f, 'list').stdout);
    assert.match(JSON.stringify(listed), /R11/); assert.match(JSON.stringify(listed), /R12/);
    ok(f, 'verify'); ok(f, 'verify', 'R11'); ok(f, 'verify', 'R12');
    for (const expected of files) {
      const resolved = JSON.parse(ok(f, 'resolve', expected.path).stdout);
      assert.equal(resolved.path, expected.path);
      assert.equal(resolved.inline, expected.inline);
      assert.equal(resolved.sha256, hash(expected.bytes));
      assert.equal(resolved.size, expected.bytes.length); assert.equal(resolved.mode, expected.mode);
      if (!expected.inline) {
        assert.equal(resolved.member, expected.path);
        assert.equal(resolved.shard, `docs/reviews/${expected.path.split('/')[2]}/.archive-v1/part-000001.tar.gz`);
      }
    }
    assert.deepEqual(snapshot(f.root), before, 'read commands modified repository contents or modes');
  });

  isolated('resolve normalizes known repository roots and dot path spelling', f => {
    for (const logical of [files[2].path, './' + files[2].path,
      '/workspace/work/terminal.ui/' + files[2].path, f.root + '/' + files[2].path]) {
      assert.equal(JSON.parse(ok(f, 'resolve', logical).stdout).path, files[2].path);
    }
  });

  for (const logical of ['src/app.cj', '/usr/sdk/docs/reviews/R11/raw/审查 evidence.bin',
    '/tmp/cache/docs/reviews/R11/raw/审查 evidence.bin', 'docs/reviews/R11/not-recorded.bin',
    '../docs/reviews/R11/raw/empty.dat', 'docs/reviews/R11/../../../src/app.cj']) {
    isolated(`resolve rejects unknown or external logical path ${logical}`, f => {
      const before = snapshot(f.root); bad(f, 'resolve', logical); assert.deepEqual(snapshot(f.root), before);
    });
  }

  isolated('restore publishes every original byte, size, and mode, including empty and Unicode paths', f => {
    const before = snapshot(f.root), out = path.join(f.home, 'restored'); fs.mkdirSync(out);
    for (const [index, expected] of files.entries()) {
      const destination = path.join(out, `${index} output 审查`);
      ok(f, 'restore', expected.path, destination); restored(destination, expected);
    }
    assert.equal(fs.readdirSync(out).length, files.length, 'restore left temporary files');
    assert.deepEqual(snapshot(f.root), before);
  });

  isolated('restore never overwrites an existing destination file or symlink', f => {
    const dest = path.join(f.home, 'existing'); write(dest, 'original destination\n', 0o600);
    bad(f, 'restore', files[2].path, dest);
    assert.equal(fs.readFileSync(dest, 'utf8'), 'original destination\n');
    assert.equal(fs.statSync(dest).mode & 0o777, 0o600);
    const link = path.join(f.home, 'existing-link'); fs.symlinkSync(dest, link);
    bad(f, 'restore', files[2].path, link);
    assert.ok(fs.lstatSync(link).isSymbolicLink()); assert.equal(fs.readFileSync(dest, 'utf8'), 'original destination\n');
  });

  const corruptions = [
    ['missing manifest', f => fs.unlinkSync(path.join(f.root, f.catalog.groups.R11.manifest.path))],
    ['manifest SHA mismatch', f => fs.appendFileSync(path.join(f.root, f.catalog.groups.R11.manifest.path), 'tamper')],
    ['missing shard', f => fs.unlinkSync(path.join(f.root, f.catalog.groups.R11.shards[0].path))],
    ['shard SHA mismatch', f => fs.appendFileSync(path.join(f.root, f.catalog.groups.R11.shards[0].path), 'tamper')],
    ['missing inline file', f => fs.unlinkSync(path.join(f.root, files[0].path))],
    ['inline byte mismatch', f => fs.writeFileSync(path.join(f.root, files[0].path), 'x'.repeat(files[0].bytes.length))],
    ['inline mode mismatch', f => fs.chmodSync(path.join(f.root, files[3].path), 0o644)],
    ['inline symlink', f => { fs.unlinkSync(path.join(f.root, files[0].path)); fs.symlinkSync(path.join(f.source, files[0].path), path.join(f.root, files[0].path)); }],
    ['missing member with valid shard hash', f => f.pack('R11', files.filter(x => x.path.startsWith('docs/reviews/R11/') && x !== files[2]).map(x => x.path))],
    ['member byte mismatch with valid shard hash', f => { write(path.join(f.source, files[2].path), Buffer.from([1,255,128,1,10,32,65,0])); f.pack(); }],
    ['member mode mismatch with valid shard hash', f => { fs.chmodSync(path.join(f.source, files[2].path), 0o600); f.pack(); }],
    ['member size mismatch with valid shard hash', f => { write(path.join(f.source, files[2].path), 'short'); f.pack(); }],
    ['member symlink with valid shard hash', f => { fs.unlinkSync(path.join(f.source, files[2].path)); fs.symlinkSync('../README.md', path.join(f.source, files[2].path)); f.pack(); }],
    ['unlisted member', f => { write(path.join(f.source, 'docs/reviews/R11/unlisted.txt'), 'extra\n'); f.pack('R11', [...f.records.R11.map(r => r.path), 'docs/reviews/R11/unlisted.txt']); }],
    ['duplicate archive member', f => f.pack('R11', [...f.records.R11.map(r => r.path), files[2].path])],
    ['traversal archive member', f => f.pack('R11', undefined, ['--transform=s@^docs/@../escaped/@'])],
    ['absolute archive member', f => f.pack('R11', undefined, ['--transform=s@^docs/@/escaped/@'])],
    ['manifest record SHA mismatch', f => { row(f).sha256 = '0'.repeat(64); f.saveManifest(); }],
    ['manifest record size mismatch', f => { row(f).size++; f.saveManifest(); }],
    ['manifest record mode mismatch', f => { row(f).mode = 0o777; f.saveManifest(); }],
    ['manifest duplicate logical path', f => { f.records.R11.push({ ...row(f) }); f.saveManifest(); }],
    ['manifest traversal logical path', f => { row(f).path = '../escaped'; f.saveManifest(); }],
    ['manifest external logical path', f => { row(f).path = 'src/external.cj'; f.saveManifest(); }],
    ['manifest traversal member', f => { row(f).member = '../escaped'; f.saveManifest(); }],
    ['manifest absolute member', f => { row(f).member = '/tmp/escaped'; f.saveManifest(); }],
    ['manifest non-file type', f => { row(f).type = 'symlink'; f.saveManifest(); }],
    ['catalog traversal shard', f => { f.catalog.groups.R11.shards[0].path = '../outside.tar.gz'; f.saveCatalog(); }],
    ['catalog absolute manifest', f => { f.catalog.groups.R11.manifest.path = path.join(f.home, 'outside.gz'); f.saveCatalog(); }],
  ];
  for (const [name, mutate] of corruptions) {
    isolated(`verify rejects ${name}`, f => {
      mutate(f); const before = snapshot(f.root); bad(f, 'verify', 'R11');
      assert.deepEqual(snapshot(f.root), before, 'verification changed evidence');
      assert.ok(!fs.existsSync(path.join(f.home, 'escaped')), 'unsafe member escaped extraction');
    });
  }

  for (const [name, mutate] of corruptions.filter(([name]) => [
    'missing shard', 'shard SHA mismatch', 'missing member with valid shard hash',
    'member byte mismatch with valid shard hash', 'member mode mismatch with valid shard hash',
    'member size mismatch with valid shard hash', 'member symlink with valid shard hash',
    'traversal archive member', 'absolute archive member', 'manifest record SHA mismatch',
  ].includes(name))) {
    isolated(`restore rejects ${name} without publishing destination or temporary files`, f => {
      mutate(f); const out = path.join(f.home, 'output'); fs.mkdirSync(out);
      const before = snapshot(f.root); bad(f, 'restore', files[2].path, path.join(out, 'wanted'));
      assert.deepEqual(fs.readdirSync(out), []); assert.deepEqual(snapshot(f.root), before);
    });
  }

  isolated('verify group scope does not hide corruption in the all-groups check', f => {
    fs.appendFileSync(path.join(f.root, f.catalog.groups.R12.shards[0].path), 'tamper');
    ok(f, 'verify', 'R11'); bad(f, 'verify'); bad(f, 'verify', 'R12'); bad(f, 'verify', 'UNKNOWN');
  });

  isolated('invalid command and missing required arguments fail with diagnostics', f => {
    for (const args of [[], ['migrate'], ['resolve'], ['restore'], ['restore', files[2].path]]) bad(f, ...args);
  });
}

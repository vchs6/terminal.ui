import assert from 'node:assert/strict';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import { createHash } from 'node:crypto';
import { gzipSync } from 'node:zlib';
import { spawnSync } from 'node:child_process';

export const hash = bytes => createHash('sha256').update(bytes).digest('hex');
export const files = [
  { path: 'docs/reviews/R11/README.md', bytes: Buffer.from('# Synthetic review\n[image](./screen shot.png)\n'), mode: 0o644, inline: true },
  { path: 'docs/reviews/R11/screen shot.png', bytes: Buffer.from([137,80,78,71,13,10,26,10,0,255,1,2]), mode: 0o644, inline: true },
  { path: 'docs/reviews/R11/raw/审查 evidence.bin', bytes: Buffer.from([0,255,128,1,10,32,65,0]), mode: 0o644, inline: false },
  { path: 'docs/reviews/R11/raw/tool.sh', bytes: Buffer.from('#!/bin/sh\nprintf synthetic\\n\n'), mode: 0o755, inline: true },
  { path: 'docs/reviews/R11/raw/empty.dat', bytes: Buffer.alloc(0), mode: 0o600, inline: false },
  { path: 'docs/reviews/R12/raw/second.txt', bytes: Buffer.from('second independent round\n'), mode: 0o644, inline: false },
];

export function write(file, bytes, mode = 0o644) {
  fs.mkdirSync(path.dirname(file), { recursive: true });
  fs.writeFileSync(file, bytes, { mode });
  fs.chmodSync(file, mode);
}

export function snapshot(root) {
  const rows = [];
  function walk(dir) {
    for (const name of fs.readdirSync(dir).sort()) {
      const file = path.join(dir, name), stat = fs.lstatSync(file), rel = path.relative(root, file);
      if (stat.isDirectory()) { rows.push([rel, 'dir', stat.mode & 0o777]); walk(file); }
      else if (stat.isSymbolicLink()) rows.push([rel, 'symlink', fs.readlinkSync(file)]);
      else rows.push([rel, 'file', stat.mode & 0o777, stat.size, hash(fs.readFileSync(file))]);
    }
  }
  walk(root);
  return rows;
}

export function fixture() {
  const home = fs.mkdtempSync(path.join(os.tmpdir(), 'archive-contract-'));
  const root = path.join(home, 'repo'), source = path.join(home, 'literal-input');
  fs.mkdirSync(root); fs.mkdirSync(source);
  const catalog = { version: 1, groups: {} }, records = {};
  write(path.join(root, 'docs/reviews/README.md'), '# Review index stays inline\n');
  for (const f of files) {
    write(path.join(source, f.path), f.bytes, f.mode);
    if (f.inline) write(path.join(root, f.path), f.bytes, f.mode);
  }
  function saveCatalog() { write(path.join(root, 'docs/reviews/archive-v1/catalog.json'), `${JSON.stringify(catalog, null, 2)}\n`); }
  function saveManifest(group = 'R11') {
    const entry = catalog.groups[group];
    const bytes = gzipSync(Buffer.from(records[group].map(r => JSON.stringify(r)).join('\n') + '\n'), { mtime: 0 });
    write(path.join(root, entry.manifest.path), bytes);
    entry.manifest.sha256 = hash(bytes); saveCatalog();
  }
  function pack(group = 'R11', names, extraArgs = []) {
    const entry = catalog.groups[group];
    names ??= files.filter(f => f.path.split('/')[2] === group).map(f => f.path);
    const result = spawnSync('tar', ['--format=ustar', '--no-recursion', '-C', source,
      ...extraArgs, '--null', '-T', '-', '-cf', '-'], { input: Buffer.from(names.join('\0') + '\0'), maxBuffer: 1024 * 1024 });
    assert.equal(result.status, 0, `fixture GNU tar: ${result.stderr}`);
    const bytes = gzipSync(result.stdout, { mtime: 0 });
    write(path.join(root, entry.shards[0].path), bytes);
    entry.shards[0].sha256 = hash(bytes); saveCatalog();
  }
  for (const group of ['R11', 'R12']) {
    const base = `docs/reviews/${group}/.archive-v1`;
    catalog.groups[group] = { manifest: { path: `${base}/manifest.jsonl.gz`, sha256: '' }, shards: [{ path: `${base}/part-000001.tar.gz`, sha256: '' }] };
    records[group] = files.filter(f => f.path.split('/')[2] === group).map(f => ({
      path: f.path, type: 'file', mode: f.mode, size: f.bytes.length, sha256: hash(f.bytes),
      shard: `${base}/part-000001.tar.gz`, member: f.path, inline: f.inline,
    })).sort((a, b) => Buffer.compare(Buffer.from(a.path), Buffer.from(b.path)));
    pack(group); saveManifest(group);
  }
  const size = snapshot(root).filter(r => r[1] === 'file').reduce((sum, r) => sum + r[3], 0);
  assert.ok(size < 1024 * 1024, `fixture exceeds 1 MiB: ${size}`);
  return { home, root, source, catalog, records, saveCatalog, saveManifest, pack,
    cleanup: () => fs.rmSync(home, { recursive: true, force: true }) };
}

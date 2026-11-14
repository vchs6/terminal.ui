import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import zlib from 'node:zlib';
import readline from 'node:readline';

export const fail = message => { throw new Error(message); };
export function logical(value, root) {
  for (const prefix of [root + '/', '/workspace/work/terminal.ui/']) if (value.startsWith(prefix)) { value = value.slice(prefix.length); break; }
  if (value.startsWith('./')) value = value.slice(2);
  if (!value.startsWith('docs/reviews/') || value.includes('\\') || value.includes('\0') || value.split('/').some(x => !x || x === '.' || x === '..')) fail(`invalid logical path: ${value}`);
  return value;
}
export function safe(root, p) {
  if (typeof p !== 'string' || p.startsWith('/') || p.includes('\\') || p.split('/').some(x => !x || x === '.' || x === '..')) fail(`invalid path: ${p}`);
  const parts = p.split('/'); let current = root;
  for (const part of parts) { current = path.join(current, part); const s = fs.lstatSync(current); if (s.isSymbolicLink()) fail(`symlink: ${p}`); }
  return current;
}
export async function digest(file) {
  const h = crypto.createHash('sha256'); let size = 0;
  for await (const chunk of fs.createReadStream(file)) { h.update(chunk); size += chunk.length; }
  return {sha256:h.digest('hex'),size};
}
const sha = s => typeof s === 'string' && /^[a-f0-9]{64}$/.test(s);
export async function load(root) {
  const catalog = JSON.parse(fs.readFileSync(safe(root,'docs/reviews/archive-v1/catalog.json'),'utf8'));
  if (catalog.version !== 1 || !catalog.groups || typeof catalog.groups !== 'object' || Array.isArray(catalog.groups)) fail('invalid catalog');
  return catalog;
}
export async function groupData(root, catalog, group) {
  if (!/^[A-Za-z0-9_-]+$/.test(group) || !Object.hasOwn(catalog.groups,group)) fail(`unknown group: ${group}`);
  const g = catalog.groups[group], base = `docs/reviews/${group}/.archive-v1/`;
  if (!g || !g.manifest || g.manifest.path !== base+'manifest.jsonl.gz' || !sha(g.manifest.sha256) || !Array.isArray(g.shards) || !g.shards.length) fail('invalid group catalog');
  const shards = new Map();
  for (const s of g.shards) { if (!s || !new RegExp(`^${base.replaceAll('.', '\\.') }part-[0-9]{6}\\.tar\\.gz$`).test(s.path) || !sha(s.sha256) || shards.has(s.path)) fail('invalid shard catalog'); shards.set(s.path,s); }
  const manifest = safe(root,g.manifest.path); if ((await digest(manifest)).sha256 !== g.manifest.sha256) fail('manifest SHA mismatch');
  const records = [], byPath = new Map(); let last = '';
  const input = fs.createReadStream(manifest).pipe(zlib.createGunzip());
  for await (const line of readline.createInterface({input,crlfDelay:Infinity})) {
    if (!line || line.length > 1024*1024) fail('invalid manifest line');
    const r=JSON.parse(line);
    if (!r || typeof r.path !== 'string' || logical(r.path,root)!==r.path || !r.path.startsWith(`docs/reviews/${group}/`) || r.path.includes('/.archive-v1/') || r.path<=last || r.type!=='file' || !Number.isInteger(r.mode) || r.mode<0 || r.mode>0o7777 || !Number.isSafeInteger(r.size) || r.size<0 || !sha(r.sha256) || !shards.has(r.shard) || r.member!==r.path || typeof r.inline!=='boolean') fail('invalid manifest record');
    last=r.path; records.push(r); byPath.set(r.path,r);
  }
  return {records,byPath,shards};
}
export async function checkInline(root,r) {
  const f=safe(root,r.path), s=fs.lstatSync(f); if (!s.isFile() || (s.mode & 0o100)!==(r.mode & 0o100)) fail(`inline type/mode mismatch: ${r.path}`);
  const d=await digest(f); if (d.size!==r.size || d.sha256!==r.sha256) fail(`inline mismatch: ${r.path}`);
}

// Fixture-only key/shape controls; no product runtime success claim.
import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import { parseResults, verifyHeadless } from './oracle.mjs';
const raw=readFileSync(new URL('./fixtures/headless-key-collision.tsv',import.meta.url),'utf8');
assert.throws(()=>parseResults(raw),/duplicate.*record shape/,'actual historical capability/result collision cannot silently overwrite');
for(const text of [
 'same\tUnsupported|KnownUnavailable|NoDevice|Direct|osc2\nsame\tSetHostTitle|Unsupported|0|NoDevice|-1|NotNeeded\n',
 'same\tSetHostTitle|Unsupported|0|NoDevice|-1|NotNeeded\nsame\tUnsupported|KnownUnavailable|NoDevice|Direct|osc2\n'
]) assert.throws(()=>parseResults(text),/duplicate.*record shape/);
const capabilityKeys=new Set(['headless.id','headless.clipboard','headless.title','headless.titleStack','headless.imageIcon']);
const renamed=raw.split('\n').map(line=>{
 const tab=line.indexOf('\t');if(tab<0)return line;
 const key=line.slice(0,tab),value=line.slice(tab+1);
 if(capabilityKeys.has(key)&&(key!=='headless.title'||value.split('|').length===5))
  return 'headless.capabilities.'+key.slice('headless.'.length)+'\t'+value;
 return line;
}).join('\n');
const rows=parseResults(renamed);
verifyHeadless(rows,Buffer.alloc(0));
assert(rows.get('headless.capabilities.title').startsWith('Unsupported|KnownUnavailable|NoDevice|'));
assert(rows.get('headless.title').startsWith('SetHostTitle|Unsupported|0|NoDevice|'));
// Existing getter/mount observations legitimately repeat. Retain the original
// same-shape last-value behavior; this is not per-invocation semantic validation.
const grouped=new Map();
for(const line of renamed.trim().split('\n')) {
 const tab=line.indexOf('\t'),key=line.slice(0,tab),value=line.slice(tab+1);
 grouped.set(key,[...(grouped.get(key)??[]),value]);
}
const repeated=[...grouped].filter(([,values])=>values.length>1);
assert(repeated.length>0,'real supplied fixture includes repeated observations');
for(const [key,values] of repeated) {
 assert.equal(new Set(values.map(value=>value.split('|').length)).size,1);
 assert.equal(rows.get(key),values.at(-1),'same-shape last-value behavior preserved');
}
console.log(`PASS fixture-only record keys: cross-shape negatives=3; distinct capability/operation namespaces; same-shape last-wins keys=${repeated.length}; no product run`);

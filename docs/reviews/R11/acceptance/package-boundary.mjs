import {readFileSync,writeFileSync} from 'node:fs';
import {execFileSync} from 'node:child_process';
import path from 'node:path';
import assert from 'node:assert/strict';
import {parse} from '/workspace/work/frame-execution/repo/node_modules/smol-toml/dist/index.js';
const base='/workspace/work/frame-execution', file=base+'/repo/target/cjtui-0.0.0.cjp';
const entries=execFileSync('tar',['-tzf',file]).toString().trim().split('\n');
const listing=execFileSync('tar',['-tvzf',file]).toString();
assert(listing.trim().split('\n').every(x=>['-','d'].includes(x[0])));
const names=new Set(entries),tables=[],manifests=[];
function visit(value,manifest,trail=''){if(!value||typeof value!=='object')return;for(const[k,v]of Object.entries(value)){if(['dependencies','test-dependencies','script-dependencies'].includes(k)){tables.push({manifest,table:trail+k,entries:v});for(const[n,d]of Object.entries(v)){assert(!d.git);if(d.path){assert.notEqual(manifest,'cjtui-0.0.0/cjpm.toml');assert(!path.posix.isAbsolute(d.path));assert(!d.path.includes('\\'));const target=path.posix.normalize(path.posix.join(path.posix.dirname(manifest),d.path,'cjpm.toml'));assert(target.startsWith('cjtui-0.0.0/'));assert(names.has(target));}}}else visit(v,manifest,trail+k+'.');}}
for(const member of entries.filter(x=>x.endsWith('/cjpm.toml'))){const manifest=parse(execFileSync('tar',['-xOzf',file,member]).toString());manifests.push({path:member,manifest});visit(manifest,member);}
const root=manifests.find(x=>x.path==='cjtui-0.0.0/cjpm.toml').manifest;
assert.deepEqual(root.dependencies,{ansies:{version:'1.3.113'},unicode:{version:'0.1.0'},unicodewidth:{version:'0.1.113'}});
const consumer=parse(readFileSync(base+'/public-consumer/tests/composition/cjpm.toml','utf8'));
assert.deepEqual(consumer.dependencies,{cjtui:{path:base+'/unpacked/cjtui-0.0.0'}});
assert(!consumer.ffi);for(const key of ['compile-option','override-compile-option','link-option'])assert(!consumer.package[key]);
const result={passed:true,allEntryTypes:'regular files or directories',manifests,dependencyTables:tables,consumerManifest:consumer,fullRelease:'failed: missing future examples/composition/cjpm.toml; unchanged original checker exit 1'};
writeFileSync('/workspace/work/frame-acceptance/package-boundary.json',JSON.stringify(result,null,2)+'\n');
console.log(JSON.stringify({passed:true,manifests:manifests.length,dependencyTables:tables.length,consumerHasNoPrivateFfiOrFlags:true}));

import assert from 'node:assert/strict';
import fs from 'node:fs';
import cp from 'node:child_process';
import crypto from 'node:crypto';
import {parse} from './repo/node_modules/smol-toml/dist/index.js';
const [archive,source]=process.argv.slice(2);
const run=(cmd,args)=>cp.execFileSync(cmd,args,{encoding:'utf8'});
const entries=run('tar',['-tzf',archive]).trim().split('\n').map(x=>x.replace(/^\.\//,''));
assert(entries.every(p=>!p.startsWith('/')&&!p.split('/').includes('..')));
assert(run('tar',['-tvzf',archive]).trim().split('\n').every(x=>/^[-d]/.test(x)));
const roots=entries.filter(p=>p==='cjpm.toml'||/^[^/]+\/cjpm\.toml$/.test(p));
assert.equal(roots.length,1);
const prefix=roots[0].slice(0,-'cjpm.toml'.length);
assert(entries.every(p=>p.startsWith(prefix)||p===prefix.replace(/\/$/,'')));
const paths=entries.map(p=>p.slice(prefix.length)).filter(p=>p&&!p.endsWith('/'));
const allowed=/^(?:src\/|examples\/|benchmarks\/|docs\/product\/|native\/.*\.(?:sh|c|h|S|cj)$|third_party\/licenses\/|build\.cj$|cjpm\.toml$|README(?:_zh)?\.md$|LICENSE$|NOTICE$|CHANGELOG\.md$)/;
for(const p of paths) {
 assert(allowed.test(p),`unexpected package path: ${p}`);
 assert(!p.split('/').some(s=>s.startsWith('.')||['target','node_modules','cache','build-script-cache'].includes(s)),p);
 assert(!/\.(?:a|o|so|cjo|cjp|zip|tar|gz)$/i.test(p),p);
 assert(!/(?:^|\/)(?:AGENTS\.md|BATTLE_PROTOCOL\.md|ENGINEERING_TASK_DECOMPOSITION\.md|cangjie-repo\.toml|cjpm\.lock|package(?:-lock)?\.json)$/.test(p),p);
}
const tracked=cp.execFileSync('git',['ls-files','-z','src','native','build.cj','examples/minimal','examples/layout','docs/product','LICENSE','NOTICE','CHANGELOG.md','README.md'],{cwd:source,encoding:'utf8'}).split('\0').filter(p=>p&&!p.split('/').some(part=>part.startsWith('.')));
const checked=[];
for(const p of tracked) {
 assert(paths.includes(p),`missing implemented source: ${p}`);
 const actual=cp.execFileSync('tar',['-xOzf',archive,prefix+p]);
 assert(actual.equals(fs.readFileSync(source+'/'+p)),`source mismatch: ${p}`);
 checked.push({path:p,sha256:crypto.createHash('sha256').update(actual).digest('hex')});
}
for(const path of paths.filter(p=>p==='cjpm.toml'||p.endsWith('/cjpm.toml'))) {
 const data=parse(run('tar',['-xOzf',archive,prefix+path]));
 function visit(obj) { if(!obj||typeof obj!=='object') return; for(const [key,value] of Object.entries(obj)) {
  if(['dependencies','test-dependencies','script-dependencies'].includes(key)) {
   for(const [name,dep] of Object.entries(value)) {
    assert(!dep.git,`git dependency ${path}:${name}`);
    if(path==='cjpm.toml') assert(!dep.path,`root path dependency ${name}`);
    if(dep.path) {assert(!dep.path.startsWith('/')&&!dep.path.includes('\\'));const pieces=path.split('/').slice(0,-1);for(const part of dep.path.split('/')) {if(part==='..') {assert(pieces.length);pieces.pop();} else if(part&&part!=='.') pieces.push(part);}assert(paths.includes([...pieces,'cjpm.toml'].join('/')));}
   }
  } else visit(value);
 }}
 visit(data);
 assert(!/node|npm|javascript|typescript/i.test(JSON.stringify(data)),`development runtime in manifest: ${path}`);
}
for(const sub of ['src/style/','src/geometry/','src/text/']) assert(paths.some(p=>p.startsWith(sub)&&p.endsWith('.cj')),`missing subpackage ${sub}`);
const result={scope:'implemented layout/decor slice source package; not full release',archive,entryCount:paths.length,checkedSourceCount:checked.length,sourceFiles:checked,passed:true,fullReleaseMissing:['examples/composition/cjpm.toml','benchmarks/rendering/cjpm.toml']};
fs.writeFileSync('/workspace/work/layout-execution/package/boundary.json',JSON.stringify(result,null,2)+'\n');
console.log(JSON.stringify({passed:true,entryCount:paths.length,checkedSourceCount:checked.length,subpackages:['style','geometry','text']},null,2));

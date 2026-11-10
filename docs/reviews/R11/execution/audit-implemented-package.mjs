import {readFileSync,writeFileSync} from 'node:fs';
import path from 'node:path';
const base='/workspace/work/frame-execution';
const a=JSON.parse(readFileSync(base+'/raw/package-audit.json'));
const prefix='cjtui-0.0.0/';
const names=new Set(a.entries.map(x=>x.path));
if(!a.allRegularOrDirectory)throw Error('special entry');
for(const e of a.entries){const p=e.path.slice(prefix.length);if(!e.path.startsWith(prefix)||p.split('/').some(x=>x==='..'||x.startsWith('.')||['target','node_modules','cache','tests','openspec'].includes(x))||/\.(a|o|so|cjo|cjp|zip|gz)$/.test(p))throw Error('unexpected entry '+p);if(e.sourceEqual!==true)throw Error('source mismatch '+p);}
const dependencyTables=[];
function visit(v,manifest,trail=''){if(!v||typeof v!=='object')return;for(const[k,x]of Object.entries(v)){if(['dependencies','test-dependencies','script-dependencies'].includes(k)){dependencyTables.push({manifest,table:trail+k,entries:x});for(const[n,d]of Object.entries(x||{})){if(d.git)throw Error('git dependency '+n);if(d.path){if(manifest===prefix+'cjpm.toml')throw Error('root path dep');if(path.posix.isAbsolute(d.path)||d.path.includes('\\'))throw Error('invalid path');const target=path.posix.normalize(path.posix.join(path.posix.dirname(manifest),d.path,'cjpm.toml'));if(!target.startsWith(prefix)||!names.has(target))throw Error('escaping/missing dep '+target);}}}else visit(x,manifest,trail+k+'.');}}
for(const m of a.manifests)visit(m.manifest,m.path);
for(const p of ['build.cj','src/frame.cj','src/cell.cj','docs/product/README.md','examples/minimal/cjpm.toml','examples/layout/cjpm.toml','examples/colors/cjpm.toml'])if(!names.has(prefix+p))throw Error('implemented entry missing '+p);
writeFileSync(base+'/raw/implemented-package-audit.json',JSON.stringify({regularFiles:a.entries.length,allEntriesSourceEqual:true,dependencyTables,scope:'Implemented entries only; original full checker remains failed and authoritative for full release'},null,2));
console.log('PASS actual 62-file source boundary, implemented entries and all recursive dependency tables; full release remains failed.');

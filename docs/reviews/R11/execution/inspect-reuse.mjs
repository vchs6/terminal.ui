import {readFileSync,writeFileSync,readdirSync,statSync,copyFileSync,mkdirSync} from 'node:fs';
import {join,relative} from 'node:path';
import {createHash} from 'node:crypto';
const base='/workspace/work/frame-execution';
const hash=p=>createHash('sha256').update(readFileSync(p)).digest('hex');
function inputs(root){let r={}; function walk(dir){for(const n of readdirSync(dir)){if(['target','.git','build-script-cache','cangjie-repo.toml'].includes(n))continue;const p=join(dir,n);if(statSync(p).isDirectory())walk(p);else if(/\.(cj|toml|c|h|S)$/.test(n))r[relative(root,p)]=hash(p);}}walk(root);return r;}
const a=inputs(base+'/cache/repository/source/default'), b=inputs('/workspace/work/frame-implementation/cache/repository/source/default');
const regressions=[]; mkdirSync(base+'/raw/reused',{recursive:true});
for(const n of ['contract','coordinates','colors','layout','decoration']){const row={name:n};for(const ext of ['stdout','stderr','exit']){const src='/workspace/work/frame-implementation/'+n+'.'+ext,dst=base+'/raw/reused/'+n+'.'+ext;copyFileSync(src,dst);row[ext+'Hash']=hash(dst);}row.exit=readFileSync(base+'/raw/reused/'+n+'.exit','utf8').trim();row.passes=(readFileSync(base+'/raw/reused/'+n+'.stdout','utf8').match(/^PASS:/gm)||[]).length;regressions.push(row);}
writeFileSync(base+'/raw/reuse-input-audit.json',JSON.stringify({dependenciesEqual:JSON.stringify(a)===JSON.stringify(b),executionDependencies:a,priorDependencies:b,regressions},null,2));

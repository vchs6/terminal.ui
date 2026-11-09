import fs from 'node:fs';
import path from 'node:path';
import {run,root,repo,hash} from './audit.mjs';
const evid=repo+'/docs/reviews/R7/evidence/licenses';
const index=JSON.parse(fs.readFileSync(evid+'/evidence-index.json'));
const central=JSON.parse(fs.readFileSync(repo+'/docs/development/central-packages.json')).packages;
function walk(d){return fs.readdirSync(d,{withFileTypes:true}).flatMap(e=>e.isDirectory()?walk(path.join(d,e.name)):e.isFile()?[path.join(d,e.name)]:[]);}
const results=[];
fs.mkdirSync(root+'/packages',{recursive:true});
for(const p of index.packages){
 const arch='/workspace/work/validation/replay-dependencies/archives/'+p.name+'-'+p.version+'.cjp';
 const actualHash=hash(fs.readFileSync(arch));
 if(actualHash!==p.cjp_sha256||actualHash!==central[p.name].index.sha256sum)throw Error('archive/index mismatch '+p.name);
 if(run('tar',['xf',arch,'-C',root+'/packages']).status)throw Error('extract '+p.name);
 const pkg=root+'/packages/'+p.name+'-'+p.version;
 const up=root+'/upstreams/'+p.name;
 const commit=run('git',['rev-parse','HEAD'],up).stdout.trim();if(commit!==p.commit)throw Error('upstream commit '+p.name);
 const counts={same:0,line_endings_only:0,different:0,missing:0};const detail={different:[],missing:[]};
 const entries=[];
 for(const f of walk(pkg)){
  const rel=path.relative(pkg,f),uf=up+'/'+rel,b=fs.readFileSync(f);let kind;
  if(!fs.existsSync(uf)){kind='missing';detail.missing.push(rel);}
  else {const u=fs.readFileSync(uf);if(b.equals(u))kind='same';else if(b.toString('latin1').replaceAll('\r\n','\n')===u.toString('latin1').replaceAll('\r\n','\n'))kind='line_endings_only';else {kind='different';detail.different.push(rel);}}
  counts[kind]++;entries.push({path:rel,sha256:hash(b),comparison:kind});
 }
 for(const k of Object.keys(counts))if(counts[k]!==p.comparison[k])throw Error('count mismatch '+p.name+' '+k+' '+counts[k]+' vs '+p.comparison[k]);
 for(const k of ['different','missing'])if(JSON.stringify(detail[k].sort())!==JSON.stringify([...p[k]].sort()))throw Error('difference list mismatch '+p.name+' '+k);
 const licenses=[];
 for(const l of p.licenses){
  const saved=fs.readFileSync(evid+'/'+l.path),fromGit=fs.readFileSync(up+'/'+path.basename(l.path));
  if(hash(saved)!==l.sha256||!saved.equals(fromGit))throw Error('license mismatch '+l.path);
  licenses.push({path:l.path,sha256:hash(saved),matchesFixedGit:true});
 }
 for(const [saved,original] of [['package-README.md.txt','README.md'],['package-cjpm.toml','cjpm.toml']])if(!fs.readFileSync(evid+'/evidence/'+p.name+'/'+saved).equals(fs.readFileSync(pkg+'/'+original)))throw Error('package evidence mismatch '+p.name+'/'+saved);
 results.push({name:p.name,version:p.version,repository:p.repository,commit,cjp_sha256:actualHash,counts,detail,licenses,entries});
 console.log(p.name,JSON.stringify(counts),'licenses',licenses.length,'match fixed Git');
}
fs.writeFileSync(root+'/provenance-results.json',JSON.stringify(results,null,2)+'\n');

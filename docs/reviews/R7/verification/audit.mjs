import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import {spawnSync} from 'node:child_process';
const root='/workspace/work/r7-acceptance';
const repo=root+'/repo';
const log=root+'/validation.txt';
export function run(cmd,args=[],cwd=repo,env={}) {
  const r=spawnSync(cmd,args,{cwd,encoding:'utf8',maxBuffer:16*1024*1024,env:{...process.env,...env}});
  fs.appendFileSync(log,`\n$ [cwd=${cwd}] ${JSON.stringify([cmd,...args])}\n${r.stdout||''}${r.stderr||''}\nexit=${r.status}${r.error?' error='+r.error.message:''}\n`);
  return r;
}
export const hash=b=>crypto.createHash('sha256').update(b).digest('hex');
export {root,repo};
if(process.argv[2]==='base') {
  fs.writeFileSync(log,'Independent acceptance verification; fixed e2c122de616207c9e5166a9c89416233b8b81268\nInitial exploratory reads were read-only; this log records substantive checks and numeric exits.\n');
  run('git',['rev-parse','HEAD']);
  if(!fs.existsSync(root+'/node_modules')) fs.symlinkSync('/workspace/work/terminal.ui/node_modules',root+'/node_modules','dir');
  run('node',['--version']);
  run('/workspace/work/terminal.ui/node_modules/.bin/openspec',['--version']);
  run('npm',['run','check'],repo,{PATH:'/workspace/work/terminal.ui/node_modules/.bin:'+process.env.PATH});
  for(const d of ['native','licenses'])run('sha256sum',['-c','SHA256SUMS'],repo+'/docs/reviews/R7/evidence/'+d);
  run('bash',['-n','docs/reviews/R7/evidence/native/run-native.sh','docs/reviews/R7/evidence/native/run-transitive.sh']);
  run('node',['--check','docs/reviews/R7/evidence/native/generate-conformance.mjs']);
  for(const f of ['docs/development/tools.lock.json','package-lock.json','scripts/setup-development.mjs']) {
    const old=run('git',['show','9a5c7034d245a053ff4614c3b7f594689a5b1389:'+f]);
    const now=fs.readFileSync(repo+'/'+f,'utf8');
    if(old.stdout!==now) throw Error('tool changed: '+f);
    fs.appendFileSync(log,`TOOL_UNCHANGED ${f} sha256=${hash(now)}\n`);
  }
  run('git',['status','--short']);
}
if(process.argv[2]==='fetch') {
  const index=JSON.parse(fs.readFileSync(repo+'/docs/reviews/R7/evidence/licenses/evidence-index.json'));
  fs.mkdirSync(root+'/upstreams',{recursive:true});
  for(const p of index.packages) {
    const dest=root+'/upstreams/'+p.name;
    fs.mkdirSync(dest,{recursive:true});
    run('git',['init','-q'],dest);
    run('git',['fetch','--depth=1',p.repository,p.commit],dest);
    run('git',['checkout','--detach','FETCH_HEAD'],dest);
    run('git',['rev-parse','HEAD'],dest);
  }
}

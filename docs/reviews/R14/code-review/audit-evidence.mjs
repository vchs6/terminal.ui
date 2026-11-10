import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import {execFileSync} from 'node:child_process';
const root='/workspace/work/rich-text-review';
const source=root+'/source';
const repo='/workspace/work/rich-text-implementation/source';
const evidence='/workspace/work/rich-text-implementation/evidence';
const base='9bc493fe9c1943b8608be0969c0b2d5e4cfdd924';
const product='034685dacd76f1450317b0352411ddc4be112136';
const sha=b=>crypto.createHash('sha256').update(b).digest('hex');
const git=(...args)=>execFileSync('git',['-C',repo,...args]);
const changed=git('diff','--name-only',base,product).toString().trim().split('\n');
const files=git('ls-tree','-r','--name-only',product).toString().trim().split('\n').filter(p=>p.startsWith('src/')||p.startsWith('native/')||p==='cjpm.toml'||p==='build.cj'||changed.includes(p));
const manifest={base,product,productTree:git('rev-parse',product+'^{tree}').toString().trim(),files:[]};
for(const file of files){
 const fixed=git('show',product+':'+file);
 const actual=fs.readFileSync(path.join(source,file));
 if(!fixed.equals(actual))throw Error('review source mismatch '+file);
 manifest.files.push({path:file,sha256:sha(actual),gitBlob:git('rev-parse',product+':'+file).toString().trim(),changed:changed.includes(file)});
}
fs.writeFileSync(root+'/reviewed-sourcehashes.json',JSON.stringify(manifest,null,2)+'\n');
const names=['rich-final','rich-fixed','runtime-fixed','regress-frame-layout','regress-color-layout-pty','bundle-fixed','clean-consumer','example','scope-probe-green','scope-probe-red','scope-probe-mounted-red','archive-boundary-fixed'];
const checks=[];
for(const name of names){
 const metadata=fs.readFileSync(evidence+'/'+name+'.meta','utf8');
 const content=fs.readFileSync(evidence+'/'+name+'.log');
 const checksum=metadata.match(/([0-9a-f]{64})\s+.*\.log/)[1];
 if(sha(content)!==checksum)throw Error('log mismatch '+name);
 for(const ext of ['meta','log'])fs.copyFileSync(evidence+'/'+name+'.'+ext,root+'/raw/'+name+'.'+ext);
 const stage=metadata.match(/staged-tree=([0-9a-f]+)/)?.[1];
 const delta=stage?git('diff','--name-only',stage,product).toString().trim().split('\n').filter(Boolean):[];
 checks.push({name,sha256:checksum,exit:metadata.match(/exit=([^\n]+)/)?.[1],stagedTree:stage,changedSince:delta,scopeNote:name==='rich-final'?'Historical result superseded by rich-fixed; not reused as final evidence':name==='scope-probe-red'||name==='scope-probe-mounted-red'?'Historical probe retained with actual exit; not a final passing claim':delta.length===0?'Exact product tree':'Only renderLayout application-root cache ownership differs; root-only layout/frame/example paths retain same branch semantics. Mounted-subtree scope separately covered by scope-probe-green and runtime-fixed.'});
}
fs.writeFileSync(root+'/raw/evidence-reuse.json',JSON.stringify(checks,null,2)+'\n');
fs.writeFileSync(root+'/raw/full-product.diff',git('diff',base,product));
fs.writeFileSync(root+'/raw/pre-scope-to-final.diff',git('diff','7abe39e6be11a7218c93a97feb639d8b88af0a74',product));
const summaries=checks.map(c=>{
 const log=fs.readFileSync(root+'/raw/'+c.name+'.log','utf8');
 return {name:c.name,exit:c.exit,passLines:log.split('\n').filter(l=>/^PASS/.test(l)).length,failLines:log.split('\n').filter(l=>/^(FAIL|Error:)/.test(l))};
});
fs.writeFileSync(root+'/raw/log-summary.json',JSON.stringify(summaries,null,2)+'\n');
console.log(JSON.stringify({sourceFiles:manifest.files.length,changedFiles:changed.length,logChecks:summaries},null,2));

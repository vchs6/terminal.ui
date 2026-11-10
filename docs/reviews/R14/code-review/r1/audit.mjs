import fs from 'node:fs';
import crypto from 'node:crypto';
import {execFileSync} from 'node:child_process';
const root='/workspace/work/rich-text-review';
const repo='/workspace/work/rich-text-implementation/source';
const product='91c22f82adcd2412d9509b9872ff63450ba81af9';
const formal='cc556f4e4548c51c3d99e5a06768e61b41932d75';
const old='034685dacd76f1450317b0352411ddc4be112136';
const git=(...args)=>execFileSync('git',['-C',repo,...args]);
const sha=b=>crypto.createHash('sha256').update(b).digest('hex');
const previous=JSON.parse(fs.readFileSync(root+'/reviewed-sourcehashes.json'));
const records=[];
for(const before of previous.files){
 const bytes=git('show',product+':'+before.path);
 const local=fs.readFileSync(root+'/r1/source/'+before.path);
 if(!bytes.equals(local)) throw Error('fixed source mismatch '+before.path);
 records.push({path:before.path,sha256:sha(bytes),priorSha256:before.sha256,changed:sha(bytes)!==before.sha256});
}
const changes=records.filter(r=>r.changed);
if(changes.length!==1||changes[0].path!=='src/text/ansi_text_decoder.cj')throw Error('Unexpected product scope');
for(const p of ['tests/rich-text/README.md','tests/rich-text/src/main.cj','tests/rich-text/src/csi_utf8_first_fault.cj']){
 const frozen=git('show',formal+':'+p);
 if(!frozen.equals(git('show',product+':'+p)))throw Error('Formal test changed '+p);
 if(!frozen.equals(fs.readFileSync('/workspace/work/rich-text-regression-tests/source/'+p)))throw Error('Independent test source changed '+p);
 records.push({path:p,sha256:sha(frozen),frozenAt:formal});
}
const metadata={product,priorProduct:old,formal,tree:git('rev-parse',product+'^{tree}').toString().trim(),files:records};
fs.writeFileSync(root+'/scoped-r1-sourcehashes.json',JSON.stringify(metadata,null,2)+'\n');
const evidence='/workspace/work/rich-text-implementation/evidence/';
const logs=[];
for(const name of ['r1-red','r1-green','r1-bundle','r1-clean-consumer']){
 const meta=fs.readFileSync(evidence+name+'.meta','utf8');
 const log=fs.readFileSync(evidence+name+'.log');
 const hash=meta.match(/([a-f0-9]{64})\s+.*\.log/)[1];
 if(sha(log)!==hash)throw Error('Raw log mismatch '+name);
 for(const ext of ['meta','log']) fs.copyFileSync(evidence+name+'.'+ext,root+'/r1/raw/'+name+'.'+ext);
 const stage=meta.match(/staged-tree=([^\n]+)/)[1];
 const delta=git('diff','--name-only',stage,product).toString().trim().split('\n').filter(Boolean);
 if(name!=='r1-red'&&delta.length)throw Error('Log source mismatch '+name);
 logs.push({name,sha256:hash,exit:meta.match(/exit=([^\n]+)/)[1],stagedTree:stage,deltaToProduct:delta,passLines:log.toString().split('\n').filter(l=>l.startsWith('PASS:')).length,failedChecks:log.toString().match(/regression failures: (\d+)/)?.[1]??null});
}
for(const file of ['initial-consumer-build.exit','initial-consumer-build.log','initial-consumer-direct.exit','initial-consumer-direct.log','source-final.sha256','regression-final.sha256','commands.md']){
 fs.copyFileSync('/workspace/work/rich-text-regression-tests/raw/'+file,root+'/r1/raw/independent-red-'+file);
}
for(const file of ['formal-tests.sha256','final-artifacts.sha256','clean-consumer-source.diff','clean-product-source.diff','clean-consumer-manifest.diff'])fs.copyFileSync('/workspace/work/rich-text-implementation/round1/'+file,root+'/r1/raw/'+file);
fs.writeFileSync(root+'/r1/raw/log-audit.json',JSON.stringify(logs,null,2)+'\n');
fs.writeFileSync(root+'/r1/raw/product-fix.diff',git('diff',old,product,'--','src'));
console.log(JSON.stringify({fixedProduct:product,priorProductFiles:previous.files.length,changedProductFiles:changes.map(r=>r.path),logs},null,2));

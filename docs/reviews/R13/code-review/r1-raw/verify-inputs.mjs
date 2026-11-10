import fs from 'node:fs';
import cp from 'node:child_process';
import crypto from 'node:crypto';
const base='/workspace/work/dynamic-review';
const raw='/workspace/work/dynamic-implementation-sol/logs';
const manifest=new Map(fs.readFileSync(raw+'/r1-raw-manifest.sha256','utf8').trim().split('\n').map(l=>[l.slice(66),l.slice(0,64)]));
const paths=[...manifest.keys()].filter(p=>/\/logs\/r1-(?:final-dynamic|final-nested-probes|runtime-core|runtime-session|normal-bundle|bundle-consumer|delivered-product-source|fix\.diff|frozen-dynamic)/.test(p)||/\/probes-r1\/(?:src\/[^/]+\.cj|cjpm.toml)$/.test(p));
for(const path of paths){const digest=crypto.createHash('sha256').update(fs.readFileSync(path)).digest('hex'); if(digest!==manifest.get(path))throw Error('raw hash mismatch '+path);}
const inputHashes=paths.map(p=>manifest.get(p)+'  '+p).join('\n')+'\n';
fs.writeFileSync(base+'/r1-raw/reused-inputs.sha256',inputHashes);
for(const name of ['main.cj','ref_box.cj'])if(!fs.readFileSync(base+'/probe/src/'+name).equals(fs.readFileSync(base+'/r1-probe/src/'+name)))throw Error('reviewer probe changed');
const source=base+'/r1-source';
const head=cp.execFileSync('git',['-C',source,'rev-parse','HEAD'],{encoding:'utf8'}).trim();
if(head!=='216b2ab5f2315f4be19467b7e49f4047aec78ab9')throw Error('head mismatch');
for(const label of ['r1-final-dynamic-run','r1-final-nested-probes-run','r1-runtime-core','r1-runtime-session','r1-normal-bundle','r1-bundle-consumer-run']){
 const meta=fs.readFileSync(raw+'/'+label+'.meta','utf8');
 if(!meta.includes('exit=0\n')||!meta.includes('76a7bff748f0e2cd12e4f17e73e2db89db4a9f6cf4ce6037fb79b4b1f814717e'))throw Error('raw version/status '+label);
}
console.log('Verified '+paths.length+' raw input hashes, fixed candidate, unchanged original reviewer probe sources, and exact final aggregate in relevant success metadata.');

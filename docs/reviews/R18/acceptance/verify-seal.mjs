// Final read-only seal/source-copy verification. No runtime checks are repeated.
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import assert from 'node:assert/strict';
const base='/workspace/work/session-extension-execution',own='/workspace/work/session-extension-acceptance';
const hash=b=>crypto.createHash('sha256').update(b).digest('hex');
const expected={
 'report.md':'2a6b9433e43fc7746e7c70502228367d9621841c1b1a077106ea410c898fe34e',
 'manifest.json':'b5e58ba3406dadfe1b6f525485f0f5f2605400957572c970532e268b08aed264',
 'artifacts.sha256':'71c92113358cb154145d536bfad9f960c9b73a04c0e1cd5693e5ff05342155da'
};
for(const [p,h] of Object.entries(expected))assert.equal(hash(fs.readFileSync(base+'/'+p)),h);
const manifest=JSON.parse(fs.readFileSync(base+'/manifest.json')),curated=manifest.curatedRoot,seen=new Set();
for(const e of manifest.files){
 assert(!seen.has(e.path));seen.add(e.path);assert(!path.isAbsolute(e.path)&&!e.path.split('/').includes('..'));
 assert(!/(^|\/)(id_rsa|id_ed25519|[^/]+\.pem)$/.test(e.path),'credential filename in manifest');
 assert(!/\.(?:cjp|cjo|so|a|o|pyc)$/.test(e.path),'non-curated build artifact');
 const a=fs.readFileSync(e.source),b=fs.readFileSync(path.join(curated,e.path));
 assert.equal(a.length,e.size);assert.equal(hash(a),e.sha256,e.path+' source');assert.deepEqual(a,b,e.path+' copy');
 assert(!a.subarray(0,4).equals(Buffer.from([127,69,76,70])),'ELF retained');
}
let artifactCount=0;
for(const line of fs.readFileSync(base+'/artifacts.sha256','utf8').trim().split('\n')){
 const m=line.match(/^([0-9a-f]{64})  (.+)$/);assert(m);assert.equal(hash(fs.readFileSync(curated+'/'+m[2])),m[1],m[2]);artifactCount++;
}
for(const file of ['manifest.json','artifacts.sha256'])assert.deepEqual(fs.readFileSync(base+'/'+file),fs.readFileSync(curated+'/'+file));
function list(root,prefix=''){return fs.readdirSync(root,{withFileTypes:true}).flatMap(e=>e.isDirectory()?list(path.join(root,e.name),prefix+e.name+'/'):[prefix+e.name]);}
const copied=list(curated);assert.equal(copied.length,manifest.files.length+2);assert(copied.every(p=>seen.has(p)||['manifest.json','artifacts.sha256'].includes(p)));
const changed=[];let unchanged=0;
for(const name of ['semantic-verification.json','lifecycle-verification.json']){
 const prior=JSON.parse(fs.readFileSync(own+'/raw/'+name));for(const e of prior.inputs){const actual=hash(fs.readFileSync(e.source));if(actual===e.sha256)unchanged++;else changed.push({source:e.source,before:e.sha256,after:actual});}
}
assert(changed.every(e=>e.source===base+'/results.json'),'previously checked immutable raw/source changed');
const initial=JSON.parse(fs.readFileSync(base+'/initial/snapshot.json'));
const relativeLinks=[];
for(const file of copied.filter(p=>p.endsWith('.md'))){const text=fs.readFileSync(curated+'/'+file,'utf8');for(const match of text.matchAll(/\[[^\]]*\]\(([^)]+)\)/g)){const href=match[1];if(/^(?:[a-z]+:|\/|#)/i.test(href))continue;const target=path.resolve(curated,path.dirname(file),href.split('#')[0]);assert(fs.existsSync(target),file+' -> '+href);relativeLinks.push({file,href});}}
const lifecycle=JSON.parse(fs.readFileSync(base+'/raw/lifecycle-hosts/summary.json'));assert(Date.parse(manifest.finalizedUtc)>Date.parse(lifecycle.utcEnd));
const result={utc:new Date().toISOString(),command:'node /workspace/work/session-extension-acceptance/verify-seal.mjs',cwd:process.cwd(),expectedSeal:expected,sourceAndCopyFiles:manifest.files.length,artifactEntries:artifactCount,curatedFiles:copied.length,unchangedPriorInputs:unchanged,intentionallyUpdatedSummary:changed,relativeMarkdownLinksChecked:relativeLinks.length,initialSnapshot:initial,finalSealAfterLastHostExit:true,passed:true};
fs.writeFileSync(own+'/raw/final-seal-verification.json',JSON.stringify(result,null,2)+'\n');console.log(JSON.stringify({sourceAndCopyFiles:result.sourceAndCopyFiles,artifactEntries:artifactCount,curatedFiles:copied.length,unchangedPriorInputs:unchanged,changed,relativeMarkdownLinksChecked:relativeLinks.length,passed:true},null,2));

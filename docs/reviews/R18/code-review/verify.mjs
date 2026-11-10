import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import cp from 'node:child_process';
const root='/workspace/work/session-extension-review';
const source=root+'/source';
const original='/workspace/work/session-extension-implementation';
const raw=original+'/raw';
const sha=p=>crypto.createHash('sha256').update(fs.readFileSync(p)).digest('hex');
const result={utc:new Date().toISOString(),cwd:root,command:'node verify.mjs',checks:[],inputs:{}};
function check(ok, detail){result.checks.push({ok,detail});if(!ok)process.exitCode=1;}
function manifest(name,base){const lines=fs.readFileSync(raw+'/'+name,'utf8').trim().split('\n'); const bad=[];for(const l of lines){const m=l.match(/^([0-9a-f]{64})  (.+)$/);if(!m||!fs.existsSync(base+'/'+m[2])||sha(base+'/'+m[2])!==m[1])bad.push(l);}check(!bad.length,{manifest:name,base,count:lines.length,bad});result.inputs[raw+'/'+name]=sha(raw+'/'+name);}
manifest('product-source.sha256',source);
manifest('formal-tests.sha256',source);
manifest('contract-runtime.sha256',source);
manifest('manifests.sha256',original);
manifest('final-runtime-binaries.sha256',original+'/source');
manifest('dependency-source.sha256','/workspace/work/validation/replay-dependencies/cache');
const packageFile=original+'/source/target/cjtui-0.0.0.cjp';
result.inputs[packageFile]=sha(packageFile);
check(sha(packageFile)==='b2a5b5e19f67058adf0f4d6f6b4e130af8454e6b72f66aaa8c09c87cf6435d54','actual CJP hash');
const unpack=root+'/package-inspection';fs.mkdirSync(unpack,{recursive:true});
cp.execFileSync('tar',['-xzf',packageFile,'-C',unpack]);
manifest('product-packaged-source.sha256',unpack+'/cjtui-0.0.0');
const members=cp.execFileSync('tar',['-tzf',packageFile],{encoding:'utf8'}).trim().split('\n');
fs.writeFileSync(root+'/raw/package-members.txt',members.join('\n')+'\n');
const forbidden=members.filter(p=>/\/(tests|openspec|\.superpowers|\.git|target|node_modules)\//.test(p)||/\.(a|o|cjo|cjp)$/.test(p));
check(!forbidden.length,{packageForbiddenMembers:forbidden});
const walk=p=>fs.readdirSync(p,{withFileTypes:true}).flatMap(e=>e.isDirectory()?walk(path.join(p,e.name)):[path.join(p,e.name)]);
const types=walk(source+'/src').filter(p=>p.endsWith('.cj')).map(p=>({file:path.relative(source,p),types:[...fs.readFileSync(p,'utf8').matchAll(/^(?:public\s+|internal\s+|private\s+|protected\s+|abstract\s+|open\s+)*(class|struct|interface|enum)\s+(\w+)/gm)].map(m=>m[2])}));
check(types.every(e=>e.types.length<=1),{oneEntityPerFile:types});
const bundle=fs.readFileSync(raw+'/bundle.log','utf8');
const warnings=[...bundle.matchAll(/warning\x1b\[0m: ([A-Z.0-9]+)/g)].map(m=>m[1]);
check(warnings.length===331,{normalBundleWarnings:warnings.length,categories:Object.fromEntries([...new Set(warnings)].map(c=>[c,warnings.filter(x=>x===c).length]))});
for(const name of ['build-final','session-final','bundle','clean-consumer-build','clean-consumer-pty','native-session','runtime-core','runtime-session-final','application-lifecycle-final','colors','capabilities']){
 const exit=fs.readFileSync(raw+'/'+name+'.exit','utf8').trim();
 check(exit==='0',{reusedOriginalRun:name,exit});
 result.inputs[raw+'/'+name+'.exit']=sha(raw+'/'+name+'.exit');result.inputs[raw+'/'+name+'.log']=sha(raw+'/'+name+'.log');
}
const cases=['038-fault-set-Direct-0','039-fault-set-Direct-1','125-fault-set-TmuxPassthrough-0','126-fault-set-TmuxPassthrough-1','230-fault-set-ScreenPassthrough-0','231-fault-set-ScreenPassthrough-1'];
for(const name of cases){const dir=raw+'/session-final/'+name; const records=fs.readFileSync(dir+'/results.tsv','utf8');const wire=fs.readFileSync(dir+'/all-wire.bin');const native=fs.readFileSync(dir+'/native.tsv','utf8');const zero=name.endsWith('-0');const size=name.includes('Tmux')?17:name.includes('Screen')?11:7;
 check(zero ? wire.length===size*2 && /cleanup\.0\tRestoreHostTitle\|SentUnconfirmed/.test(records) : wire.length===size+1 && /cleanup\.0\tRestoreHostTitle\|Failed\|0\|ParserUnsynchronized/.test(records),{independentRawAssertion:name,wireBytes:wire.length,zeroFailure:zero});
 check(!native.includes('poll-after-fault'),{noPollAfterFault:name});
 check(fs.readFileSync(dir+'/before').equals(fs.readFileSync(dir+'/after')),{exactTermios:name});
 for(const f of ['results.tsv','native.tsv','wire.bin','all-wire.bin','before','after','launch.json','check.json'])result.inputs[dir+'/'+f]=sha(dir+'/'+f);
}
fs.writeFileSync(root+'/raw/independent-verification.json',JSON.stringify(result,null,2)+'\n');
console.log(JSON.stringify({utc:result.utc,checks:result.checks.length,failed:result.checks.filter(c=>!c.ok),inputHashes:Object.keys(result.inputs).length}));

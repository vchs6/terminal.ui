import fs from 'node:fs';import cp from 'node:child_process';import crypto from 'node:crypto';
import {parseResults,verifyLive} from './source/tests/session_extensions/oracle.mjs';
import {sessionCases} from './source/tests/session_extensions/cases.mjs';
const dir='/workspace/work/session-extension-review/test-supplement', repo='/workspace/work/terminal.ui';
const base='47d267fe802dcb817b4f95247eac18a4a30c2fab',head='f8b95815616c850145b647aae57e082c7915dab0';
const sha=p=>crypto.createHash('sha256').update(fs.readFileSync(p)).digest('hex');
const git=(...a)=>cp.execFileSync('git',['-C',repo,...a],{encoding:'utf8'}).trim();
const result={utc:new Date().toISOString(),command:'node verify.mjs',cwd:dir,base,head,testTree:git('rev-parse',head+':tests/session_extensions'),checks:[],inputs:{}};
const check=(ok,detail)=>{result.checks.push({ok,detail});if(!ok)process.exitCode=1;};
check(git('rev-parse',head+'^')===base,'parent is official namespace-fixed tests');
const files=git('diff','--name-only',base,head).split('\n');check(files.length===6&&files.every(p=>p.startsWith('tests/session_extensions/')),{onlySixTestFiles:files});
const summary=JSON.parse(fs.readFileSync('/workspace/work/session-safe-pop-tests/summary.json'));
for(const f of files){const p=dir+'/source/'+f;check(sha(p)===summary.file_sha256[f],{fixedFile:f});result.inputs[p]=sha(p);}
const pack=repo+'/.superpowers/sdd/tasks-implement-session-extensions/review-47d267f..f8b9581.diff';const data=fs.readFileSync(pack,'utf8');result.inputs[pack]=sha(pack);
check(data.slice(data.indexOf('diff --git'))===cp.execFileSync('git',['-C',repo,'diff','-U10',base,head],{encoding:'utf8'}),'full supplied technical diff exact -U10 match');
check(git('diff','--check',base,head)==='','git diff --check');
check(sessionCases.length===278&&sessionCases.filter(c=>c.scenario==='fault-set'&&c.offset===0).length===4,{matrix:278,affectedConfigurations:4});
const originals='/workspace/work/session-safe-pop-tests';
const manifest=new Map(fs.readFileSync(originals+'/evidence.sha256','utf8').trim().split('\n').map(l=>[l.slice(66),l.slice(0,64)]));
const walk=p=>fs.readdirSync(p,{withFileTypes:true}).flatMap(e=>e.isDirectory()?walk(p+'/'+e.name):[p+'/'+e.name]);
for(const p of walk(originals+'/raw/final-s007-selftest')){const rel=p.slice(originals.length+1);check(sha(p)===manifest.get(rel),{originalFixtureEvidence:rel});result.inputs[p]=sha(p);}
const event=JSON.parse(fs.readFileSync(originals+'/raw/final-s007-selftest/execution.json'));check(event.exit===0,'original final-s007 fixture selftest real exit0');
const controls=fs.readFileSync(originals+'/raw/final-s007-selftest/stdout','utf8');check(controls.includes('deliberate-negative-controls=39 native-selection-checks=3'),'final evidence contains 39 controls / 3 native selector probes');
for(const [n,route] of [['038-fault-set-Direct-0','Direct'],['125-fault-set-TmuxPassthrough-0','TmuxPassthrough'],['230-fault-set-ScreenPassthrough-0','ScreenPassthrough']]){
 const p='/workspace/work/session-extension-implementation/raw/session-final/'+n;const read=f=>fs.readFileSync(p+'/'+f);
 verifyLive(parseResults(read('results.tsv').toString()),read('wire.bin'),read('native.tsv').toString(),'fault-set',route,0,read('all-wire.bin'));
 check(true,{original830ObservationRecheckOnly:n,productRerun:false});
 for(const f of ['results.tsv','wire.bin','native.tsv','all-wire.bin'])result.inputs[p+'/'+f]=sha(p+'/'+f);
}
fs.writeFileSync(dir+'/raw/verification.json',JSON.stringify(result,null,2)+'\n');
console.log(JSON.stringify({utc:result.utc,checks:result.checks.length,failed:result.checks.filter(c=>!c.ok),testTree:result.testTree,productRuntimeExecuted:false}));

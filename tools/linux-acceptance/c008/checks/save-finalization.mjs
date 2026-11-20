// PASTE002-R001 only: real save/finalize hooks, file fixtures, no device/app execution.
import assert from 'node:assert/strict';
import {mkdirSync,mkdtempSync,readFileSync,writeFileSync,existsSync} from 'node:fs';
import {tmpdir} from 'node:os';
import {join} from 'node:path';
import {spawnSync} from 'node:child_process';
import {createHash} from 'node:crypto';
import {installActualSession} from '../operator/actual-session.mjs';
import {installVTSession} from '../operator/vt-session.mjs';
const sha=v=>createHash('sha256').update(v).digest('hex');
const readJSON=path=>JSON.parse(readFileSync(path));
function fixture(kind,mode,dir){
 mkdirSync(dir,{recursive:true});
 const raw=Buffer.from('PURE FILE FIXTURE INPUT'),source=Buffer.from(kind==='vt'?'PURE FILE FIXTURE SERIAL':raw);
 const sourcePath=join(dir,'original-source.raw'),sourceSnapshot=join(dir,'captured-source.raw'),rawPath=join(dir,'captured-input.raw'),evidence=join(dir,'evidence.raw');
 writeFileSync(sourcePath,source);writeFileSync(sourceSnapshot,source);writeFileSync(rawPath,raw);writeFileSync(evidence,'PURE FILE FIXTURE EVIDENCE');
 const capture={kind:kind==='vt'?'controlled-keyboard-raw':'gui-selection',source:sourcePath,sourceSnapshot,sourceSha256:sha(source),sourceBytes:source.length,rawPath,rawSha256:sha(raw),rawBytes:raw.length};
 class Session{async wait(){}}
 (kind==='vt'?installVTSession:installActualSession)(Session);
 const session=new Session();Object.assign(session,{dir,finished:true,hostClosed:mode!=='unclosed',raw:Buffer.from('RETAINED CASE STDOUT'),stderr:'RETAINED CASE STDERR',events:[{fixture:'retained input event'}],frames:[{fixture:'retained full frame'}],directExit:mode==='prior'?7:0,paste002:[{before:capture,after:capture,evidence:[{path:evidence,snapshot:evidence,sha256:sha(readFileSync(evidence))}]}]});
 let captures=0,cleanups=0;
 session.refresh=()=>{};session.cleanupResources=async()=>{cleanups++};session.bridge=r=>{assert.equal(r.op,'capture');captures++;return {fixtureCapture:true}};
 const prior=mode==='prior'?new Error('EARLIER_CASE_FAILURE'):undefined;if(prior)session.error=prior;
 if(['source','prior'].includes(mode))writeFileSync(sourcePath,'changed original source');
 if(mode==='raw')writeFileSync(rawPath,'changed captured raw');
 if(mode==='evidence')writeFileSync(evidence,'changed evidence');
 return {session,prior,counts:()=>({captures,cleanups})};
}
function artifacts(dir,mode){
 const result=readJSON(join(dir,'result.json'));
 assert.equal(readFileSync(join(dir,'stdout.raw'),'utf8'),'RETAINED CASE STDOUT');
 assert.equal(readFileSync(join(dir,'stderr.txt'),'utf8'),'RETAINED CASE STDERR');
 assert.equal(readJSON(join(dir,'events.json'))[0].fixture,'retained input event');
 assert.equal(readJSON(join(dir,'frames.json'))[0].fixture,'retained full frame');
 assert.equal(readJSON(join(dir,'captures.json'))[0].status,'CAPTURED');
 assert.equal(readJSON(join(dir,'cleanup.json')).forced,false);
 assert.equal(result.directExit,mode==='prior'?7:0,'true app direct exit stays separate');
 assert.equal(result.finalAcceptance,false);
 if(mode==='good'){assert.equal(result.status,'ACTUAL_ATTEMPT');assert.equal(result.paste002FinalizationError,null);assert(existsSync(join(dir,'paste002-finalization.json')))}
 else {assert.equal(result.status,'FAILED_TRANSPORT');assert.match(result.paste002FinalizationError,/INSUFFICIENT_EVIDENCE PASTE002/);assert.match(result.error,mode==='prior'?/EARLIER_CASE_FAILURE/:/INSUFFICIENT_EVIDENCE PASTE002/);assert(!existsSync(join(dir,'paste002-finalization.json')))}
 return result;
}
if(process.argv[2]==='--runner-case'){
 const [kind,mode,dir]=process.argv.slice(3),{session}=fixture(kind,mode,dir);
 // Same await/finally shape as frozen cases, followed by a passing runner sentinel.
 try{}finally{await session.save()}
 writeFileSync(join(dir,'RUNNER_PASSED'),'passed after awaited case');
}else{
 const root=mkdtempSync(join(process.env.C008_PASTE002_CHECK_ROOT??tmpdir(),'paste002-r001-'));let checks=0;
 for(const kind of ['xterm','vt'])for(const mode of ['source','good','raw','evidence','unclosed','prior']){
  const dir=join(root,kind+'-'+mode),{session,prior,counts}=fixture(kind,mode,dir);
  if(mode==='good')await session.save();else await assert.rejects(session.save(),e=>{if(prior)assert.equal(e,prior,'earlier Session error remains the primary rejection');else assert.match(e.message,/INSUFFICIENT_EVIDENCE PASTE002/);return true});
  assert.deepEqual(counts(),{captures:1,cleanups:1});artifacts(dir,mode);checks++;
 }
 for(const kind of ['xterm','vt']){
  // A prior test-body failure remains unchanged when finalization succeeds.
  const dir=join(root,kind+'-prior-body'),{session}=fixture(kind,'good',dir),prior=new Error('ORIGINAL_BODY_ASSERTION');
  await assert.rejects((async()=>{try{throw prior}finally{await session.save()}})(),e=>e===prior);artifacts(dir,'good');checks++;
  for(const mode of ['good','source','prior']){
   const dir=join(root,kind+'-runner-'+mode),argv=[new URL(import.meta.url).pathname,'--runner-case',kind,mode,dir];
   const result=spawnSync(process.execPath,argv,{encoding:'utf8'});writeFileSync(join(dir,'runner.stdout'),result.stdout);writeFileSync(join(dir,'runner.stderr'),result.stderr);
   writeFileSync(join(dir,'runner-result.json'),JSON.stringify({argv,status:result.status,signal:result.signal})+'\n');
   assert.equal(result.status===0,mode==='good','awaited runner process must reject/nonzero on required finalization failure');
   assert.equal(existsSync(join(dir,'RUNNER_PASSED')),mode==='good');artifacts(dir,mode);checks++;
  }
 }
 console.log(`PASS PASTE002-R001: ${checks} focused save/case/runner checks; cleanup, raw/failure/result artifacts and direct exit retained; required finalization rejects/nonzero. File fixtures only.`);
}

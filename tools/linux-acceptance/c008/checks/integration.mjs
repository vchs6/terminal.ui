import assert from 'node:assert/strict';
import {mkdtempSync,mkdirSync,readFileSync,writeFileSync,appendFileSync,readdirSync} from 'node:fs';
import {tmpdir} from 'node:os';
import {join} from 'node:path';
import {spawnSync} from 'node:child_process';
import {createHash} from 'node:crypto';
import {installActualSession} from '../operator/actual-session.mjs';
import {installVTSession} from '../operator/vt-session.mjs';
import {sendPaste002,finalizePaste002} from '../operator/paste002_support.mjs';
import {preparePolicy,verifyReceivedPacket,SOURCE_HEX,CR_PAYLOAD_HEX,OPEN_HEX,CLOSE_HEX} from '/workspace/work/linux-final-host-test-contract/paste-revision/packet-policy.mjs';
const sha=b=>createHash('sha256').update(b).digest('hex');
const cr=OPEN_HEX+CR_PAYLOAD_HEX+CLOSE_HEX,lf=OPEN_HEX+SOURCE_HEX+CLOSE_HEX;
const input=Buffer.from('0909090901'+lf,'hex');
const fixture=Buffer.from('PURE FILE FIXTURE ONLY: no actual owner, modes, route or host acceptance');
let checks=0;
function setup(kind='xterm',wire){
 const vt=kind==='vt',route=vt?'controlled-keyboard-raw':'gui-selection',dir=mkdtempSync(join(process.env.C008_PASTE002_CHECK_ROOT??tmpdir(),'paste002-pure-'));
 mkdirSync(join(dir,vt?'vt-run':'transport'));
 writeFileSync(join(dir,vt?'vt-run/vt-serial.log':'transport/input.raw'),'');
 const evidence=join(dir,'fixture-evidence.raw');writeFileSync(evidence,fixture);
 const policyId=vt?'DIRECT_VT_RAW_LF':kind==='vte'?'VTE0801_FIXED_NL_TO_CR':'XTERM398_DEFAULT_NL_TO_CR';
 const declaration={schema:'C008-PASTE002-v1',policyId,owner:{engine:vt?'LinuxVT':kind==='vte'?'VTE':'XTerm',version:vt?'fixture-kernel':kind==='vte'?'0.80.1':'398'},route:{kind:route,chain:['PURE FIXTURE '+kind+' route','PURE FIXTURE actual app tty']},modes:{bracketedPaste:'set',pasteQuote:vt?'not-applicable':kind==='vte'?'fixed-reset':'reset',literalNewline:vt?'not-applicable':kind==='vte'?'fixed-reset':'reset',basis:kind==='vte'?'fixed-official-source':'verified-default-config'},evidence:['owner-config','newline-policy','mode-state','raw-route'].map(kind=>({kind,path:evidence,sha256:sha(fixture)}))};
 const declarationPath=join(dir,'declaration.json');writeFileSync(declarationPath,JSON.stringify(declaration));
 class Session{constructor(){this.dir=dir;this.events=[];this.actualTty='/dev/pts/FIXTURE';this.hostClosed=true}async wait(){}}
 (vt?installVTSession:installActualSession)(Session);
 const session=new Session();let actions=0,before=0;
 session.bridge=r=>{
  if(r.op==='input'){
   actions++;
   const prepared=readdirSync(dir).filter(v=>v.startsWith('paste002-')&&v!=='paste002-originals');
   assert.equal(prepared.length,1,'pre-action owner persisted preparation before Python input');
   assert.equal(JSON.parse(readFileSync(join(dir,prepared[0],'prepared.json'))).status,'PREPARED_BEFORE_ACTION');
  }
  if(r.op==='paste002-before')before++;
  const env={...process.env,C008_HOST_KIND:kind};if(wire!==undefined)env.MOCK_PACKET_HEX=wire;
  const child=spawnSync('python3',[new URL('./mock_bridge.py',import.meta.url).pathname,route,JSON.stringify({...r,dir})],{env,encoding:'utf8'});
  assert.equal(child.status,0,child.stderr);return JSON.parse(child.stdout);
 };
 return {session,dir,route,declaration,declarationPath,evidence,count:()=>({actions,before})};
}
function use(s,fn){const old=process.env.C008_PASTE002_DECLARATION;process.env.C008_PASTE002_DECLARATION=s.declarationPath;try{return fn()}finally{if(old===undefined)delete process.env.C008_PASTE002_DECLARATION;else process.env.C008_PASTE002_DECLARATION=old}}
for(const kind of ['xterm','vte','tmux','screen','ssh','vt']){
 const s=setup(kind);use(s,()=>s.session.send(input,'multiline fixture'));
 assert.equal(s.count().actions,1);assert.equal(s.session.events.length,1);
 const record=s.session.paste002[0],proof=JSON.parse(readFileSync(join(record.folder,'verified.json')));
 assert.equal(proof.receivedPacketHex,kind==='vt'?lf:cr);
 assert.equal(proof.sourceHex,SOURCE_HEX);assert.equal(proof.finalAcceptance,false);
 assert.equal(proof.prefixHex,'0909090901','navigation provenance preserved');
 if(kind!=='vt')assert.equal(readFileSync(join(s.dir,'mock-clipboard-cleanup.log'),'utf8'),'terminate\nwait\n','native owner always cleaned up');
 const source=record.after.source;appendFileSync(source,kind==='vt'?'POST_FIXTURE_FINAL_ORIGINAL\n':'suffix');
 finalizePaste002(s.session);const final=JSON.parse(readFileSync(join(s.dir,'paste002-finalization.json')));
 assert.equal(final.proofs.length,2);assert.equal(final.proofs[1].finalSourceSha256,sha(readFileSync(source)));
 assert.notEqual(final.proofs[1].finalSourceSha256,record.after.sourceSha256,'final appended original has fresh hash');checks++;
}
for(const [name,wire,pattern] of [
 ['wrong GUI LF',lf,/FAILED_PASTE_WIRE/],['missing opener',CR_PAYLOAD_HEX+CLOSE_HEX,/FAILED_PASTE_WIRE/],
 ['missing closer',OPEN_HEX+CR_PAYLOAD_HEX,/FAILED_PASTE_WIRE/],['wrong Unicode',cr.replace('e4b8ad','e4b8ae'),/FAILED_PASTE_WIRE/],['extra packet',cr+cr,/FAILED_PASTE_WIRE/]]){
 const s=setup('xterm',wire);use(s,()=>assert.throws(()=>s.session.send(input,name),pattern));
 assert.equal(s.count().actions,1);assert.equal(s.session.paste002[0].after.rawSha256,sha(readFileSync(s.session.paste002[0].after.rawPath)));
 assert(JSON.parse(readFileSync(join(s.session.paste002[0].folder,'failed.json'))).error.match(pattern));checks++;
}
for(const wire of ['7f'+cr,cr+'01']){
 const s=setup('xterm',wire);use(s,()=>assert.throws(()=>s.session.send(input,'unlogged surrounding input'),/INSUFFICIENT_EVIDENCE.*unlogged prefix\/suffix/));checks++;
}
{
 const s=setup('vt',cr);use(s,()=>assert.throws(()=>s.session.send(input,'wrong VT CR'),/FAILED_PASTE_WIRE/));checks++;
}
for(const mutate of [d=>d.policyId='unsupported',d=>d.owner.version='unknown',d=>d.owner.engine='wrong',d=>d.modes.literalNewline='set',d=>d.evidence.pop(),d=>d.route.kind='wrong']){
 const s=setup();mutate(s.declaration);writeFileSync(s.declarationPath,JSON.stringify(s.declaration));
 use(s,()=>assert.throws(()=>s.session.send(input,'unsupported facts'),/INSUFFICIENT_EVIDENCE/));assert.equal(s.count().actions,0);checks++;
}
for(const inject of ['chronology','stale-offset','changed-raw','changed-evidence']){
 const s=setup(),bridge=s.session.bridge;
 s.session.bridge=r=>{const v=bridge(r);if(r.op==='input'){
  if(inject==='chronology')v.paste002.after.capturedUTC='1970-01-01T00:00:00.000Z';
  if(inject==='stale-offset')v.paste002.beforeOffset=v.paste002.afterOffset;
  if(inject==='changed-raw')appendFileSync(v.paste002.after.rawPath,'changed');
  if(inject==='changed-evidence')appendFileSync(s.evidence,'changed');
 }return v};
 use(s,()=>assert.throws(()=>s.session.send(input,inject),/INSUFFICIENT_EVIDENCE/));assert(s.session.error);checks++;
}
{
 const s=setup(),bridge=s.session.bridge;writeFileSync(join(s.dir,'transport/input.raw'),'prior');
 s.session.bridge=r=>{if(r.op==='input')writeFileSync(join(s.dir,'transport/input.raw'),'rewritten');return bridge(r)};
 use(s,()=>assert.throws(()=>s.session.send(input,'source rewrite during input'),/source prefix changed/));
 assert.equal(readFileSync(join(s.dir,'mock-clipboard-cleanup.log'),'utf8'),'terminate\nwait\n','native selection owner cleanup survives capture error');checks++;
}
{
 const s=setup();const prior=process.env.C008_PASTE002_DECLARATION;delete process.env.C008_PASTE002_DECLARATION;
 assert.throws(()=>s.session.send(input,'absent facts'),/INSUFFICIENT_EVIDENCE/);assert.deepEqual(s.count(),{actions:0,before:0});
 if(prior!==undefined)process.env.C008_PASTE002_DECLARATION=prior;checks++;
}
{
 const s=setup();use(s,()=>assert.throws(()=>s.session.send(Buffer.from(input.toString('hex').replace('790a','790d0a'),'hex'),'old CRLF'),/INSUFFICIENT_EVIDENCE/));assert.equal(s.count().actions,0);checks++;
}
for(const target of ['raw','original','evidence','not-complete']){
 const s=setup();use(s,()=>s.session.send(input,'mutation fixture'));const r=s.session.paste002[0];
 if(target==='raw')appendFileSync(r.after.rawPath,'mutation');
 if(target==='original')writeFileSync(r.after.source,'changed original');
 if(target==='evidence')appendFileSync(s.evidence,'mutation');
 if(target==='not-complete')s.session.hostClosed=false;
 assert.throws(()=>finalizePaste002(s.session),/INSUFFICIENT_EVIDENCE/);checks++;
}
// Existing ordinary send behavior stays a single ordinary bridge invocation with no policy reads.
for(const install of [installActualSession,installVTSession]){
 class Session{constructor(){this.events=[]}async wait(){}}
 install(Session);const s=new Session(),calls=[];s.bridge=r=>{calls.push(r);return {ordinary:true}};
 for(const value of ['\x01','\x1b[21~','\x1b[200~Parse\x1b[201~'])s.send(value,'ordinary');
 assert.equal(calls.length,3);assert(calls.every(v=>v.op==='input'&&!v.paste002));assert.equal(s.events.length,3);checks++;
}
// Both amended save hooks retain capture/resource cleanup and report new evidence failures.
for(const kind of ['xterm','vt'])for(const corrupt of [false,true]){
 const s=setup(kind);use(s,()=>s.session.send(input,'save hook fixture'));
 if(corrupt)writeFileSync(s.session.paste002[0].after.source,'changed final original');
 Object.assign(s.session,{finished:true,hostClosed:true,raw:Buffer.alloc(0),stderr:'',frames:[],directExit:0});
 let cleanups=0,captures=0;
 s.session.refresh=()=>{};s.session.cleanupResources=async()=>{cleanups++};s.session.bridge=r=>{assert.equal(r.op,'capture');captures++;return {fixtureImage:true}};
 if(corrupt)await assert.rejects(s.session.save(),/INSUFFICIENT_EVIDENCE/);else await s.session.save();
 const result=JSON.parse(readFileSync(join(s.dir,'result.json')));
 assert.equal(captures,1);assert.equal(cleanups,1);assert.equal(result.status,corrupt?'FAILED_TRANSPORT':'ACTUAL_ATTEMPT');
 assert.equal(result.finalAcceptance,false);assert.equal(result.directExit,0);
 for(const artifact of ['stdout.raw','stderr.txt','events.json','frames.json','captures.json','cleanup.json'])readFileSync(join(s.dir,artifact));
 if(corrupt){assert.match(result.error,/INSUFFICIENT_EVIDENCE/);assert.match(result.paste002FinalizationError,/INSUFFICIENT_EVIDENCE/)}checks++;
}
// Reuse the independent fixed 15 vectors without executing its artifact-writing generator.
const vectors=JSON.parse(readFileSync('/workspace/work/linux-final-host-test-contract/paste-revision/vectors.json')).vectors;
for(const v of vectors){const receipt=preparePolicy(v.declaration,()=>Buffer.from('PURE FIXTURE: declared route/config/modes before input; not actual host evidence.'));
 if(v.expected==='match')assert.equal(verifyReceivedPacket(receipt,v.sourceHex,Buffer.from(v.rawHex,'hex'),v.observation).status,'EXACT_RECEIVED_PACKET_MATCH');
 else assert.throws(()=>verifyReceivedPacket(receipt,v.sourceHex,Buffer.from(v.rawHex,'hex'),v.observation),new RegExp(v.expected));}
assert.throws(()=>verifyReceivedPacket({},SOURCE_HEX,Buffer.from(cr,'hex'),{}),/INSUFFICIENT_EVIDENCE/);
console.log(`PASS ${checks} integration checks + 15 frozen packet vectors; real Python bridges with file-only device mocks; no actual host or network execution.`);

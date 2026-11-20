// Genuine guest tty1, admitted public argv/files, immutable finalized evidence.
import assert from 'node:assert/strict';
import {spawn} from 'node:child_process';
import {createHash} from 'node:crypto';
import {existsSync,readFileSync} from 'node:fs';
import {mkdir,writeFile} from 'node:fs/promises';
import {join,resolve} from 'node:path';
import {launchPlan} from './vt_launch_plan.mjs';
import {boundedWait,observeChild,cleanupOwned,helper,sealLifecycle,captureResult,verifyFinalizedOriginals} from './session_support.mjs';
import {sendPaste002,finalizePaste002} from './paste002_support.mjs';
export function installVTSession(Session){
 const originalWait=Session.prototype.wait;
 Session.prototype.wait=async function(...args){const rows=await originalWait.apply(this,args);captureResult(this,{},true,args[1]);return rows};
 Session.prototype.bridge=function(r){return JSON.parse(helper('./vt-transport.py',[JSON.stringify({...r,dir:this.dir})]))};
 Session.prototype.syncFixture=function(){if(!this.plan?.fixture)return;const data=readFileSync(this.plan.fixture),sha=createHash('sha256').update(data).digest('hex');if(sha===this.fixtureSha)return;
  const actual=this.bridge({op:'fixture',hex:data.toString('hex')});assert.equal(actual.sha256,sha);this.fixtureSha=sha;this.events.push({utc:new Date().toISOString(),fixture:this.plan.fixture,actual})};
 Session.prototype.refresh=function(){const value=this.bridge({op:'wire'}),wire=Buffer.from(value.wireBase64,'base64');if(wire.length>this.raw.length){this.view.feed(wire.subarray(this.raw.length));this.raw=wire}
  if(value.directExit!==null){this.directExit=value.directExit;this.keyboardRestored=value.keyboardRestored;this.finished=true}};
 Session.prototype.start=async function(){
  assert.equal(process.env.C008_ROOT_ACTUAL_GO,'1');assert.equal(this.w,80);assert.equal(this.h,25);
  const known=[process.env.C008_VT_SHOWCASE_ELF,process.env.C008_VT_COMPOSITION_ELF].filter(Boolean).some(p=>resolve(p)===resolve(this.binary));
  this.plan=launchPlan(this.binary,this.dir,process.env,!known&&existsSync(this.binary)?readFileSync(this.binary,'utf8'):null);
  await mkdir(this.dir,{recursive:true});
  const child=spawn('bash',[new URL('./launch-host.sh',import.meta.url).pathname,'vt'],{detached:true,env:{...process.env,VT_RUN_DIR:join(this.dir,'vt-run'),VT_SCENE:this.plan.scene},stdio:['ignore','pipe','pipe']});observeChild(this,child);
  child.stdout.on('data',b=>{this.stderr+='qemu stdout: '+b});child.stderr.on('data',b=>{this.stderr+=b});
  this.syncFixture();this.bridge({op:'identify'});
  this.pump=setInterval(()=>{try{this.refresh()}catch(e){this.error??=e}},60);
 };
 Session.prototype.send=function(bytes,label){this.syncFixture();const actual=sendPaste002(this,bytes,label,'controlled-keyboard-raw')??this.bridge({op:'input',hex:Buffer.from(bytes).toString('hex')});this.events.push({utc:new Date().toISOString(),label,hex:Buffer.from(bytes).toString('hex'),actual})};
 Session.prototype.resize=async function(w,h){this.bridge({op:'resize',cols:w,rows:h});return this.view.rows()};
 Session.prototype.stop=async function(key='\x1b[21~'){
  this.send(key,'ordinary public quit');assert(await boundedWait(()=>{if(this.error)throw this.error;return this.finished},30000),'VT app completion timeout');
  assert(await boundedWait(()=>this.hostClosed,30000),'VT recorder shutdown timeout');this.refresh();if(this.error)throw this.error;
  await sealLifecycle(this,'vt',join(this.dir,'vt-run'));this.view.finish();assert.equal(this.directExit,0);assert(this.keyboardRestored);
  assert(this.raw.includes(Buffer.from('\x1b[?2004h'))&&this.raw.includes(Buffer.from('\x1b[?2004l')),'bracketed-paste enter/restore');
 };
 Session.prototype.forceOwned=async function(){this.bridge({op:'stop'})};
 Session.prototype.save=async function(){
  await mkdir(this.dir,{recursive:true});this.failureFinalization=!this.finished;
  try{captureResult(this,{},!(this.finished&&this.hostClosed),'final or failure checkpoint')}catch(e){this.error??=e}
  this.cleanup=await cleanupOwned(this,async()=>{if(!this.finished){try{this.send('\x1b[21~','failure cleanup ordinary quit')}catch{this.bridge({op:'stop'})}}});
  clearInterval(this.pump);try{this.refresh()}catch(e){this.error??=e}
  try{verifyFinalizedOriginals(this.dir)}catch(e){this.error??=e}
  let paste002FinalizationError;try{finalizePaste002(this)}catch(e){paste002FinalizationError=e;this.error??=e}
  await writeFile(join(this.dir,'stdout.raw'),this.raw);await writeFile(join(this.dir,'stderr.txt'),this.stderr);
  for(const [name,data]of [['events',this.events],['frames',this.frames],['captures',this.captures??[]],['cleanup',this.cleanup]])await writeFile(join(this.dir,name+'.json'),JSON.stringify(data,null,2)+'\n');
  await writeFile(join(this.dir,'result.json'),JSON.stringify({status:this.error?'FAILED_TRANSPORT':this.failureFinalization?'FAILED_CASE_FINALIZATION':'ACTUAL_ATTEMPT',directExit:this.directExit??null,error:this.error?.message??null,paste002FinalizationError:paste002FinalizationError?.message??null,cleanup:this.cleanup,captures:this.captures,publicPlan:this.plan,finalAcceptance:false},null,2)+'\n');
  if(paste002FinalizationError)throw this.error;
 };
}

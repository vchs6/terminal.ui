// Actual-host transport only; independent binding owns all expected assertions.
import assert from 'node:assert/strict';
import {spawn} from 'node:child_process';
import {mkdir,readFile,writeFile} from 'node:fs/promises';
import {join} from 'node:path';
import {boundedWait,observeChild,cleanupOwned,helper,sealLifecycle,captureResult,verifyFinalizedOriginals} from './session_support.mjs';
import {sendPaste002,finalizePaste002} from './paste002_support.mjs';
const read=async p=>{try{return await readFile(p)}catch(e){if(e.code==='ENOENT')return Buffer.alloc(0);throw e}};
export function installActualSession(Session){
 const frozenWait=Session.prototype.wait;
 Session.prototype.wait=async function(...args){const rows=await frozenWait.apply(this,args);captureResult(this,{tty:this.actualTty},true,args[1]);return rows};
 Session.prototype.bridge=function(r){return JSON.parse(helper('./x11-transport.py',[JSON.stringify({...r,dir:this.dir})]))};
 Session.prototype.refresh=async function(){
  if(!this.transport)return;const raw=await read(join(this.transport,'ansi.raw'));
  if(raw.length>this.raw.length){this.view.feed(raw.subarray(this.raw.length));this.raw=raw}
  const s=(await read(join(this.transport,'inner-state.txt'))).toString(),m=s.match(/^exit_status=(\d+)$/m);
  if(m){this.directExit=Number(m[1]);this.finished=true}
 };
 Session.prototype.start=async function(){
  assert.equal(process.env.C008_ROOT_ACTUAL_GO,'1');for(const k of ['C008_147_ADMISSION','C008_PROVENANCE','C008_SOURCE','C008_HOST_KIND','C008_HOST_ID'])assert(process.env[k],k);
  assert.equal(process.env.C008_DISPLAY_OWNED,'1');if(process.env.C008_HOST_KIND==='ssh')assert(process.env.C008_DIMENSIONS_READER);
  await mkdir(this.dir,{recursive:true});this.transport=join(this.dir,'transport');
  const child=spawn('bash',[new URL('./launch-host.sh',import.meta.url).pathname,process.env.C008_HOST_KIND],{detached:true,env:{...process.env,C008_BINARY:this.binary,C008_OUT:this.transport,C008_GEOMETRY:`${this.w}x${this.h}`},stdio:['ignore','pipe','pipe']});observeChild(this,child);
  child.stdout.on('data',b=>{this.stderr+='host stdout: '+b});child.stderr.on('data',b=>{this.stderr+=b});
  this.pump=setInterval(()=>{if(this.pumping)return;this.pumping=true;this.refresh().catch(e=>{this.error??=e}).finally(()=>{this.pumping=false})},15);
  assert(await boundedWait(async()=>{if(this.error)throw this.error;const s=(await read(join(this.transport,'inner-state.txt'))).toString(),m=s.match(/^tty=(.+)$/m);if(m)this.actualTty=m[1];return !!m},20000),'actual tty readiness timeout');
  this.bridge({op:'identify',tty:this.actualTty});
 };
 Session.prototype.send=function(bytes,label){const actual=sendPaste002(this,bytes,label,'gui-selection')??this.bridge({op:'input',hex:Buffer.from(bytes).toString('hex'),tty:this.actualTty});this.events.push({utc:new Date().toISOString(),label,hex:Buffer.from(bytes).toString('hex'),actual})};
 Session.prototype.resize=async function(w,h){this.view.screen.beginResize(w,h);const readback=this.bridge({op:'resize',cols:w,rows:h,tty:this.actualTty});this.events.push({utc:new Date().toISOString(),resize:[w,h],readback});
  assert(await boundedWait(()=>{if(this.error)throw this.error;return this.view.screen.targetComplete(w,h)},20000),'actual host repaint timeout');
  const rows=this.view.screen.finishResize(w,h);this.w=w;this.h=h;this.frames.push({label:`resize ${w}x${h}`,rows});return rows};
 Session.prototype.stop=async function(key='\x1b[21~'){
  this.send(key,'ordinary quit');assert(await boundedWait(()=>{if(this.error)throw this.error;return this.finished},20000),'actual app exit timeout');
  assert(await boundedWait(()=>this.hostClosed,20000),'recorder completion timeout');await this.refresh();if(this.error)throw this.error;
  await sealLifecycle(this,'pty',this.transport);this.view.finish();assert.equal(this.directExit,0);
  const state=(await read(join(this.transport,'inner-state.txt'))).toString(),before=state.match(/^ready_termios=(.*)$/m)?.[1];assert(before);assert.equal(state.match(/^exit_termios=(.*)$/m)?.[1],before);
  assert(this.raw.includes(Buffer.from('\x1b[?2004h'))&&this.raw.includes(Buffer.from('\x1b[?2004l')),'bracketed-paste enter/restore');
 };
 Session.prototype.cleanupResources=async function(){helper('./cleanup-resources.py',[])};
 Session.prototype.forceOwned=async function(){helper('./owned-process.py',['terminate',join(this.transport,'app-identity.json')])};
 Session.prototype.save=async function(){
  await mkdir(this.dir,{recursive:true});this.failureFinalization=!this.finished;
  const optional=this.finished&&this.hostClosed;try{captureResult(this,{tty:this.actualTty},!optional,'final or failure checkpoint')}catch(e){this.error??=e}
  this.cleanup=await cleanupOwned(this,async()=>{if(!this.finished&&this.actualTty)this.send('\x1b[21~','failure cleanup ordinary quit');});
  clearInterval(this.pump);await boundedWait(()=>!this.pumping,2000);try{await this.refresh()}catch(e){this.error??=e}
  try{verifyFinalizedOriginals(this.dir)}catch(e){this.error??=e}
  let paste002FinalizationError;try{finalizePaste002(this)}catch(e){paste002FinalizationError=e;this.error??=e}
  await writeFile(join(this.dir,'stdout.raw'),this.raw);await writeFile(join(this.dir,'stderr.txt'),this.stderr);
  for(const [name,data]of [['events',this.events],['frames',this.frames],['captures',this.captures??[]],['cleanup',this.cleanup]])await writeFile(join(this.dir,name+'.json'),JSON.stringify(data,null,2)+'\n');
  await writeFile(join(this.dir,'result.json'),JSON.stringify({status:this.error?'FAILED_TRANSPORT':this.failureFinalization?'FAILED_CASE_FINALIZATION':'ACTUAL_ATTEMPT',directExit:this.directExit??null,error:this.error?.message??null,paste002FinalizationError:paste002FinalizationError?.message??null,cleanup:this.cleanup,captures:this.captures,finalAcceptance:false},null,2)+'\n');
  if(paste002FinalizationError)throw this.error;
 };
}

import {spawnSync} from 'node:child_process';
import {readFileSync,existsSync} from 'node:fs';
import {createHash} from 'node:crypto';
import {join} from 'node:path';
const delay=ms=>new Promise(r=>setTimeout(r,ms));
export async function boundedWait(predicate,ms,{now=Date.now,pause=delay}={}){const end=now()+ms;while(now()<end){if(await predicate())return true;await pause(20)}return !!await predicate()}
export function observeChild(session,child){
 session.child=child;session.hostClosed=false;
 child.on('error',e=>{session.error??=e;session.hostClosed=true});
 child.on('close',(code,signal)=>{session.code=code;session.signal=signal;session.hostClosed=true;
  Promise.resolve().then(()=>session.refresh?.()).then(()=>{if(!session.cleanupInProgress&&(!session.finished||code!==0||signal))session.error??=new Error(`FAILED_TRANSPORT premature/abnormal owned host death code=${code} signal=${signal}`)}).catch(e=>{session.error??=e});
 });
}
export async function cleanupOwned(session,grace,{signal=(pid,sig)=>process.kill(pid,sig),wait=boundedWait}={}){
 const result={ownedPid:session.child?.pid??null,attempts:[],forced:false,reaped:!!session.hostClosed};session.cleanupInProgress=true;
 if(!session.child||session.hostClosed){try{await session.cleanupResources?.()}catch(e){result.resourceError=e.message}return result;}
 try{await grace();result.attempts.push('graceful-request')}catch(e){result.attempts.push('grace-error:'+e.message)}
 if(!await wait(()=>session.hostClosed,15000)){
  result.forced=true;
  try{await session.forceOwned?.();result.attempts.push('owned-resource-termination');await wait(()=>session.hostClosed,3000)}catch(e){result.attempts.push('owned-resource-error:'+e.message)}
  for(const [sig,ms]of [['SIGTERM',3000],['SIGKILL',2000]]){
   if(session.hostClosed)break;
   try{signal(-session.child.pid,sig);result.attempts.push('owned-process-group:'+sig)}catch(e){if(e.code!=='ESRCH')result.attempts.push(e.message)}
   if(await wait(()=>session.hostClosed,ms))break;
  }
 }
 try{await session.cleanupResources?.()}catch(e){result.resourceError=e.message}
 result.reaped=!!session.hostClosed;
 if(!result.reaped){session.child.stdout?.destroy();session.child.stderr?.destroy();session.child.unref?.();result.error='owned child did not reap within bounded cleanup'}
 return result;
}
export function helper(name,args,env=process.env){
 const r=spawnSync('python3',[new URL(name,import.meta.url).pathname,...args],{env,encoding:'utf8',timeout:35000,maxBuffer:16*1024*1024});
 if(r.error||r.status!==0)throw new Error(`FAILED_TRANSPORT ${name}: ${r.error?.message??r.stderr??r.stdout}`);return r.stdout;
}
export async function sealLifecycle(session,kind,raw,env=process.env){
 if(!session.hostClosed)throw Error('INSUFFICIENT_EVIDENCE recorder/tracer not complete');
 helper('./materialize-lifecycle.py',[kind,session.dir,raw],{...env,C008_BINARY:session.binary,C008_CAPTURE_FINALIZED:'1'});
}
export function captureResult(session,request,required,label){
 session.captures??=[];let result;
 try{result={...session.bridge({...request,op:'capture'}),checkpoint:label,required,utc:new Date().toISOString(),status:'CAPTURED'}}
 catch(e){result={checkpoint:label,required,utc:new Date().toISOString(),status:required?'INSUFFICIENT_EVIDENCE':'POST_EXIT_WINDOW_UNAVAILABLE',error:e.message}}
 session.captures.push(result);
 if(required&&result.status!=='CAPTURED'){session.error??=new Error('INSUFFICIENT_EVIDENCE required original image: '+label);throw session.error}
 return result;
}

export function verifyFinalizedOriginals(dir){
 const p=join(dir,'lifecycle-finalization.json');if(!existsSync(p))return;
 const m=JSON.parse(readFileSync(p));for(const row of m.originals){for(const path of [row.original,row.path]){
  if(createHash('sha256').update(readFileSync(path)).digest('hex')!==row.sha256)throw Error('FAILED_TRANSPORT finalized original changed: '+path);
 }}
}

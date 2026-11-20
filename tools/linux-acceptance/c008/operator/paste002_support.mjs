// Persistent Node ownership of the independently reviewed opaque PASTE002 receipt.
import assert from 'node:assert/strict';
import {readFileSync,writeFileSync,mkdirSync,existsSync} from 'node:fs';
import {createHash,randomUUID} from 'node:crypto';
import {join} from 'node:path';
import {preparePolicy,verifyReceivedPacket,SOURCE_HEX,OPEN_HEX,CLOSE_HEX} from '/workspace/work/linux-final-host-test-contract/paste-revision/packet-policy.mjs';
const policyPath='/workspace/work/linux-final-host-test-contract/paste-revision/packet-policy.mjs';
const policySha='44dfdd40c34ddcf92ebd0221fbb8f7d8f825cb6df87b2223793e4553dae2290c';
const sha=bytes=>createHash('sha256').update(bytes).digest('hex');
const demand=(ok,why)=>assert(ok,'INSUFFICIENT_EVIDENCE PASTE002 '+why);
const json=(path,value)=>writeFileSync(path,JSON.stringify(value,null,2)+'\n',{flag:'wx'});
const readOriginal=path=>{try{return readFileSync(path)}catch(error){throw new Error('INSUFFICIENT_EVIDENCE PASTE002 cannot read original '+path+': '+error.message,{cause:error})}};
const bytesAt=(path,expected)=>{const bytes=readOriginal(path);demand(sha(bytes)===expected,'original hash changed '+path);return bytes};
function rawCapture(value,kind){
 demand(value?.kind===kind,'capture route');
 const source=bytesAt(value.sourceSnapshot,value.sourceSha256),raw=bytesAt(value.rawPath,value.rawSha256);
 demand(source.length===value.sourceBytes&&raw.length===value.rawBytes,'capture lengths');
 if(kind==='gui-selection')demand(source.equals(raw),'GUI endpoint source identity');
 return {raw,source};
}
export function sendPaste002(session,bytes,label,kind,env=process.env){
 try{return preparedSend(session,bytes,label,kind,env)}catch(error){session.error??=error;throw error}
}
function preparedSend(session,bytes,label,kind,env){
 const input=Buffer.from(bytes),open=Buffer.from(OPEN_HEX,'hex'),close=Buffer.from(CLOSE_HEX,'hex');
 const start=input.indexOf(open);
 if(start<0)return null;
 const end=input.indexOf(close,start+open.length),source=input.subarray(start+open.length,end);
 // All existing single-line packets/ordinary keys retain their existing transport.
 if(!source.includes(10)&&!source.includes(13))return null;
 demand(end>=0&&source.toString('hex')===SOURCE_HEX,'exact preselected common LF source');
 demand(input.indexOf(open,start+open.length)<0&&input.indexOf(close,end+close.length)<0,'single source packet');
 demand(sha(readOriginal(policyPath))===policySha,'fixed packet-policy module hash');
 demand(env.C008_PASTE002_DECLARATION,'missing pre-action owner/config/mode/route declaration');
 const declarationBytes=readOriginal(env.C008_PASTE002_DECLARATION);let facts;
 try{facts=JSON.parse(declarationBytes)}catch(error){throw new Error('INSUFFICIENT_EVIDENCE PASTE002 malformed policy declaration',{cause:error})}
 // Facts are supplied independently; only actual offset and preparation time are stamped here.
 const before=session.bridge({op:'paste002-before',tty:session.actualTty}),initial=rawCapture(before,kind);
 const declaration={...facts,declaredBeforeOffset:initial.raw.length,declaredUTC:new Date().toISOString()};
 demand(declaration.route?.kind===kind,'predeclared transport route');
 const originals=[];
 const receipt=preparePolicy(declaration,path=>{const data=readOriginal(path);originals.push({path,data,sha256:sha(data)});return data});
 const folder=join(session.dir,'paste002-'+randomUUID());mkdirSync(folder,{recursive:true});
 writeFileSync(join(folder,'declaration-source.json'),declarationBytes,{flag:'wx'});
 writeFileSync(join(folder,'selection-source.raw'),source,{flag:'wx'});
 const evidence=originals.map((row,i)=>{const snapshot=join(folder,'evidence-'+i+'.raw');writeFileSync(snapshot,row.data,{flag:'wx'});return {path:row.path,snapshot,sha256:row.sha256}});
 json(join(folder,'prepared.json'),{status:'PREPARED_BEFORE_ACTION',label,requestedInputHex:input.toString('hex'),declaration,declarationPath:env.C008_PASTE002_DECLARATION,declarationSha256:sha(declarationBytes),policyPath,policySha256:policySha,sourceHex:SOURCE_HEX,sourceSha256:sha(source),before,evidence,finalAcceptance:false});
 const record={folder,before,evidence,sourceHex:SOURCE_HEX,finalAcceptance:false};
 (session.paste002??=[]).push(record);
 const sentUTC=new Date().toISOString();let actual;
 try{
  actual=session.bridge({op:'input',hex:input.toString('hex'),tty:session.actualTty,paste002:{before,sourceHex:SOURCE_HEX}});
  const observation=actual.paste002;demand(observation,'transport packet observation');
  json(join(folder,'transport.json'),actual);record.after=observation.after;
  demand(JSON.stringify(observation.before)===JSON.stringify(before),'transport reused exact before snapshot');
  demand(actual.pasteSource?.sourceHex===SOURCE_HEX&&actual.pasteSource.sourceSha256===sha(source),'native selection/raw source identity');
  const received=rawCapture(observation.after,kind);
  demand(received.raw.subarray(0,initial.raw.length).equals(initial.raw)&&received.source.subarray(0,initial.source.length).equals(initial.source),'append-only captured source/input prefix');
  for(const row of evidence){bytesAt(row.path,row.sha256);bytesAt(row.snapshot,row.sha256)}
  const o={beforeOffset:observation.beforeOffset,afterOffset:observation.afterOffset,packetStart:observation.packetStart,packetEnd:observation.packetEnd,sentUTC,capturedUTC:observation.after.capturedUTC,rawSha256:observation.after.rawSha256};
  const result=verifyReceivedPacket(receipt,SOURCE_HEX,received.raw,o);
  const prefix=received.raw.subarray(o.beforeOffset,o.packetStart),suffix=received.raw.subarray(o.packetEnd,o.afterOffset);
  demand(prefix.equals(input.subarray(0,start))&&suffix.equals(input.subarray(end+close.length)),'unlogged prefix/suffix bytes outside the source packet');
  json(join(folder,'verified.json'),{...result,sentUTC,capturedUTC:o.capturedUTC,sourceSha256:sha(source),capture:observation.after,prefixHex:prefix.toString('hex'),suffixHex:suffix.toString('hex'),provenance:'exact requested navigation bytes in prepared.json and native actions in transport.json; independent route review required'});
  record.status=result.status;
  return actual;
 }catch(error){record.status=error.message;json(join(folder,'failed.json'),{error:error.message,sentUTC,originalSource:before.source,actual:actual??null,finalAcceptance:false});throw error}
}

export function finalizePaste002(session){
 if(!session.paste002?.length)return;
 demand(session.hostClosed,'completed producer for final original-source proof');
 const proofs=[];
 for(const record of session.paste002){
  for(const value of [record.before,record.after].filter(Boolean)){
   const captured=rawCapture(value,value.kind),final=readOriginal(value.source);
   demand(final.subarray(0,captured.source.length).equals(captured.source),'final original does not retain captured source prefix');
   proofs.push({source:value.source,finalSourceSha256:sha(final),finalSourceBytes:final.length,sourceSnapshot:value.sourceSnapshot,sourcePrefixSha256:value.sourceSha256,sourcePrefixBytes:captured.source.length,rawPath:value.rawPath,rawSha256:value.rawSha256,rawBytes:captured.raw.length});
  }
  for(const row of record.evidence){bytesAt(row.path,row.sha256);bytesAt(row.snapshot,row.sha256)}
 }
 const path=join(session.dir,'paste002-finalization.json');demand(!existsSync(path),'finalization already exists');
 json(path,{producersComplete:true,proofs,finalAcceptance:false});
}

// PASTE002 independent external input-wire oracle; no product/terminal parser imports.
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
export const SOURCE_HEX='717263767a790a72657669657720e4b8ade6968720f09f91a9e2808df09f92bb';
export const CR_PAYLOAD_HEX='717263767a790d72657669657720e4b8ade6968720f09f91a9e2808df09f92bb';
export const OPEN_HEX='1b5b3230307e',CLOSE_HEX='1b5b3230317e';
const policies=Object.freeze({
 XTERM398_DEFAULT_NL_TO_CR:{engine:'XTerm',version:'398',route:'gui-selection',quote:'reset',newline:'reset',payload:CR_PAYLOAD_HEX},
 VTE0801_FIXED_NL_TO_CR:{engine:'VTE',version:'0.80.1',route:'gui-selection',quote:'fixed-reset',newline:'fixed-reset',payload:CR_PAYLOAD_HEX},
 DIRECT_VT_RAW_LF:{engine:'LinuxVT',version:null,route:'controlled-keyboard-raw',quote:'not-applicable',newline:'not-applicable',payload:SOURCE_HEX}
});
const prepared=new WeakMap();
const digest=bytes=>createHash('sha256').update(bytes).digest('hex');
function demand(condition,message){assert(condition,'INSUFFICIENT_EVIDENCE PASTE002 '+message)}
export function preparePolicy(declaration,readEvidence){
 demand(declaration?.schema==='C008-PASTE002-v1','policy schema');
 const p=policies[declaration.policyId];demand(p,'unknown/unsupported policy');
 demand(typeof readEvidence==='function','independent evidence reader');
 demand(declaration.owner?.engine===p.engine&&typeof declaration.owner.version==='string'&&declaration.owner.version.length>0&&(p.version===null||declaration.owner.version===p.version),'actual owning engine/version');
 demand(declaration.route?.kind===p.route&&Array.isArray(declaration.route.chain)&&declaration.route.chain.length>0&&declaration.route.chain.every(v=>typeof v==='string'&&v.length>0),'actual complete outer-to-app route');
 demand(declaration.modes?.bracketedPaste==='set'&&declaration.modes.pasteQuote===p.quote&&declaration.modes.literalNewline===p.newline,'declared genuine modes/configuration');
 demand(declaration.modes.basis==='genuine-observation'||declaration.modes.basis==='verified-default-config'||(p.engine==='VTE'&&declaration.modes.basis==='fixed-official-source'),'mode/configuration provenance');
 demand(Number.isSafeInteger(declaration.declaredBeforeOffset)&&declaration.declaredBeforeOffset>=0,'declaration raw-input offset');
 demand(typeof declaration.declaredUTC==='string'&&Number.isFinite(Date.parse(declaration.declaredUTC)),'declaration UTC');
 demand(Array.isArray(declaration.evidence)&&['owner-config','newline-policy','mode-state','raw-route'].every(kind=>declaration.evidence.some(ref=>ref.kind===kind)),'all four independent evidence kinds');
 for(const ref of declaration.evidence){
  demand(typeof ref.path==='string'&&ref.path.length>0&&/^[a-f0-9]{64}$/.test(ref.sha256),'evidence reference');
  const bytes=readEvidence(ref.path);demand(Buffer.isBuffer(bytes)||bytes instanceof Uint8Array,'raw evidence bytes');
  demand(digest(bytes)===ref.sha256,'evidence hash '+ref.kind);
 }
 // Caller cannot supply expected payloads; clone/freeze facts before the input action.
 const receipt=Object.freeze({policyId:declaration.policyId,sourceHex:SOURCE_HEX});
 prepared.set(receipt,{declaration:JSON.parse(JSON.stringify(declaration)),expected:Buffer.from(OPEN_HEX+p.payload+CLOSE_HEX,'hex')});
 return receipt;
}
function occurrences(bytes,marker){let count=0;for(let at=0;(at=bytes.indexOf(marker,at))>=0;at+=marker.length)count++;return count}
export function verifyReceivedPacket(receipt,sourceHex,raw,observation){
 const frozen=prepared.get(receipt);demand(frozen,'prepare policy before input; no supplied expected payload');
 demand(sourceHex===SOURCE_HEX,'exact common LF selection-source bytes');
 demand(Buffer.isBuffer(raw)||raw instanceof Uint8Array,'unaltered complete input.raw bytes');raw=Buffer.from(raw);
 const d=frozen.declaration,o=observation;
 demand(o&&[o.beforeOffset,o.afterOffset,o.packetStart,o.packetEnd].every(v=>Number.isSafeInteger(v)&&v>=0),'exclusive byte offsets');
 demand(d.declaredBeforeOffset<=o.beforeOffset&&o.beforeOffset<=o.packetStart&&o.packetStart<o.packetEnd&&o.packetEnd<=o.afterOffset&&o.afterOffset<=raw.length,'packet entirely new within captured action window');
 demand(Number.isFinite(Date.parse(o.sentUTC))&&Number.isFinite(Date.parse(o.capturedUTC))&&Date.parse(d.declaredUTC)<=Date.parse(o.sentUTC)&&Date.parse(o.sentUTC)<=Date.parse(o.capturedUTC),'predeclared policy chronology');
 demand(/^[a-f0-9]{64}$/.test(o.rawSha256)&&digest(raw)===o.rawSha256,'unaltered raw-record identity');
 const window=raw.subarray(o.beforeOffset,o.afterOffset),actual=raw.subarray(o.packetStart,o.packetEnd);
 // Exactly one complete fresh packet. Prefix/suffix may contain separately logged key/reply bytes,
 // but cannot contain extra/nested/replayed paste delimiters or supply missing delimiters.
 assert.equal(occurrences(window,Buffer.from(OPEN_HEX,'hex')),1,'FAILED_PASTE_WIRE PASTE002 exactly one new opener');
 assert.equal(occurrences(window,Buffer.from(CLOSE_HEX,'hex')),1,'FAILED_PASTE_WIRE PASTE002 exactly one new closer');
 assert(actual.equals(frozen.expected),'FAILED_PASTE_WIRE PASTE002 exact complete packet mismatch; preserve original raw bytes');
 return Object.freeze({status:'EXACT_RECEIVED_PACKET_MATCH',policyId:receipt.policyId,sourceHex:SOURCE_HEX,expectedPacketHex:frozen.expected.toString('hex'),receivedPacketHex:actual.toString('hex'),beforeOffset:o.beforeOffset,afterOffset:o.afterOffset,packetStart:o.packetStart,packetEnd:o.packetEnd,rawSha256:o.rawSha256,finalAcceptance:false});
}

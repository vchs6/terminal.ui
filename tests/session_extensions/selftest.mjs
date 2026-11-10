import assert from 'node:assert/strict';
import { spawnSync } from 'node:child_process';
import { mkdtempSync,readFileSync,existsSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join,resolve } from 'node:path';
import { golden,hex,wrap,assertWire,assertResult,parseResults } from './oracle.mjs';
const driver=resolve(process.argv[2]);
const dir=mkdtempSync(join(tmpdir(),'session-fixture-selftest-'));
let checks=0,negative=0;
for(const item of golden.copy) {
  assert.equal(Buffer.from(item.utf8Hex,'hex').toString('base64'),item.base64,'independent SDK-free RFC4648 vector check');
  assert.equal(hex(item.directHex).length,8+item.base64.length);checks++;
}
assertWire(wrap(hex(golden.copy[1].directHex),'TmuxPassthrough'),hex(golden.tmuxCopyFHex),'manual tmux golden');checks++;
assertWire(wrap(hex(golden.copy[1].directHex),'ScreenPassthrough'),hex(golden.screenCopyFHex),'manual screen golden');checks++;
for(const bad of [hex('1b5d35323b633b5a6707'),hex('1b5d35323b633b3f07'),hex('1b5d303b7807'),Buffer.concat([hex(golden.copy[1].directHex),hex(golden.popHex)])]) {
  assert.throws(()=>assertWire(bad,hex(golden.copy[1].directHex),'negative corruption'));negative++;
}
for(const [field,bad] of [['status','Applied'],['bytes',11],['issue','NoIssue']]) {
  const want={status:'Failed',bytes:1,issue:'ParserUnsynchronized'};
  const actual={...want,[field]:bad};
  const rows=parseResults(`fault\tCopyLocalText|${actual.status}|${actual.bytes}|${actual.issue}|-1|NotNeeded\n`);
  assert.throws(()=>assertResult(rows,'fault',want));negative++;
}
const frame=hex(golden.copy[1].directHex);
for(const [mode,at,wantStatus,wantBytes] of [[0,0,0,12],[1,0,4,0],[1,1,4,1],[1,11,4,11],[2,0,0,12],[3,0,4,0],[4,0,4,0],[5,0,3,0],[6,0,0,12]]) {
  const stem=join(dir,`${mode}-${at}`),wire=`${stem}.bin`,native=`${stem}.tsv`;
  const result=spawnSync(driver,[String(mode),String(at)],{env:{...process.env,CJTUI_SESSION_WIRE:wire,CJTUI_SESSION_NATIVE:native}});
  assert.equal(result.status,wantStatus,`native driver mode=${mode} at=${at}`);
  const bytes=existsSync(wire)?readFileSync(wire):Buffer.alloc(0);
  assertWire(bytes,frame.subarray(0,wantBytes),'native real writer fault boundary');
  const events=readFileSync(native,'utf8');
  if(mode===2)assert.match(events,/eintr/);
  if(mode===6)assert.equal(events.split('\n').filter(l=>l.startsWith('write\t')).length,12);
  checks++;
}
for (const [tag,args,want,all] of [
  ['second-sequence',['1','1','2','2'],Buffer.concat([frame,frame.subarray(0,1)]),Buffer.concat([frame,frame.subarray(0,1)])],
  ['ordinary-screen',['1','1','1','1','screen'],Buffer.alloc(0),hex('1b')]
]) {
  const wire=join(dir,tag+'.bin'),every=join(dir,tag+'.all');
  const result=spawnSync(driver,args,{env:{...process.env,CJTUI_SESSION_WIRE:wire,CJTUI_SESSION_ALL_WIRE:every}});
  assert.equal(result.status,4);
  assertWire(existsSync(wire)?readFileSync(wire):Buffer.alloc(0),want,tag);
  assertWire(readFileSync(every),all,tag+' all output');checks++;
}
console.log(`PASS fixture-selftest checks=${checks} deliberate-negative-controls=${negative} artifacts=${dir}`);
const {verifyObservation,hostText}=await import('./host-oracle.mjs');
const expected={seedHex:'53454544',clipboardApplied:false,title:{initial:'original',A:'A',B:'B',restored:'original'}};
const observed={clipboardBeforeHex:'53454544',clipboardAfterHex:'53454544',title:{...expected.title},iconBeforeSha256:'a'.repeat(64),iconAfterSha256:'a'.repeat(64),termiosBefore:'same',termiosAfter:'same',exitCode:0};
verifyObservation(observed,expected);
for(const bad of [{...observed,clipboardAfterHex:Buffer.from(hostText).toString('hex')},{...observed,title:{...observed.title,restored:'B'}},{...observed,iconAfterSha256:'b'.repeat(64)},{...observed,termiosAfter:'raw'}]) assert.throws(()=>verifyObservation(bad,expected));
console.log('PASS host observation oracle: permission-negative/title/icon/termios controls=4; synthetic observations only, no product/host PASS');

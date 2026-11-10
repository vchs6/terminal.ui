#!/usr/bin/env node
// Deterministic regression controls for the existing color fixture parser.
import assert from 'node:assert/strict';
import { execFileSync } from 'node:child_process';
import { readFile } from 'node:fs/promises';
import { createHash } from 'node:crypto';
import { fileURLToPath } from 'node:url';
import { Screen, expectedResize } from './pty.mjs';

const root=fileURLToPath(new URL('../../',import.meta.url));
const origins=JSON.parse(await readFile(new URL('fixtures/origins.json',import.meta.url),'utf8'));
const raw=await readFile(new URL('fixtures/old-failure-session.raw',import.meta.url));
const trace=await readFile(new URL('fixtures/stty-resize-ioctl.trace',import.meta.url));
const sha=b=>createHash('sha256').update(b).digest('hex');
assert.equal(sha(raw),origins.session.sha256);assert.equal(sha(trace),origins.trace.sha256);
const sets=[...trace.toString().matchAll(/TIOCSWINSZ, \{ws_row=(\d+), ws_col=(\d+).*?= 0/g)].map(m=>[Number(m[2]),Number(m[1])]);
assert.deepEqual(sets,[[100,12],[31,12]],'old stty really passes through100x12');
const oldSource=execFileSync('git',['show',`${origins.old_test_base}:tests/colors/pty.mjs`],{cwd:root,encoding:'utf8'});
// Execute the exact historical Screen implementation, not a recreated oracle.
const body=oldSource.slice(oldSource.indexOf('function width('),oldSource.indexOf('class Session'));
const module='data:text/javascript;base64,'+Buffer.from("import assert from 'node:assert/strict'; import { StringDecoder } from 'node:string_decoder';\n"+body+'\nexport {Screen};').toString('base64');
const {Screen:OldScreen}=await import(module);
const middle=raw.subarray(...origins.session.intermediate_offsets);
const atRealSize=new OldScreen(100,12);atRealSize.feed(middle);
assert.equal(atRealSize.snapshot().length,12,'actual intermediate is a complete coherent frame');
const frame=(w,h,letter='T')=>Buffer.from(Array.from({length:h},(_,i)=>`\x1b[0m\x1b[${i+1};1H${letter.repeat(w)}\x1b[0m`).join(''));
for(const [name,bytes] of [['real100x12',middle],['legalOldInflight100x40',frame(100,40,'O')]]) {
 const old=new OldScreen(100,40);old.resize(31,12);
 assert.throws(()=>old.feed(bytes),/complete row 1/);
 console.log(`PASS negative old oracle misrejects ${name}`);
}
const actualInflight=await readFile(new URL('fixtures/real-inflight-session.raw',import.meta.url));
assert.equal(sha(actualInflight),origins.inflight.sha256);
const oldInflight=new OldScreen(24,5);oldInflight.resize(8,3);
assert.throws(()=>oldInflight.feed(actualInflight),/complete row 1/);
const actual=new Screen(24,5);actual.beginResize(8,3);actual.feed(actualInflight);
assert.deepEqual(actual.resizeFrames.map(f=>[f.width,f.height]),[[24,5],[8,3]]);
assert.deepEqual(actual.finishResize(8,3).map(row=>row.text),['CJTUI_CO','01234567','        ']);
console.log('PASS actual R019 gated old/inflight: old oracle misrejects, fixed oracle accepts complete final grid');
const transition=()=>{const s=new Screen(100,40);s.beginResize(31,12);return s;};
const valid=transition();valid.feed(frame(100,40,'O'));valid.feed(frame(31,12));
assert.deepEqual(valid.resizeFrames.map(f=>[f.width,f.height]),[[100,40],[31,12]]);
assert.equal(valid.finishResize(31,12).length,12);
console.log('PASS coherent old/inflight followed by complete target accepted');
const split=transition();const bytes=Buffer.concat([frame(100,40,'O'),frame(31,12)]);
for(let i=0;i<bytes.length;i+=7)split.feed(bytes.subarray(i,i+7));
assert.equal(split.finishResize(31,12).length,12,'transport chunking does not define frames');
console.log('PASS split-byte old/inflight and target accepted');
for(const [name,bytes] of [
 ['bad row width',Buffer.from('\x1b[0m\x1b[1;1H'+'T'.repeat(31)+'\x1b[0m\x1b[2;1H'+'T'.repeat(30)+'\x1b[0m\x1b[3;1H')],
 ['third width',frame(50,12)],
 ['third pair100x12 after atomic two-state resize',Buffer.concat([middle,frame(31,12)])],
 ['oversized target height',frame(31,13)]
]) {
 const bad=transition();assert.throws(()=>bad.feed(bytes));console.log(`PASS rejects ${name}`);
}
for(const [name,bytes] of [['old only',frame(100,40,'O')],['incomplete target',frame(31,11)],
 ['target followed by old',Buffer.concat([frame(31,12),frame(100,40,'O')])]]) {
 const bad=transition();bad.feed(bytes);assert.throws(()=>bad.finishResize(31,12));console.log(`PASS rejects unsettled ${name}`);
}
const late=transition();late.feed(frame(31,12));late.finishResize(31,12);
assert.throws(()=>late.feed(frame(100,40,'O')));
console.log('PASS late wrong-size bytes still rejected after target completion');
const expected=expectedResize(31),wrongStyle=structuredClone(expected);wrongStyle[4].cells[0].fg='rgb:250,0,0';
assert.throws(()=>assert.deepEqual(wrongStyle,expected));
console.log('PASS exact target rejects incorrect style');
console.log('PASS colors resize oracle: old false rejections reproduced; finite pairs, complete settled grid and styles enforced');

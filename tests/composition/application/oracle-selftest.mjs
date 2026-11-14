// Test infrastructure checks only; never evidence of application correctness.
import assert from 'node:assert/strict';
import {spawnSync} from 'node:child_process';
import {goldens,modalGoldens} from './fixtures.mjs';
import {WireScreen} from './pty.mjs';
import {verify} from './smoke.mjs';
const segmenter=new Intl.Segmenter('und',{granularity:'grapheme'});
const widths=new Map([['中',2],['文',2],['👩‍💻',2]]);
for(const frame of [...goldens,...modalGoldens]){
 assert.equal(frame.rows.length,frame.height,`${frame.scene} rows`);
 for(const row of frame.rows){let width=0;for(const {segment}of segmenter.segment(row))width+=widths.get(segment)??1;assert.equal(width,frame.width,`${frame.scene} literal row width`)}
}
assert.equal(goldens.find(f=>f.scene==='tasks'&&f.width===40).rows[10],'01 Ready Parse                          ');
assert.equal(goldens.find(f=>f.scene==='logs'&&f.width===80).rows[22],'016 INFO record 16                                                              ');
const wire=new WireScreen(4,2);
const literal=Buffer.from('\x1b[?2004h\x1b[?25$p\x1b[0m\x1b[1;1H\x1b[33mIdle\x1b[0m\x1b[2;1H    \x1b[0m\x1b[1;3H\x1b[?25h');
for(const byte of literal)wire.feed(Buffer.of(byte));
assert.deepEqual(wire.rows().map(row=>row.text),['Idle','    '],'byte chunking and mode/caret separation');
assert.equal(wire.rows()[0].cells[0].fg,'named:33','existing Screen retains style');
assert.throws(()=>new WireScreen(4,1).feed(Buffer.from('\x1b[1;1Hbad\x1b[0m\x1b[1;2H')),/wrong complete width/,'malformed rows cannot count as complete');
const fake={status:0,signal:null,error:undefined,stdout:'PASS composition\n',stderr:''};
assert.throws(()=>verify(fake,true,'composition'),/literal startup/,'marker without actual grids is rejected');
assert.throws(()=>verify({...fake,stdout:'diagnostic'},false,'composition'),/invalid CLI/,'false successful invalid argument rejected');
assert.throws(()=>verify({...fake,status:null,signal:'SIGTERM'},false,'composition'),/signal/,'timeout cannot satisfy nonzero error case');
const trueExit=spawnSync('/bin/sh',['-c','printf diagnostic >&2; exit 7'],{encoding:'utf8'});
verify(trueExit,false,'composition');assert.equal(trueExit.status,7,'infrastructure control retains direct exit7');
console.log('PASS infrastructure only: literal grid shape, independent row/style oracle, chunking, malformed wire and real-exit negative controls');

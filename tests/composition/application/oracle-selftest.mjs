// Test infrastructure checks only; never evidence of application correctness.
import assert from 'node:assert/strict';
import {spawnSync} from 'node:child_process';
import {goldens,modalGoldens,minimalPtyGolden} from './fixtures.mjs';
import {WireScreen,themeVisible} from './pty.mjs';
import {verify} from './smoke.mjs';
const segmenter=new Intl.Segmenter('und',{granularity:'grapheme'});
const widths=new Map([['中',2],['文',2],['👩‍💻',2]]);
for(const frame of [...goldens,...modalGoldens,minimalPtyGolden]){
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
// Full encoder may leave default-tail rows without a per-row reset. Preserve
// actual SGR state while using the next CUP as a complete-row boundary.
const full=new WireScreen(4,2);
const noRowReset=Buffer.from('\x1b[0m\x1b[1;1H\x1b[36mAB\x1b[0m  \x1b[2;1HCD  \x1b[0m');
for(const byte of noRowReset)full.feed(Buffer.of(byte));
assert.deepEqual(full.rows().map(row=>row.text),['AB  ','CD  '],'full rows complete at CUP or final reset');
assert.equal(full.rows()[0].cells[0].fg,'named:36','colored prefix retains actual style');
assert.equal(full.rows()[0].cells[2].fg,'default','mid-row reset applies to trailing spaces');
assert.equal(full.rows()[1].cells[0].fg,'default','next row remains default');
full.feed(Buffer.from('\x1b[0m\x1b[2;1HNEW \x1b[0m'));
assert.deepEqual(full.rows().map(row=>row.text),['AB  ','NEW '],'dirty-row update preserves untouched row');
full.finish();
const inherited=new WireScreen(4,2);
inherited.feed(Buffer.from('\x1b[0m\x1b[1;1H\x1b[36mAB  \x1b[2;1HCD  \x1b[0m'));
assert.equal(inherited.rows()[1].cells[0].fg,'named:36','adapter never invents reset between rows');
assert.throws(()=>assert.equal(inherited.rows()[1].cells[0].fg,'default'),'wrong inherited style cannot satisfy a default-style oracle');
assert.throws(()=>new WireScreen(4,2).feed(Buffer.from('\x1b[1;1Hbad\x1b[2;1H')),/wrong complete width/,'short row rejected at next CUP');
assert.throws(()=>new WireScreen(4,2).feed(Buffer.from('\x1b[1;1Hlong!\x1b[2;1H')),/wrong complete width/,'overlong row rejected at next CUP');
assert.throws(()=>new WireScreen(4,1).feed(Buffer.from('\x1b[1;1H\x1b[999mAB  \x1b[0m')),/unsupported SGR/,'unsupported SGR is not discarded');
const partial=new WireScreen(4,1);partial.feed(Buffer.from('\x1b[1;1HAB'));
assert.throws(()=>partial.finish(),/incomplete renderer row/,'truncated row cannot finish successfully');
const partialControl=new WireScreen(4,1);partialControl.feed(Buffer.from('\x1b[1;1HAB  \x1b[0m\x1b['));
assert.throws(()=>partialControl.finish(),/incomplete terminal control/,'truncated control cannot finish successfully');
const partialUtf8=new WireScreen(4,1);partialUtf8.feed(Buffer.from([0xe4,0xb8]));
assert.throws(()=>partialUtf8.finish(),/incomplete UTF-8/,'truncated UTF-8 cannot finish successfully');
const resized=new WireScreen(4,2);resized.feed(Buffer.from('\x1b[0m\x1b[1;1H1111\x1b[2;1H2222\x1b[0m'));
resized.screen.beginResize(2,3);resized.feed(Buffer.from('\x1b[0m\x1b[1;1Haa\x1b[2;1Hbb\x1b[3;1Hcc\x1b[0m'));
assert(resized.screen.targetComplete(2,3),'new dimensions require a complete sequential target');
assert.deepEqual(resized.screen.finishResize(2,3).map(row=>row.text),['aa','bb','cc'],'resize retains complete-row validation');
resized.finish();
const logicalMinimal=goldens.find(frame=>frame.scene==='minimal');
assert.equal(logicalMinimal.rows[1],'中文 👩‍💻         ','headless Unicode source is retained');
assert.equal(minimalPtyGolden.rows[1],'中文 ??         ','manual G012 Auto result preserves exactly two projected columns');
// A visible requested label is allowed before asynchronous theme acceptance.
const themeRows=(name,bg,fg)=>[
 {text:'    ',cells:Array.from({length:4},()=>({text:' ',bg,fg}))},
 {text:'Tasks | '+name,cells:Array.from({length:4},()=>({text:' ',bg,fg}))}
];
assert.equal(themeVisible('Light')(themeRows('Light','default','default')),false,'pending Light label must not release theme wait');
assert.equal(themeVisible('Light')(themeRows('Light','rgb:255,255,255','rgb:24,32,40')),true,'expected label and applied Light colors release wait');
assert.equal(themeVisible('Light')(themeRows('Light','rgb:255,255,255','default')),false,'incomplete Light text style remains pending');
assert.equal(themeVisible('Light')(themeRows('Classic','rgb:255,255,255','rgb:24,32,40')),false,'old label cannot satisfy requested theme');
assert.equal(themeVisible('Classic')(themeRows('Classic','rgb:255,255,255','rgb:24,32,40')),false,'pending Classic label cannot bypass old Light colors');
assert.equal(themeVisible('Classic')(themeRows('Classic','default','default')),true,'Classic label and default colors release wait');
const partialTheme=themeRows('Light','rgb:255,255,255','rgb:24,32,40');partialTheme[0].cells[3].bg='default';
assert.equal(themeVisible('Light')(partialTheme),false,'partially painted background cannot release wait');
// Manual local-selection fixture: undo restores [7,8], external source sync
// only clamps endpoints; eleven-cluster Shared note leaves both unchanged.
const selectedSource=[...segmenter.segment('qrcvzy\nreview 中文 👩‍💻')].map(item=>item.segment);
assert.equal(selectedSource.slice(0,7).join(''),'qrcvzy\n','six text clusters plus LF place second-line start at7');
assert.equal(selectedSource[7],'r','gap7..8 originally selects r');
const externalNote='Shared note';
assert.equal([...segmenter.segment(externalNote)].length,11,'new source has eleven clusters, so gaps7 and8 do not clamp');
assert.equal(externalNote.slice(7,8),'n','retained gap7..8 now selects n');
const replacedNote=externalNote.slice(0,7)+'!'+externalNote.slice(8);
assert.equal(replacedNote,'Shared !ote','literal exact-selection replacement');
assert.notEqual(replacedNote,'Shared note!','caret moved to end would fail exact replacement');
assert.notEqual(replacedNote,'Shared !note','collapsed gap7 would fail exact replacement');
assert.notEqual(replacedNote,'!Shared note','focus/caret reset to start would fail exact replacement');
// Hand arithmetic for the full-width short phase:4 text columns+76 blanks=80.
const donePhaseRow='Done'+' '.repeat(76);
assert.equal(donePhaseRow.length,80,'Done phase expectation fits the fixed80-column viewport');
assert.throws(()=>assert.equal('Done'+' '.repeat(75)+'x',donePhaseRow),'stale nonspace at column79 fails exact-row oracle despite correct width');
assert.throws(()=>assert.equal('Done'+' '.repeat(77),donePhaseRow),'81-column padding mistake cannot satisfy exact-row oracle');
const fake={status:0,signal:null,error:undefined,stdout:'PASS composition\n',stderr:''};
assert.throws(()=>verify(fake,true,'composition'),/literal startup/,'marker without actual grids is rejected');
assert.throws(()=>verify({...fake,stdout:'diagnostic'},false,'composition'),/invalid CLI/,'false successful invalid argument rejected');
assert.throws(()=>verify({...fake,status:null,signal:'SIGTERM'},false,'composition'),/signal/,'timeout cannot satisfy nonzero error case');
const trueExit=spawnSync('/bin/sh',['-c','printf diagnostic >&2; exit 7'],{encoding:'utf8'});
verify(trueExit,false,'composition');assert.equal(trueExit.status,7,'infrastructure control retains direct exit7');
console.log('PASS infrastructure only: literal grid shape, independent row/style oracle, chunking, malformed wire and real-exit negative controls');

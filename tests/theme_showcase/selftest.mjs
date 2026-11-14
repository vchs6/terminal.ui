// Infrastructure check only. A passing selftest never means the example ran.
import assert from 'node:assert/strict';
import {spawnSync} from 'node:child_process';
import {WireScreen} from '../composition/application/pty.mjs';
import {smokeGoldens,ptyGoldens,modalGoldens,retainedGoldens,presets,palette,frame} from './fixtures.mjs';
import {width,cellAt,acceptedPalette,checkStyles,sameGrid} from './checks.mjs';
import {verify} from './smoke.mjs';
for(const fixtures of [smokeGoldens,ptyGoldens,modalGoldens,retainedGoldens]){
  for(const entry of fixtures){
    assert.equal(entry.rows.length,entry.height,`${entry.name} ${entry.state} exact height`);
    for(const row of entry.rows)assert.equal(width(row),entry.width,`${entry.name} ${entry.state} literal row width`);
  }
}
assert.equal(smokeGoldens.length,16,'four presets × three sizes plus pending full grid');
assert.equal(ptyGoldens.length,16,'PTY projections are frozen separately');
assert.equal(modalGoldens.length,4,'four complete visible modal layers');
assert.equal(retainedGoldens.length,8,'four pending and four scrolled complete retained grids');
for(const name of presets){
  assert(frame(smokeGoldens,name,80,24)[10].startsWith('001 INFO record 01'),'first scroll row');
  assert(frame(smokeGoldens,name,80,24)[22].startsWith('013 INFO record 13'),'thirteenth scroll row');
  assert(frame(smokeGoldens,name,80,24,'pending')[9].startsWith('==========----------'),'pending progress');
  assert(frame(modalGoldens,name,80,24,'modal')[7].includes(name==='Dark'||name==='Light'?'╭':'+'),'preset modal border');
  assert(frame(retainedGoldens,name,80,24,'retained-scrolled')[10].startsWith('012 INFO record 12'),'clamped offset11');
  assert(frame(retainedGoldens,name,80,24,'retained-scrolled')[22].startsWith('024 INFO record 24'),'last scroll row');
}
assert.equal(width('Label é 中 👩‍💻'),13,'Unicode clusters have source widths');
assert.equal(width('Label é 中 ??'),13,'Auto PTY emoji fallback occupies two cells');
const wire=new WireScreen(4,2);
for(const byte of Buffer.from('\x1b[0m\x1b[1;1H\x1b[36mAB\x1b[0m  \x1b[2;1HCD  \x1b[0m'))wire.feed(Buffer.of(byte));
sameGrid(wire.rows(),[{name:'probe',state:'startup',width:4,height:2,rows:['AB  ','CD  ']}],'probe',4,2);
assert.equal(wire.rows()[0].cells[0].fg,'named:36','existing oracle preserves first styled segment');
assert.equal(wire.rows()[0].cells[2].fg,'default','mid-row reset affects blanks');
assert.equal(wire.rows()[1].cells[0].fg,'default','next row has default style');
wire.finish();
assert.throws(()=>new WireScreen(4,1).feed(Buffer.from('\x1b[1;1Hbad\x1b[0m\x1b[1;2H')),/wrong complete width/);
assert.throws(()=>new WireScreen(4,1).feed(Buffer.from('\x1b[1;1Hlong!\x1b[0m\x1b[1;2H')),/wrong complete width/);
const partial=new WireScreen(4,1);partial.feed(Buffer.from('\x1b[1;1HAB'));assert.throws(()=>partial.finish(),/incomplete renderer row/);
const falseRows=[{text:'Gallery | Light |',cells:[]},{text:'',cells:[]}];
assert.equal(acceptedPalette(falseRows,'Light'),false,'label alone cannot satisfy async acceptance');
assert.equal(acceptedPalette(falseRows,'Dark'),false,'wrong name cannot satisfy async acceptance');
const source=frame(ptyGoldens,'Classic',80,24);
const styled=source.map(text=>({text,cells:[...new Intl.Segmenter('und',{granularity:'grapheme'}).segment(text)]
  .map(({segment})=>({text:segment,fg:'default',bg:'default',attributes:[]}))}));
const mark=(x,y,fg,attributes)=>{const cell=cellAt(styled,x,y);cell.fg=fg;cell.attributes=attributes};
mark(0,1,'default',[1]);mark(0,4,'named:36',[4]);mark(0,6,'default',[7]);
mark(40,2,'named:36',[1]);mark(48,2,'named:36',[1,4]);
mark(40,7,'named:90',[2]);mark(48,0,'named:90',[2]);
checkStyles(styled,'Classic');
cellAt(styled,79,22).bg='named:40';
assert.equal(acceptedPalette(styled,'Classic'),false,'partial new background cannot release wait');
cellAt(styled,79,22).bg='default';cellAt(styled,40,7).attributes=[];
assert.throws(()=>checkStyles(styled,'Classic'),/disabled Button dim/,'wrong disabled style rejected');
const fake={status:0,signal:null,error:undefined,stdout:'PASS theme showcase\n',stderr:''};
assert.throws(()=>verify(fake,true),/four complete literal grids/,'marker alone cannot satisfy smoke');
assert.throws(()=>verify(fake,false),/nonzero/,'false successful invalid CLI rejected');
assert.throws(()=>verify({...fake,status:null,signal:'SIGTERM'},false),/signal/,'timeout is not invalid CLI');
const real=spawnSync('/bin/sh',['-c','printf diagnostic >&2; exit 7'],{encoding:'utf8'});
verify(real,false);assert.equal(real.status,7,'real negative control retains direct exit');
assert.equal(palette['High contrast'].bg,'named:40','HC literal black background');
console.log('PASS infrastructure only: literal widths, complete grids, existing oracle, chunking, style/reset, partial/invalid frames, async and true-exit controls');

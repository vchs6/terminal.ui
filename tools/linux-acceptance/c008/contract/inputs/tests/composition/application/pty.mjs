// Ordinary executable, real input/resize; util-linux PTY is a synthetic host.
import assert from 'node:assert/strict';
import {spawn,spawnSync} from 'node:child_process';
import {mkdir,mkdtemp,readFile,writeFile} from 'node:fs/promises';
import {resolve,join} from 'node:path';
import {StringDecoder} from 'node:string_decoder';
import {Screen} from '../../colors/pty.mjs';
import {prepareTerminalSizeTool,atomicResize} from '../../support/terminal_frames.mjs';
import {goldens,modalGoldens,minimalPtyGolden,keys,paste} from './fixtures.mjs';
const quote=value=>`'${value.replaceAll("'","'\\''")}'`;
const delay=ms=>new Promise(done=>setTimeout(done,ms));
const read=async path=>{try{return await readFile(path,'utf8')}catch(error){if(error.code==='ENOENT')return '';throw error}};
const text=rows=>rows.map(row=>row.text).join('\n');
const at=(rows,x,y)=>{let col=0;for(const cell of rows[y].cells){if(col===x)return cell;col+=[...cell.text].length}throw Error(`missing cell ${x},${y}`)};
async function until(predicate,label,ms=12000){
  const end=Date.now()+ms;
  while(Date.now()<end){if(await predicate())return;await delay(10)}
  throw Error(`timeout waiting for visible event: ${label}`);
}
// Only separates renderer full-row records from native mode/query/caret controls.
// Existing Screen owns every glyph/style/row assertion; no new ANSI renderer.
export class WireScreen {
  constructor(w,h){this.screen=new Screen(w,h);this.decoder=new StringDecoder('utf8');this.wire='';this.offset=0}
  feed(bytes){
    this.wire+=this.decoder.write(bytes);this.incompleteRow=false;
    const pattern=/\x1b\[(\d+);1H((?:\x1b\[[0-9;]*m|[^\x1b\x00-\x1f])*)/gu;
    pattern.lastIndex=this.offset;
    for(let m; (m=pattern.exec(this.wire));){
      if(!m[2].replaceAll(/\x1b\[[0-9;]*m/g,'').length){continue}
      const endsReset=m[2].endsWith('\x1b[0m');
      const nextAvailable=/^\x1b\[(?:\d+;\d+H|\?(?:25|2004)[hl]|\?25\$p)/.test(this.wire.slice(pattern.lastIndex));
      if(!endsReset&&!nextAvailable){this.incompleteRow=true;break}
      const widths=this.screen.transition?[this.screen.transition.old[0],this.screen.transition.target[0]]:[this.screen.w];
      let complete=false;
      for(const w of new Set(widths)){
        const probe=new Screen(w,Math.max(this.screen.h,Number(m[1])));
        try{
          probe.feed(Buffer.from(m[0]));probe.flush();complete=true;break;
        }catch(error){if(!/^complete row \d+:/.test(error.message))throw error}
      }
      if(!complete){if(nextAvailable)assert.fail('renderer row has wrong complete width');this.incompleteRow=true;break}
      this.screen.feed(Buffer.from(m[0]));this.screen.flush();this.offset=pattern.lastIndex;
    }
  }
  rows(){return this.screen.snapshot()}
  finish(){
    assert.equal(this.decoder.end(),'','no incomplete UTF-8 at wire close');
    assert(!this.incompleteRow,'no incomplete renderer row at wire close');
    assert(!/\x1b(?:\[[0-9;?]*\$?)?$/.test(this.wire),'no incomplete terminal control at wire close');
    return this.screen.finalize();
  }
}
export class Session {
  constructor(directory,w,h,binary=resolve('examples/composition/target/release/bin/main')) {
    this.dir=directory;this.w=w;this.h=h;this.binary=binary;this.view=new WireScreen(w,h);
    this.raw=Buffer.alloc(0);this.events=[];this.frames=[];this.stderr='';this.finished=false;
  }
  async start(){
    await mkdir(this.dir,{recursive:true});
    const wrapper=join(this.dir,'session.sh');
    await writeFile(wrapper,'#!/bin/sh\nstty rows "$3" cols "$4"\nstty -g > "$2/before"\ntty > "$2/tty"\n"$1" < /dev/tty &\np=$!\necho "$p" > "$2/pid"\nwait "$p"\nstatus=$?\nprintf "%s\\n" "$status" > "$2/direct.exit"\nstty -g > "$2/after"\nexit "$status"\n');
    this.child=spawn('script',['--quiet','--return','--flush','--command',
      `sh ${quote(wrapper)} ${quote(this.binary)} ${quote(this.dir)} ${this.h} ${this.w}`,'/dev/null'],
      {stdio:['pipe','pipe','pipe'],env:{...process.env,TERM:'xterm-256color',COLORTERM:'truecolor'}});
    this.child.stdout.on('data',bytes=>{
      this.raw=Buffer.concat([this.raw,bytes]);
      try{this.view.feed(bytes)}catch(error){this.error??=error}
      if(!this.answeredProbe && this.raw.includes(Buffer.from('\x1b[?25$p'))){
        this.answeredProbe=true;this.send('\x1b[?25;1$y','synthetic DECRQM visible response');
      }
    });
    this.child.stderr.on('data',bytes=>{this.stderr+=bytes.toString()});
    this.child.on('error',error=>{this.error??=error;this.finished=true});
    this.child.on('close',(code,signal)=>{this.code=code;this.signal=signal;this.finished=true});
    await until(async()=>{this.pid=Number((await read(join(this.dir,'pid'))).trim());return this.pid>0},'direct binary PID');
  }
  send(bytes,label){this.events.push({utc:new Date().toISOString(),label,hex:Buffer.from(bytes).toString('hex')});this.child.stdin.write(bytes)}
  async wait(predicate,label){
    let rows;
    await until(()=>{if(this.error)throw this.error;assert(!this.finished,`direct binary exited before ${label}: ${this.code}`);
      if(this.view.incompleteRow||this.view.screen.row!==null||this.view.screen.pending)return false;
      rows=this.view.rows();return predicate(rows)},label);
    this.frames.push({label,utc:new Date().toISOString(),rows});return rows;
  }
  async has(value,label=value){return this.wait(rows=>text(rows).includes(value),label)}
  async key(bytes,predicate,label){const previous=this.view.screen.updates.length;this.send(bytes,label);return this.wait(rows=>this.view.screen.updates.length>previous&&predicate(rows),label)}
  async resize(w,h){
    this.view.screen.beginResize(w,h);
    const tty=(await read(join(this.dir,'tty'))).trim();
    const readback=atomicResize(tty,w,h);this.events.push({utc:new Date().toISOString(),resize:[w,h],readback});
    process.kill(this.pid,'SIGWINCH');
    await until(()=>{if(this.error)throw this.error;return this.view.screen.targetComplete(w,h)},`full ${w}x${h} actual resize`);
    const rows=this.view.screen.finishResize(w,h);this.w=w;this.h=h;
    this.frames.push({label:`resize ${w}x${h}`,rows});return rows;
  }
  async stop(exitKey=keys.f10){
    this.send(exitKey,'ordinary quit');await until(()=>this.finished,'ordinary successful quit');
    if(this.error)throw this.error;
    this.view.finish();
    assert.equal(this.code,0,'script --return true exit');assert.equal(this.signal,null);
    assert.equal((await read(join(this.dir,'direct.exit'))).trim(),'0','actual binary true exit');
    const before=(await read(join(this.dir,'before'))).trim();assert(before,'before termios recorded');
    assert.equal((await read(join(this.dir,'after'))).trim(),before,'exact termios restore');
    assert(this.raw.includes(Buffer.from('\x1b[?2004h'))&&this.raw.includes(Buffer.from('\x1b[?2004l')),'bracketed-paste enter/restore');
  }
  async save(){
    await writeFile(join(this.dir,'stdout.raw'),this.raw);await writeFile(join(this.dir,'stderr.txt'),this.stderr);
    await writeFile(join(this.dir,'events.json'),JSON.stringify(this.events,null,2)+'\n');
    await writeFile(join(this.dir,'frames.json'),JSON.stringify(this.frames,null,2)+'\n');
    await writeFile(join(this.dir,'result.json'),JSON.stringify({code:this.code??null,signal:this.signal??null,
      profile:'synthetic PTY: TERM=xterm-256color COLORTERM=truecolor; native default Auto',binary:this.binary,
      error:this.error?.message??null,utc:new Date().toISOString()},null,2)+'\n');
    if(!this.finished){try{if(this.pid)process.kill(this.pid,'SIGKILL')}catch{}this.child.kill('SIGKILL')}
    this.child?.stdin.destroy();
  }
}
const contains=value=>rows=>text(rows).includes(value);
// Theme labels are business state; Preset requests apply asynchronously.
export const themeVisible=name=>rows=>{
  const footer=rows.at(-1),root=rows.at(-2).cells.at(-1),end=footer.cells.at(-1);
  const bg=name==='Light'?'rgb:255,255,255':'default';
  const fg=name==='Light'?'rgb:24,32,40':'default';
  return footer.text.includes('| '+name)&&root?.bg===bg&&end?.bg===bg&&footer.cells[0]?.fg===fg;
};
function sameGrid(actual,w,h,scene){assert.deepEqual(actual.map(row=>row.text),goldens.find(f=>f.scene===scene&&f.width===w&&f.height===h).rows,`${scene} ${w}x${h} hand-authored grid`)}
async function startup(directory,w,h){
  const s=new Session(directory,w,h);
  try{
    await s.start();const initial=await s.has('Tasks | Ready 0/');sameGrid(initial,w,h,'tasks');
    if(w===80){
      assert.equal(at(initial,0,9).fg,'named:33','explicit initial Idle yellow');
      assert.equal(at(initial,40,2).fg,'named:36','shared Ready cyan');
      assert(at(initial,0,1).attributes.includes(1),'title bold');
      assert(at(initial,25,0).attributes.includes(2),'disabled menu dim');
    }
    const logs=await s.key(keys.f2,contains('Logs |'), 'F2 Logs');sameGrid(logs,w,h,'logs');
    const tasks=await s.key(keys.f1,contains('Tasks | Ready 0/'),'F1 Tasks');sameGrid(tasks,w,h,'tasks');
    if(w>=40){
      const modal=await s.key(keys.f4,contains('╭'),'startup centered reused panel');
      const golden=modalGoldens.find(f=>f.width===w);
      assert.deepEqual(modal.map(r=>r.text),golden.rows,'manual centered modal grid');
      const {x,y,width,height}=golden.shadow;
      for(let col=x;col<x+width;col++)assert.equal(at(modal,col,y+height-1).bg,'named:40','full bottom shadow styles');
      for(let row=y;row<y+height;row++)assert.equal(at(modal,x+width-1,row).bg,'named:40','full right shadow styles');
      await s.key(keys.esc,rows=>!text(rows).includes('╭'),'startup modal close');
    }
    if(w===80){
      sameGrid(await s.resize(40,12),40,12,'tasks');sameGrid(await s.resize(16,6),16,6,'tasks');sameGrid(await s.resize(80,24),80,24,'tasks');
    }
    await s.stop();
  }finally{await s.save()}
}
async function minimal(directory){
  const s=new Session(directory,16,3,resolve('examples/minimal/target/release/bin/main'));
  try{await s.start();const rows=await s.has('中文 ??');
    assert.deepEqual(rows.map(row=>row.text),minimalPtyGolden.rows,'minimal synthetic unknown-PTY Auto grid');
    assert.equal(at(rows,0,0).fg,'named:36','minimal styled Text uses cyan');await s.stop('q');
  }finally{await s.save()}
}
async function interactions(directory){
  const s=new Session(directory,80,24);
  try{
    await s.start();await s.has('Tasks | Ready 0/2');
    s.send(keys.backtab+keys.home+'\x1b[C'.repeat(4),'horizontal menu skips Disabled');
    await s.wait(rows=>at(rows,34,0).attributes.includes(4),'Quit focused after skipping Disabled');
    assert(!at(s.view.rows(),25,0).attributes.includes(4),'disabled menu cannot focus');
    s.send(keys.home+keys.enter,'Tasks menu returns to filter');
    await s.key('qrcvzy',contains('qrcvzy'),'standard printable editing never quits');
    await s.key(keys.ctrlA+paste('Parse'),rows=>text(rows).includes('01 Ready Parse')&&!text(rows).includes('02 Ready Render'),'single-line paste filters tasks');
    await s.key(keys.undo,contains('qrcvzy'),'undo restores previous query');
    await s.key(keys.ctrlA+'\x7f',contains('03 Done Export'),'clear filter');
    await s.key(keys.tab+' ',rows=>text(rows).includes('[x] Hide done')&&!text(rows).includes('03 Done Export'),'business checkbox hides done');
    await s.key(' ',contains('03 Done Export'),'business checkbox restores done');
    s.send(keys.tab+keys.tab+' ','Name radio');
    await s.wait(rows=>rows[10].text.startsWith('03 Done Export')&&rows[11].text.startsWith('01 Ready Parse'),'name order Export Parse Render');
    await s.key(keys.backtab+' ',rows=>rows[10].text.startsWith('01 Ready Parse'),'ID radio owns sorting');
    // ID -> Name -> Run -> scroll -> notes. Edit in the real TextArea.
    await s.key(keys.tab.repeat(4)+keys.ctrlA+paste('qrcvzy\r\nreview 中文 👩‍💻'),contains('review 中文 ??'),'multiline paste is editor data');
    s.send(keys.home+'\x1b[1;2C','select first character');
    const light=await s.key(keys.f3,themeVisible('Light'),'theme changes without losing editor');
    assert.equal(at(light,79,22).bg,'rgb:255,255,255','Light applies root background');
    await s.key('X',contains('Xeview'),'replace preserved selection after theme');
    await s.key(keys.undo,contains('review'),'undo survives theme transition');
    await s.key(keys.f3,themeVisible('Classic'),'return Classic');
    const modal=await s.key(keys.f4,contains('╭'),'open reused JobPanel modal');
    assert(text(modal).includes('qrcvzy'),'shared model remains visible in both hosts');
    await s.key(keys.esc,rows=>!text(rows).includes('╭'),'close modal preserves editor selection');
    await s.key('Y',contains('Yeview'),'replace exact selection after modal close');
    await s.key(keys.undo,contains('review'),'undo survives modal close');
    await s.key(keys.f4,contains('╭'),'reopen reused panel for shared data');
    // Modal editor starts with the same business notes; a typed letter changes
    // the shared source and must not activate an application command.
    await s.key(keys.ctrlA+paste('Shared note'),contains('Shared note'),'same custom panel shares business notes');
    s.send(keys.tab+keys.enter,'Actions popup');await s.has('Inspect');
    s.send(keys.down+keys.enter,'Down skips disabled Delete and opens Confirm');await s.has('Confirm?');
    await s.key(keys.esc,rows=>!text(rows).includes('Confirm?')&&text(rows).includes('Inspect'),'cancel nested confirmation');
    await s.key(keys.esc,rows=>!text(rows).includes('Inspect'),'cancel popup only');
    await s.key(keys.esc,rows=>!text(rows).includes('╭')&&text(rows).includes('Shared note'),'close modal and latest underlying notes');
    s.send(keys.f4+keys.tab+keys.enter,'reopen nested ownership case');await s.has('Inspect');
    s.send(keys.down+keys.enter,'confirm under owned Details');await s.has('Confirm?');
    await s.key(keys.f9,rows=>!text(rows).includes('╭')&&!text(rows).includes('Inspect')&&!text(rows).includes('Confirm?'),'close ancestor removes all owned layers');
    await s.key('!',contains('Shared !ote'),'focus returns to underlying editor');
    await s.key(keys.f2,contains('Logs | 24/24'),'different business scene');
    await s.key(keys.tab.repeat(4)+keys.pageDown,contains('024 ERROR record 24'),'vertical ScrollView reaches record24');
    const scrolled=s.view.rows();
    await s.key(keys.f4,contains('╭'),'JobPanel modal over log business');
    await s.key(keys.esc,rows=>!text(rows).includes('╭'),'close preserves log ScrollView focus');
    assert.equal(s.view.rows()[7].text,scrolled[7].text,'scroll offset preserved by modal close');
    await s.key(keys.f3,themeVisible('Light'),'theme preserves log scroll');
    assert.equal(s.view.rows()[7].text,scrolled[7].text,'scroll offset preserved by theme');
    await s.key(keys.f3,themeVisible('Classic'),'Classic after log work');
    s.send(keys.f2,'return to log filter');
    await s.key(paste('record 03'),rows=>text(rows).includes('003 ERROR record 03')&&text(rows).includes('Logs | 1/24'),'log query business predicate');
    await s.key(keys.ctrlA+'\x7f'+keys.tab+' ',contains('Logs | 8/24'),'errors-only AND filter');
    await s.key(keys.tab+keys.tab+' ',rows=>rows[7].text.startsWith('024 ERROR record 24'),'newest radio reverses business order');
    await s.key(keys.f1,contains('Shared !ote'),'scene roundtrip retains task editor data');
    s.send(keys.f5,'start actual first background computation');
    await s.has('Waiting for review: Parse complete','posted half-progress from completed worker');
    assert(s.view.rows()[8].text.startsWith('==========----------'),'useful half progress');
    assert(text(s.view.rows()).includes('01 Done Parse 50005000'),'visible first computed result');
    await s.key(keys.f4,contains('╭'),'modal during review');
    s.send(keys.f6,'modal blocks Continue');
    // F3 forces an observed boundary; do not infer delivery from an idle sleep.
    await s.key(keys.f3,themeVisible('Light'),'modal remains responsive while review paused');
    assert(text(s.view.rows()).includes('Tasks | Review 1/2'),'blocked Continue has no business side effect');
    await s.key(keys.esc,rows=>!text(rows).includes('╭'),'return to review');
    await s.key(keys.f3,themeVisible('Classic'),'Classic before second worker');
    s.send(keys.f6+keys.f4,'resume real worker then open modal');
    await s.wait(rows=>text(rows).includes('Tasks | Done 2/2')&&text(rows).includes('╭'),
      'latest completed state shared by opened modal; either legal completion order');
    await s.key(keys.esc,contains('Tasks | Done 2/2'),'close reveals latest underlying completion');
    const done=await s.has('Tasks | Done 2/2');
    assert(done[8].text.startsWith('===================='),'completed progress');
    assert(text(done).includes('02 Done Render 333383335000'),'visible second computed result');
    assert.equal(done[9].text,'Done'+' '.repeat(76),'long-to-short clears full phase tail');
    assert.equal(at(done,0,9).fg,'named:33','Done awaits acknowledgement in yellow');
    s.send(keys.f4+keys.tab+keys.enter,'open completed task actions');await s.has('Inspect');
    s.send(keys.down+keys.enter,'nested acknowledgement');await s.has('Confirm?');
    s.send(keys.enter,'acknowledge completed work');await s.wait(rows=>!text(rows).includes('Confirm?')&&!text(rows).includes('Inspect'),'confirmation and popup close');
    await s.key(keys.esc,rows=>!text(rows).includes('╭'),'close acknowledged JobPanel');
    const acknowledged=await s.wait(rows=>at(rows,0,9).fg==='named:32','color-only Done turns green');
    assert.deepEqual(acknowledged.map(r=>r.text),done.map(r=>r.text),'acknowledgement changes color only');
    await s.resize(40,12);await s.resize(16,6);const restored=await s.resize(80,24);
    assert.deepEqual(restored.map(r=>r.text),acknowledged.map(r=>r.text),'live resize retains business/editor state');
    await s.stop();
  }finally{await s.save()}
}
if(process.argv[1]===new URL(import.meta.url).pathname){
  prepareTerminalSizeTool();for(const command of ['script','stty'])assert.equal(spawnSync(command,['--version']).status,0);
  const parent=resolve(process.env.CJTUI_APPLICATION_ARTIFACTS??'tests/composition/application/target/evidence');
  await mkdir(parent,{recursive:true});const directory=await mkdtemp(join(parent,'pty-'));
  let failures=0;
  for(const [name,run] of [['minimal',()=>minimal(join(directory,'minimal'))],['startup-wide',()=>startup(join(directory,'startup-wide'),80,24)],
    ['startup-narrow',()=>startup(join(directory,'startup-narrow'),40,12)],
    ['startup-minimum',()=>startup(join(directory,'startup-minimum'),16,6)],
    ['interactions',()=>interactions(join(directory,'interactions'))]]){
    try{await run();console.log(`PASS composition ordinary ${name}`)}
    catch(error){failures++;console.error(`FAIL composition ordinary ${name}: ${error.stack}`)}
  }
  console.log(`Application artifacts=${directory}; failures=${failures}`);if(failures)process.exitCode=1;
}

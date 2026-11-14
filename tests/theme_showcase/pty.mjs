// Synthetic PTY verifies real keys and complete visible rows. GUI PNG acceptance
// is a separate execution role; this test never calls a screenshot a GUI image.
import assert from 'node:assert/strict';
import {spawnSync} from 'node:child_process';
import {mkdir,mkdtemp,readFile,writeFile} from 'node:fs/promises';
import {resolve,join} from 'node:path';
import {Session} from '../composition/application/pty.mjs';
import {keys,paste} from '../composition/application/fixtures.mjs';
import {prepareTerminalSizeTool} from '../support/terminal_frames.mjs';
import {ptyGoldens,modalGoldens,retainedGoldens,palette,f7} from './fixtures.mjs';
import {cellAt,sameGrid,acceptedPalette,checkStyles} from './checks.mjs';
const binary=resolve('examples/theme_showcase/target/release/bin/main');
const artifacts=resolve(process.env.CJTUI_SHOWCASE_ARTIFACTS??'tests/theme_showcase/target/evidence');
const text=rows=>rows.map(row=>row.text).join('\n');
const contains=value=>rows=>text(rows).includes(value);
const fullName=['Dark','Light','High contrast','Classic'];
const fullKey=[keys.f2,keys.f3,keys.f4,keys.f1];

async function startup(dir,w,h){
  const s=new Session(dir,w,h,binary);
  try{
    await s.start();const rows=await s.has('Gallery |');
    sameGrid(rows,ptyGoldens,'Classic',w,h);
    if(w===80)checkStyles(rows,'Classic');
    if(w===16)assert.equal(rows.length,6,'actual small height has no virtual minimum');
    await s.stop();
  }finally{await s.save()}
}
async function fullCycle(dir){
  const s=new Session(dir,80,24,binary);
  try{
    await s.start();sameGrid(await s.has('Gallery | Classic'),ptyGoldens,'Classic',80,24);
    for(let i=0;i<4;i++){
      const name=fullName[i];const rows=await s.key(fullKey[i],r=>acceptedPalette(r,name),`F${i+1} accepted ${name}`);
      sameGrid(rows,ptyGoldens,name,80,24);checkStyles(rows,name);
      const modal=await s.key(keys.f5,r=>text(r).includes(name==='Classic'?'+------------------------------+':'╭──────────────────────────────╮'),`${name} modal`);
      sameGrid(modal,modalGoldens,name,80,24,'modal');
      if(name!=='Classic'){
        for(let x=25;x<57;x++)assert.equal(cellAt(modal,x,16).text,'░',`${name} full lower shadow`);
        for(let y=8;y<16;y++)assert.equal(cellAt(modal,56,y).text,'░',`${name} full right shadow`);
      }
      await s.key(keys.enter,r=>text(r).includes('Inspect')&&text(r).includes('Delete')&&text(r).includes('Confirm'),`${name} PopupMenu`);
      const popup=s.view.rows();
      assert(popup.some(row=>row.cells.some(c=>c.text==='D'&&c.attributes.includes(2))),`${name} disabled Delete dim`);
      assert(popup.some(row=>row.cells.some(c=>c.text==='I'&&c.attributes.includes(4))),`${name} focused Inspect underline`);
      await s.key(keys.esc,r=>!text(r).includes('Inspect')&&text(r).includes('Preview'),`${name} popup close`);
      await s.key(keys.f9,r=>!text(r).includes('Preview'),`${name} modal close`);
      sameGrid(s.view.rows(),ptyGoldens,name,80,24);
    }
    await s.stop();
  }finally{await s.save()}
}
async function retainedState(dir){
  const s=new Session(dir,80,24,binary);
  try{
    await s.start();await s.has('Gallery | Classic');
    await s.key(keys.ctrlA+paste('qrcvzy'),contains('qrcvzy'),'TextInput paste is data');
    s.send(keys.home+'\x1b[1;2C','select exact first grapheme gap 0..1');
    for(let i=0;i<4;i++){
      const name=fullName[i];await s.key(fullKey[i],r=>acceptedPalette(r,name),`${name} with retained input selection`);
      assert(text(s.view.rows()).includes('qrcvzy'),`${name} retains editor data`);
    }
    await s.key('X',contains('Xrcvzy'),'selected first grapheme replaced after four theme switches');
    await s.key(keys.undo,contains('qrcvzy'),'undo history survives all four switches');
    await s.key(keys.tab+' ',contains('[x] Pin'),'checkbox changes business value');
    await s.key(keys.tab.repeat(2)+' ',contains('(*) Name'),'radio selected state changes');
    await s.key(keys.tab+keys.enter,r=>text(r).includes('Gallery | Classic | 1/2'), 'Run preserves pending business work');
    const pending=s.view.rows();
    sameGrid(pending,retainedGoldens,'Classic',80,24,'retained-pending');
    await s.key('\x1b[19~',r=>r[10].text.startsWith('012 INFO record 12')&&r[22].text.startsWith('024 INFO record 24'),
      'F8 uses mounted ScrollView public scrollBy and clamps to offset11');
    const scrolled=s.view.rows().map(row=>row.text);
    sameGrid(s.view.rows(),retainedGoldens,'Classic',80,24,'retained-scrolled');
    for(let i=0;i<4;i++){
      const name=fullName[i];const rows=await s.key(fullKey[i],r=>acceptedPalette(r,name),`${name} retained scroll and pending work`);
      assert.equal(rows[10].text,scrolled[10],`${name} retains exact scroll row`);
      assert.equal(rows[22].text,scrolled[22],`${name} retains bottom scroll row`);
      assert(rows[23].text.includes('1/2'),`${name} retains pending business state`);
      assert(text(rows).includes('[x] Pin')&&text(rows).includes('(*) Name'),`${name} retains checkbox and radio models`);
      assert(text(rows).includes('qrcvzy'),`${name} retains edited text`);
      sameGrid(rows,retainedGoldens,name,80,24,'retained-scrolled');
      assert(cellAt(rows,0,8).attributes.includes(4),`${name} retains focused Run button`);
    }
    // Focus must still return to the original editor, not a rebuilt control.
    await s.key(keys.backtab.repeat(4)+'Y',contains('Yrcvzy'),'editor identity and focus survive theme/scroll business changes');
    await s.key(keys.undo,contains('qrcvzy'),'same controller undo stack survives');
    await s.stop();
  }finally{await s.save()}
}
async function fileReload(dir){
  await mkdir(dir,{recursive:true});
  const selected=join(dir,'selected.toml');
  await writeFile(selected,await readFile('themes/dark.toml'));
  const launcher=join(dir,'launch.sh');
  await writeFile(launcher,`#!/bin/sh\nexec "${binary}" --theme-file "${selected}"\n`,{mode:0o755});
  const s=new Session(join(dir,'session'),80,24,launcher);
  try{
    await s.start();await s.has('Gallery | Classic');
    const pending=await s.key(keys.tab.repeat(4)+keys.enter,r=>r[23].text.includes('1/2'),'pending business before file load');
    sameGrid(pending,ptyGoldens,'Classic',80,24,'pending');
    const dark=await s.key(keys.f6,r=>acceptedPalette(r,'Dark'),'explicit F6 initial file load');
    sameGrid(dark,ptyGoldens,'Dark',80,24,'pending');
    await writeFile(selected,'schema_version = 1\nname = "broken"\n[text]\nforeground = "not-a-color"\n');
    const failed=await s.key(f7,r=>r[9].text.includes('Load failed'),'invalid explicit F7 reload reports failure');
    assert.equal(cellAt(failed,79,22).bg,palette.Dark.bg,'invalid file retains old accepted background');
    assert.equal(cellAt(failed,0,1).fg,palette.Dark.fg,'invalid file retains old accepted foreground');
    assert(failed[23].text.includes('Gallery | Dark | 1/2'),'invalid file retains accepted name and pending business');
    assert(failed[9].text.startsWith('==========----------'),'invalid file retains progress');
    await writeFile(selected,await readFile('themes/light.toml'));
    const light=await s.key(f7,r=>acceptedPalette(r,'Light'),'explicit F7 accepts edited valid file');
    sameGrid(light,ptyGoldens,'Light',80,24,'pending');
    assert(cellAt(light,0,8).attributes.includes(4),'focused Run survives invalid and valid file reload');
    await s.stop();
  }finally{await s.save()}
}
async function absentFile(dir){
  const s=new Session(dir,80,24,binary);
  try{
    await s.start();await s.has('Gallery | Classic');
    const rows=await s.key(keys.f6,r=>r[9].text.includes('No theme file'),'F6 absent file diagnostic is nonfatal');
    assert.equal(cellAt(rows,79,22).bg,palette.Classic.bg,'old palette remains');
    await s.stop();
  }finally{await s.save()}
}

if(process.argv[1]===new URL(import.meta.url).pathname){
  prepareTerminalSizeTool();for(const command of ['script','stty'])assert.equal(spawnSync(command,['--version']).status,0);
  await mkdir(artifacts,{recursive:true});const dir=await mkdtemp(join(artifacts,'pty-'));
  let failures=0;
  for(const [name,run] of [
    ['startup-normal',()=>startup(join(dir,'startup-normal'),80,24)],
    ['startup-small',()=>startup(join(dir,'startup-small'),40,12)],
    ['startup-actual16',()=>startup(join(dir,'startup-actual16'),16,6)],
    ['four-theme-modal-popup',()=>fullCycle(join(dir,'four-theme-modal-popup'))],
    ['retained-state',()=>retainedState(join(dir,'retained-state'))],
    ['file-reload',()=>fileReload(join(dir,'file-reload'))],
    ['unconfigured-file',()=>absentFile(join(dir,'unconfigured-file'))]
  ]){
    try{await run();console.log(`PASS showcase PTY ${name}`)}
    catch(error){failures++;console.error(`FAIL showcase PTY ${name}: ${error.stack}`)}
  }
  console.log(`Showcase PTY raw artifacts=${dir}; failures=${failures}`);
  if(failures)process.exitCode=1;
}

// TASK027-R1: real F2 input while a modal or its owned popup holds the domain.
// Reuses the existing PTY/Screen oracle and the frozen literal gallery grids.
import assert from 'node:assert/strict';
import {spawnSync} from 'node:child_process';
import {mkdir,mkdtemp} from 'node:fs/promises';
import {resolve,join} from 'node:path';
import {Session} from '../composition/application/pty.mjs';
import {keys} from '../composition/application/fixtures.mjs';
import {ptyGoldens,modalGoldens} from './fixtures.mjs';
import {acceptedPalette,matchesGrid,sameGrid} from './checks.mjs';

const binary=resolve(process.env.CJTUI_SHOWCASE_BINARY??'examples/theme_showcase/target/release/bin/main');
const artifacts=resolve(process.env.CJTUI_SHOWCASE_ARTIFACTS??'tests/theme_showcase/target/evidence');
const text=rows=>rows.map(row=>row.text).join('\n');
const popupVisible=rows=>['Inspect','Delete','Confirm'].every(label=>text(rows).includes(label));

async function controlledClassic(s){
  await s.start();
  sameGrid(await s.has('Gallery | Classic'),ptyGoldens,'Classic',80,24);
  sameGrid(await s.key(keys.f2,r=>acceptedPalette(r,'Dark'),'F2 delivered before modal'),ptyGoldens,'Dark',80,24);
  sameGrid(await s.key(keys.f1,r=>acceptedPalette(r,'Classic'),'F1 delivered before modal'),ptyGoldens,'Classic',80,24);
  sameGrid(await s.key(keys.f5,r=>text(r).includes('+------------------------------+'),'Classic Preview opens'),
    modalGoldens,'Classic',80,24,'modal');
}

async function previewSwitch(directory){
  const s=new Session(directory,80,24,binary);
  try{
    await controlledClassic(s);
    const changed=await s.key(keys.f2,r=>acceptedPalette(r,'Dark')&&matchesGrid(r,modalGoldens,'Dark',80,24,'modal'),
      'F2 accepts Dark while Preview stays open');
    sameGrid(changed,modalGoldens,'Dark',80,24,'modal');
    sameGrid(await s.key(keys.f9,r=>matchesGrid(r,ptyGoldens,'Dark',80,24),'F9 closes Preview'),ptyGoldens,'Dark',80,24);
    await s.stop();
  }finally{await s.save()}
}

async function popupSwitch(directory){
  const s=new Session(directory,80,24,binary);
  try{
    await controlledClassic(s);
    await s.key(keys.enter,popupVisible,'owned PopupMenu opens');
    const changed=await s.key(keys.f2,r=>acceptedPalette(r,'Dark')&&popupVisible(r)&&
      text(r).includes('Theme sample')&&text(r).includes('╭──────────────────────────────╮'),
      'F2 accepts Dark while owned PopupMenu stays open');
    assert(popupVisible(changed),'popup remains mounted with all entries');
    assert(text(changed).includes('╭──────────────────────────────╮'),'Preview receives Dark rounded border');
    assert(changed.some(row=>row.cells.some(c=>c.text==='D'&&c.attributes.includes(2))),
      'owned popup disabled Delete remains dim');
    await s.key(keys.down,r=>popupVisible(r)&&r.some(row=>row.cells.some(c=>c.text==='C'&&c.attributes.includes(4))),
      'popup navigation skips disabled Delete after theme');
    sameGrid(await s.key(keys.enter,r=>matchesGrid(r,modalGoldens,'Dark',80,24,'modal'),'Confirm closes popup'),
      modalGoldens,'Dark',80,24,'modal');
    sameGrid(await s.key(keys.f9,r=>matchesGrid(r,ptyGoldens,'Dark',80,24),'F9 closes owning Preview'),ptyGoldens,'Dark',80,24);
    await s.stop();
  }finally{await s.save()}
}

if(process.argv[1]===new URL(import.meta.url).pathname){
  for(const command of ['script','stty'])assert.equal(spawnSync(command,['--version']).status,0);
  await mkdir(artifacts,{recursive:true});const directory=await mkdtemp(join(artifacts,'modal-key-'));
  let failures=0;
  for(const [name,run] of [
    ['preview',()=>previewSwitch(join(directory,'preview'))],
    ['owned-popup',()=>popupSwitch(join(directory,'owned-popup'))]
  ]){
    try{await run();console.log(`PASS TASK027-R1 ${name}`)}
    catch(error){failures++;console.error(`FAIL TASK027-R1 ${name}: ${error.stack}`)}
  }
  console.log(`TASK027-R1 raw artifacts=${directory}; failures=${failures}`);
  if(failures)process.exitCode=1;
}

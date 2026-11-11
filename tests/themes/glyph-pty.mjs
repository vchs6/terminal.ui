#!/usr/bin/env node
// Controlled real PTY + the existing glyph fixture engine, never real kernel VT.
import assert from 'node:assert/strict';
import { spawn } from 'node:child_process';
import { mkdir, readFile, writeFile } from 'node:fs/promises';
import { resolve, join } from 'node:path';
import { fileURLToPath } from 'node:url';
const here = fileURLToPath(new URL('.', import.meta.url));
const control = process.argv[2] === 'control';
const artifacts = resolve(process.argv[3]);
const binary = resolve(here, control ? 'glyph-language/target/release/bin/main' : 'glyph-session/target/release/bin/main');
const delay = ms => new Promise(resolve => setTimeout(resolve, ms));
const quote = value => `'${value.replaceAll("'", "'\\''")}'`;
const read = async path => { try { return await readFile(path, 'utf8'); } catch { return ''; } };
const fields = text => Object.fromEntries(text.trim().split('\n').map(line => { const i=line.indexOf('=');return [line.slice(0,i),line.slice(i+1)]; }));
// Inspect complete written rows only; this does not implement a terminal renderer.
const rows = bytes => [...bytes.toString('utf8').matchAll(/\x1b\[(\d+);1H([^\x1b]*(?:\x1b\[[0-9;]*m[^\x1b]*)*)/gu)]
  .map(m => ({ row:Number(m[1]),text:m[2].replaceAll(/\x1b\[[0-9;]*m/gu,'') }));
async function until(predicate,label) {
  const deadline=Date.now()+10000;
  while(Date.now()<deadline) { if(await predicate()) return;await delay(10); }
  throw Error(`timeout ${label}`);
}
// Exact, independently typed 5-column by 8-row goldens.
const unicode = ['     ','…    ','A…   ','AB…  ','ABC… ','ABC…q','éBC… ','👩‍💻   '];
const ascii = ['     ','.    ','..   ','...  ','A... ','A...q','?... ','??   '];
const mappedMissing = ['     ','.    ','..   ','...  ','A... ','A...q','é... ','??   '];
const mappedPresent = ['     ','…    ','A…   ','AB…  ','ABC… ','ABC…q','éBC… ','??   '];
const conservative = ['     ','…    ','A…   ','AB…  ','ABC… ','ABC…q','éBC… ','??   '];
const cases = control ? [
  ['control-unknown','real','Auto','é …  ',false],
  ['control-mapped','mapped','Auto','é …  ',true],
  ['control-missing','no-ellipsis','Auto','é ?  ',true]
] : [
  ['unknown-auto','real','Auto',conservative,false],
  ['unknown-unicode','real','Unicode',unicode,false],
  ['unknown-ascii','real','Ascii',ascii,false],
  ['mapped-present','mapped','Auto',mappedPresent,true],
  ['mapped-missing','no-ellipsis','Auto',mappedMissing,true],
  ['mapped-unicode','no-ellipsis','Unicode',unicode,true],
  ['mapped-ascii','no-ellipsis','Ascii',ascii,true]
];
await mkdir(artifacts,{recursive:true});
for(const [name,scenario,mode,expected,known] of cases) {
  const dir=join(artifacts,name);await mkdir(dir,{recursive:true});
  const report=join(dir,'report.txt'),capture=join(dir,'writes.raw'),trace=join(dir,'syscalls.txt');
  const wrapper=join(dir,'session.sh');
  await writeFile(wrapper,'#!/bin/sh\nstty rows 8 cols 5\nstty -g > "$2/before"\n"$1" < /dev/tty &\np=$!\necho "$p" > "$2/pid"\nwait "$p"\nr=$?\nstty -g > "$2/after"\nexit "$r"\n');
  const child=spawn('script',['--quiet','--return','--flush','--command',`sh ${quote(wrapper)} ${quote(binary)} ${quote(dir)}`,'/dev/null'],{
    stdio:['pipe','pipe','pipe'],env:{...process.env,TERM:'dumb',COLORTERM:'',
      CJTUI_THEME_GLYPH_MODE:mode,CJTUI_THEME_GLYPH_REPORT:report,
      ...(control ? {CJTUI_THEME_GLYPH_CONTROL_PTY:'1'} : {}),
      CJTUI_GLYPH_TEST_NATIVE:scenario,CJTUI_GLYPH_TEST_TRACE:trace,CJTUI_GLYPH_TEST_CAPTURE:capture}
  });
  let stdout=Buffer.alloc(0),stderr='',finished=false,code,signal,serial=0;
  child.stdout.on('data',data=>{stdout=Buffer.concat([stdout,data]);});
  child.stderr.on('data',data=>{stderr+=data;});
  child.on('close',(c,s)=>{code=c;signal=s;finished=true;});
  const sync=async(action='')=>{
    serial++;child.stdin.write(action+'p');
    await until(async()=> (await read(report)).includes(`serial=${serial}\n`),name+' fence');
    return fields(await read(report));
  };
  try {
    await until(async()=>rows(Buffer.from(await read(capture))).some(row=>row.row===8),name+' full frame');
    const state=await sync();
    assert.equal(state.nativeVt,String(known));assert.equal(state.mapKnown,String(known));
    assert.equal(state.entryCount,known?'104':'0');
    assert.equal(state.source,known?'linux-vt-unimap':'unknown');
    assert.equal(state.reason,known?'':'not-concrete-linux-vt');assert.equal(state.nativeError,'0');
    const initial=rows(await readFile(capture));
    if(control) assert.equal(initial.find(row=>row.row===1)?.text,expected,name+' current public projection');
    else assert.deepEqual(initial.slice(0,8).map(row=>row.text),expected,name+' typed scene golden');
    if(!control && name==='mapped-missing') {
      const mounted=state.mounted;
      const offset=(await readFile(capture)).length;
      const switched=await sync('u');
      assert(rows((await readFile(capture)).subarray(offset)).some(row=>row.row===5&&row.text==='ABC… '),'setter wakes and budgets Unicode prefix');
      assert(Number(switched.measures)>Number(state.measures));assert.equal(switched.mounted,mounted);
      const before=(await readFile(capture)).length;
      const repeated=await sync('u');
      assert.equal((await readFile(capture)).length,before,'same setter is byte silent');
      assert.equal(repeated.frames,switched.frames,'same setter does not dirty cache');
      const restoredAt=(await readFile(capture)).length;
      await sync('o');
      assert(rows((await readFile(capture)).subarray(restoredAt)).some(row=>row.row===5&&row.text==='A... '),'Auto restores mapped missing marker budget');
    }
    child.stdin.write('q');await until(()=>finished,name+' exit');
    assert.equal(code,0);assert.equal(signal,null);
    assert.deepEqual(stdout,await readFile(capture),'actual write capture equals PTY bytes');
    assert.equal((await read(join(dir,'before'))).trim(),(await read(join(dir,'after'))).trim(),'termios restored');
    const calls=await read(trace);
    assert.equal((calls.match(/unimap capacity=/gu)??[]).length,known?1:0,'detect once and never offline');
    if(scenario==='no-ellipsis') assert(calls.includes('theme-filter ellipsis-removed=1 pairs=104\n'),'filter actual returned map');
    if(!control) {
      const offlineDefault='     \n…    \nA…   \nAB…  \nABC… \nABC…q\néBC… \n👩‍💻   ';
      const offlineAscii='     \n.    \n..   \n...  \nA... \nA...q\né... \n👩‍💻   ';
      assert.equal(await read(report+'.default'),offlineDefault,'device profile does not pollute offline default');
      assert.equal(await read(report+'.auto'),offlineDefault,'offline Auto Unicode independent');
      assert.equal(await read(report+'.ascii'),offlineAscii,'offline Ascii generates dots but retains body');
    }
    console.log(`PASS ${name}`);
  } finally {
    await writeFile(join(dir,'stdout.raw'),stdout);await writeFile(join(dir,'stderr.txt'),stderr);
    await writeFile(join(dir,'result.json'),JSON.stringify({code,signal,scenario,mode,expected,binary},null,2)+'\n');
    if(!finished) { child.kill('SIGKILL');child.stdin.destroy(); }
  }
}

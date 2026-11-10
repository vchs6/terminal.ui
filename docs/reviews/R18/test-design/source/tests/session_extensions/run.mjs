#!/usr/bin/env node
import assert from 'node:assert/strict';
import { spawn, spawnSync } from 'node:child_process';
import { mkdtemp, mkdir, readFile, writeFile } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import { resolve, join } from 'node:path';
import { sessionCases } from './cases.mjs';
import { common, verifyHeadless, verifyLive, parseResults, wrap, golden, hex } from './oracle.mjs';
const binary=resolve(process.argv[2]);
const selected=process.argv.slice(3);
const artifacts=resolve(process.env.CJTUI_SESSION_ARTIFACTS??await mkdtemp(join(tmpdir(),'cjtui-session-')));
await mkdir(artifacts,{recursive:true});
const read=async path=>{try{return await readFile(path);}catch{return Buffer.alloc(0);}};
const quote=s=>`'${s.replaceAll("'","'\\''")}'`;
const delay=ms=>new Promise(r=>setTimeout(r,ms));
const matrix=sessionCases;
async function run(config,index) {
  const {scenario,route,offset=0}=config;
  const name=`${String(index).padStart(3,'0')}-${scenario}-${route}-${offset}${config.uiFail?'-aggregate':''}`;
  const dir=join(artifacts,name); await mkdir(dir);
  const env={...process.env,TERM:'xterm-256color',COLORTERM:'truecolor',TMUX:'name-is-not-evidence',STY:'name-is-not-evidence',CJTUI_SESSION_CASE:scenario,CJTUI_SESSION_ROUTE:route,CJTUI_SESSION_OFFSET:String(offset),CJTUI_SESSION_RESULTS:join(dir,'results.tsv'),CJTUI_SESSION_NATIVE:join(dir,'native.tsv'),CJTUI_SESSION_WIRE:join(dir,'wire.bin'),CJTUI_SESSION_ALL_WIRE:join(dir,'all-wire.bin'),CJTUI_SESSION_UI_FAIL:config.uiFail?'1':'0',CJTUI_SESSION_CLOSE_FAIL:config.closeFail?'1':'0',CJTUI_SESSION_CALLBACK_FAIL:config.callbackFail?'1':'0'};
  await writeFile(join(dir,'launch.json'),JSON.stringify({binary,config,utc:new Date().toISOString(),term:env.TERM,grid:[100,28]},null,2));
  if(scenario==='headless') {
    const result=spawnSync(binary,[],{env,encoding:'utf8',timeout:15000});
    await writeFile(join(dir,'stdout.txt'),result.stdout??''); await writeFile(join(dir,'stderr.txt'),result.stderr??'');
    assert.equal(result.status,0,`headless actual binary exit: ${result.stderr}`);
    assert.equal(result.stdout,'','headless no terminal output');
    assert(!(await read(env.CJTUI_SESSION_NATIVE)).toString().includes('open\t'),'headless never opens native device');
    verifyHeadless(parseResults((await read(env.CJTUI_SESSION_RESULTS)).toString()),await read(env.CJTUI_SESSION_WIRE));
    return;
  }
  const wrapper=join(dir,'session.sh');
  await writeFile(wrapper,'#!/bin/sh\nstty rows 28 cols 100\nstty -g > "$2/before"\ntty > "$2/tty"\n"$1" < /dev/tty &\np=$!\necho "$p" > "$2/pid"\nwait "$p"\nstatus=$?\nstty -g > "$2/after"\nexit "$status"\n');
  const child=spawn('script',['--quiet','--return','--flush','--command',`sh ${quote(wrapper)} ${quote(binary)} ${quote(dir)}`,'/dev/null'],{stdio:['pipe','pipe','pipe'],env});
  let stdout=Buffer.alloc(0),stderr='',finished=false,code,signal,pid;
  child.stdout.on('data',b=>stdout=Buffer.concat([stdout,b])); child.stderr.on('data',b=>stderr+=b);
  child.on('close',(c,s)=>{code=c;signal=s;finished=true;}); child.on('error',e=>{stderr+=e.message;finished=true;});
  async function until(predicate,label) {const deadline=Date.now()+12000;while(Date.now()<deadline){if(await predicate())return;if(finished)throw new Error(`early exit ${label}: ${stderr}; ${stdout.toString()}`);await delay(15);}throw new Error(`timeout ${label}`);}
  try {
    await until(async()=>{pid=Number((await read(join(dir,'pid'))).toString().trim());return pid>0;},'PID');
    await until(()=>stdout.includes(Buffer.from('CJTUI_SESSION_READY')),'real first frame');
    for(const forbidden of ['\x1b]52;','\x1b]2;','\x1b]0;','\x1b]1;','\x1b[22;2t','\x1b[23;2t']) assert(!stdout.includes(Buffer.from(forbidden)),'no unsolicited session protocol during startup');
    child.stdin.write('x');
    if(scenario==='ledger-error'||scenario==='ledger-cancel') {
      await until(async()=>(await read(env.CJTUI_SESSION_WIRE)).length>=wrap(hex(golden.saveHex),route).length+wrap(Buffer.from('\x1b]2;A\x07'),route).length*2,'two titles');
      child.stdin.write(scenario==='ledger-error'?'e':'\x03');
    }
    const deadline=Date.now()+15000;while(!finished&&Date.now()<deadline)await delay(15);
    assert(finished,'run closes at safe boundary'); assert.equal(signal,null,'no forced termination'); assert.equal(code,0,`test consumer exit ${code}: ${stderr}`);
    const rows=parseResults((await read(env.CJTUI_SESSION_RESULTS)).toString()); common(rows);
    const before=(await read(join(dir,'before'))).toString().trim(),after=(await read(join(dir,'after'))).toString().trim();
    assert(before&&after,'both actual termios snapshots'); assert.equal(after,before,'exact termios restored');
    const native=(await read(env.CJTUI_SESSION_NATIVE)).toString();
    verifyLive(rows,await read(env.CJTUI_SESSION_WIRE),native,scenario,route,offset,await read(env.CJTUI_SESSION_ALL_WIRE));
    if(config.uiFail) assert.match(rows.get('run.error'),/SESSION_UI_CLEANUP_SENTINEL/);
    if(config.closeFail) assert.match(rows.get('run.error'),/terminal restore failed/);
    if(scenario==='ledger-error') assert.match(rows.get('run.primary')??rows.get('run.error'),/SESSION_CALLBACK_SENTINEL/);
    if(config.uiFail && config.closeFail) {
      assert(rows.has('run.primary'),'cleanup aggregation preserves public UICleanupException shape');
      assert(Number(rows.get('run.extras')) >= 2,'both cleanup failures survive');
      const extras=[...rows].filter(([key])=>/^run\.extra[0-9]+$/.test(key)).map(([,value])=>value).join('\n');
      assert.match(extras,/SESSION_UI_CLEANUP_SENTINEL/);assert.match(extras,/terminal restore failed/);
    }
    if(config.callbackFail) assert(rows.has('run.primary')&&!rows.get('run.primary').includes('SESSION_LATE_CALLBACK_SENTINEL'),'first device error remains primary');
    for(const line of native.split('\n').filter(l=>l.startsWith('signal-restored\t'))) assert.equal(line.split('\t')[2],'1','original signal handler/mask restored');
    assert.equal(rows.get('run.failed'),scenario==='ledger-error'||config.closeFail||(/^fault/.test(scenario)&&!['fault-eintr','fault-short','fault-allocation'].includes(scenario))?'true':'false','expected run failure shape');
    await writeFile(join(dir,'check.json'),JSON.stringify({passed:true,code,signal,utc:new Date().toISOString()}));
  } finally {
    await writeFile(join(dir,'session.raw'),stdout);await writeFile(join(dir,'stderr.txt'),stderr);
    if(!finished){if(pid){try{process.kill(pid,'SIGKILL');}catch{}}child.kill('SIGKILL');}child.stdin.destroy();
  }
}
let failures=0,count=0;
assert.equal(spawnSync('script',['--version']).status,0,'existing util-linux script');
const chosen=selected.length&&selected[0]!=='all'?matrix.filter(c=>selected.includes(c.scenario)):matrix;
assert(chosen.length,'requested scenario exists');
for(const [index,config] of chosen.entries()) {
  try {await run(config,index);console.log(`PASS ${JSON.stringify(config)}`);}
  catch(error){failures++;console.error(`FAIL ${JSON.stringify(config)} ${error.stack}`);}
  count++;
}
await writeFile(join(artifacts,'summary.json'),JSON.stringify({binary,cases:count,failures,utc:new Date().toISOString()},null,2));
console.log(`session-extensions cases=${count} failures=${failures} artifacts=${artifacts}`);
if(failures)process.exitCode=1;

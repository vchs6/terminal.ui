#!/usr/bin/env node
// Exact literal transactions plus existing independent row/style interpreter.
import assert from 'node:assert/strict';
import {spawn, spawnSync} from 'node:child_process';
import {mkdir, readFile, writeFile, readdir, rm} from 'node:fs/promises';
import {resolve, join} from 'node:path';
import {fileURLToPath} from 'node:url';
import {Screen} from '../colors/pty.mjs';

const binary=resolve(process.argv[2]);
const sizeTool=fileURLToPath(new URL('./native/terminal-size',import.meta.url));
const artifacts=resolve(process.env.CJTUI_RECOVERY_ARTIFACTS??'/tmp/cjtui-output-recovery');
await mkdir(artifacts,{recursive:true});
const read=async p=>{try{return await readFile(p);}catch(e){if(e.code==='ENOENT')return Buffer.alloc(0);throw e;}};
const quote=s=>`'${s.replaceAll("'","'\\''")}'`;
const E='\x1b[';
const full=Buffer.from(E+'0m'+E+'1;1HAé  '+E+'0m');
const short=Buffer.from(E+'0m'+E+'1;1Hé   '+E+'0m');
const style=Buffer.from(E+'0m'+E+'1;1H'+E+'0m'+E+'38;2;1;128;254m'+E+'1mAé'+E+'0m  '+E+'0m');
const mono=Buffer.from(E+'0m'+E+'1;1H'+E+'0m'+E+'1mAé'+E+'0m  '+E+'0m');
const protocols={query:Buffer.from(E+'?25$p'),paste:Buffer.from(E+'?2004h'),pasteRestore:Buffer.from(E+'?2004l'),
  save:Buffer.from(E+'22;2t'),set:Buffer.from('\x1b]2;é\x07'),restore:Buffer.from(E+'23;2t'),
  clipboard:Buffer.from('\x1b]52;c;w6k=\x07'),caret:Buffer.from(E+'1;3H'),caretHide:Buffer.from(E+'?25l'),caretRestore:Buffer.from(E+'?25h')};
const outcomes=[];
async function run(config) {
  const {name,scenario='frame',mode=0,offset=0,target=1,startup=false,reply=false,extra=false}=config;
  const directory=join(artifacts,name); await mkdir(directory);
  const env={...process.env,TERM:'xterm-256color',COLORTERM:'truecolor',CJTUI_RECOVERY_DIR:directory,
    CJTUI_RECOVERY_CASE:scenario,CJTUI_RECOVERY_MODE:String(mode),CJTUI_RECOVERY_OFFSET:String(offset),CJTUI_RECOVERY_TARGET:String(target),
    CJTUI_RECOVERY_REOPEN:mode===1||mode===4?'1':'0',CJTUI_RECOVERY_UI_FAIL:extra?'1':'0',CJTUI_SESSION_CLOSE_FAIL:extra?'1':'0',
    CJTUI_SESSION_NATIVE:join(directory,'native.tsv'),CJTUI_SESSION_ALL_WIRE:join(directory,'all-wire.bin')};
  if(startup)env.CJTUI_RECOVERY_STARTUP='1';else delete env.CJTUI_RECOVERY_STARTUP;
  const wrapper=join(directory,'launch.sh');
  await writeFile(wrapper,'#!/bin/sh\nstty rows 1 cols 4\nstty -g > "$2/before"\ntty > "$2/tty"\n"$1" < /dev/tty &\np=$!\necho "$p" > "$2/pid"\nwait "$p"\nstatus=$?\nstty -g > "$2/after"\nexit "$status"\n');
  await writeFile(join(directory,'launch.json'),JSON.stringify({binary,config,utc:new Date().toISOString(),TERM:env.TERM,grid:[4,1]},null,2));
  const child=spawn('script',['-q','-e','-f','-c',`sh ${quote(wrapper)} ${quote(binary)} ${quote(directory)}`,'/dev/null'],{env,stdio:['pipe','pipe','pipe']});
  let raw=Buffer.alloc(0),stderr='',finished=false,code,signal,pid,sameCounts;
  child.stdout.on('data',b=>{raw=Buffer.concat([raw,b]);});child.stderr.on('data',b=>stderr+=b);
  child.on('close',(c,s)=>{finished=true;code=c;signal=s;});
  child.on('error',e=>{finished=true;stderr+=e.message;});
  const until=async (predicate,label)=>{const deadline=Date.now()+7000;while(Date.now()<deadline){if(await predicate())return;if(finished)throw Error(`early exit ${label}: ${stderr}`);await new Promise(r=>setTimeout(r,5));}throw Error(`deadline ${label}`);};
  const transactions=async()=>{const names=(await readdir(directory)).filter(n=>/^transaction-/.test(n)).sort();return Promise.all(names.map(n=>read(join(directory,n))));};
  try {
    await until(async()=>{pid=Number((await read(join(directory,'pid'))).toString());return pid>0;},'PID');
    const fatal=mode===1||mode===4;
    let armStart=0;
    if(!startup) {
      await until(()=>raw.includes(full),'literal complete first frame');
      if(reply){child.stdin.write(E+'?25;1$y');await until(async()=>raw.includes(Buffer.from(E+'?25h'))||raw.includes(Buffer.from(E+'?25l')),'known original mode');}
      armStart=(await transactions()).length;
      child.stdin.write('x');
    }
    if(!fatal || config.cleanup) {
      await until(async()=>{const n=(await read(env.CJTUI_SESSION_NATIVE)).toString();return n.includes('sequence-result\t0\t');},'successful armed writer');
      child.stdin.write('h');await until(async()=>(await read(join(directory,'ack'))).length>0,'event fence');
      if(config.normal) {
        const before=await transactions();
        await rm(join(directory,'ack'));child.stdin.write('sh');await until(async()=>(await read(join(directory,'ack'))).length>0,'same target fence');
        const after=await transactions();
        sameCounts=[before.length,after.length];
        if(scenario==='style') {
          await rm(join(directory,'ack'));child.stdin.write('ch');await until(async()=>(await read(join(directory,'ack'))).length>0,'effective profile fence');
          assert.deepEqual((await transactions()).at(-1),mono,'Monochrome removes RGB while preserving bold and exact blanks');
          const beforeRepeat=(await transactions()).length;
          await rm(join(directory,'ack'));child.stdin.write('ch');await until(async()=>(await read(join(directory,'ack'))).length>0,'same profile fence');
          assert.equal((await transactions()).length,beforeRepeat,'same effective profile does not repaint');
        }
        if(scenario==='frame') {
          const tty=(await read(join(directory,'tty'))).toString().trim();
          for(const [cols,text] of [[2,'é '],[4,'é   ']]) {
            const rawOffset=raw.length;
            const resized=spawnSync(sizeTool,[tty,String(cols),'1'],{encoding:'utf8'});
            assert.equal(resized.status,0,resized.stderr);assert.equal(resized.stdout,`${cols} 1\n`);
            await writeFile(join(directory,`size-${cols}.json`),JSON.stringify({cols,rows:1,readback:resized.stdout,utc:new Date().toISOString()}));
            const expected=Buffer.from(E+'0m'+E+'1;1H'+text+E+'0m');
            await until(()=>raw.subarray(rawOffset).includes(expected),'complete coherent resize target');
            assert.deepEqual((await transactions()).at(-1),expected,'resize full target literal grid including blanks');
          }
        }
      }
      child.stdin.write('q');
    }
    await until(()=>finished,'normal direct binary exit');
    assert.equal(code,0,`consumer true exit ${stderr}; ${(await read(join(directory,'consumer-error'))).toString()}`);assert.equal(signal,null);
    const before=(await read(join(directory,'before'))).toString().trim(),after=(await read(join(directory,'after'))).toString().trim();assert(before&&after);assert.equal(after,before,'exact termios restored');
    const result=(await read(join(directory,'result'))).toString().split('\n');
    assert.equal(result[0],String(fatal),'actual Application.run failure shape');
    assert.equal(result[2],'1','UI cleanup once if mounted');assert.equal(result[3],'0/0/0/0','public runtime resources released');
    const native=(await read(env.CJTUI_SESSION_NATIVE)).toString();
    assert(native.includes('close\t0\t'),'native close executed');
    assert(!native.includes('poll-after-fault'),'fatal safe boundary precedes another input poll');
    for(const line of native.split('\n').filter(l=>l.startsWith('signal-restored')))assert.equal(line.split('\t')[2],'1');
    const expectedAction={frame:short,style,caret:protocols.caret,title:protocols.save,clipboard:protocols.clipboard}[scenario];
    if(fatal) {
      const expectedPrimary=config.cleanup&&scenario==='title'?'host title restore failed; visual title state not confirmed':
        offset>0?'terminal write failed; ParserUnsynchronized; visual state not restored':'terminal write failed';
      assert.equal(result[1],expectedPrimary,'first exact device/cleanup exception');
      assert(native.includes(`writer-state\t${offset>0?1:0}\t${offset}\n`),'exact emitted byte count and unsafe distinction');
      const all=await read(env.CJTUI_SESSION_ALL_WIRE);
      const tx=await transactions();
      const selected=startup?target-1:armStart+target-1;
      assert(tx[selected],`selected transaction ${selected}`);
      assert.deepEqual(tx[selected],config.bytes??expectedAction,'fault target is the independently literal valid normal transaction');
      if(offset>0) {
        const prefix=startup?Buffer.concat(tx.slice(0,selected)):Buffer.concat(tx.slice(armStart,selected));
        assert.deepEqual(all,Buffer.concat([prefix,tx[selected].subarray(0,offset)]),'partial fatal emits exact prefix then no frame/mode/title/clipboard/recovery bytes');
      }
      const reopen=(await read(join(directory,'reopen'))).toString();assert.equal(reopen.split('\n')[0],String(offset>0),'same-process reopen only refused after actual partial');
      if(extra){assert(result.slice(4).join('\n').includes('OUTPUT_UI_CLEANUP_SENTINEL'));assert(result.slice(4).join('\n').includes('terminal restore failed'));}
    } else {
      const tx=await transactions();
      assert.deepEqual(tx[armStart],expectedAction,'successful/retried target is literal normal transaction');
      assert.deepEqual(await read(env.CJTUI_SESSION_ALL_WIRE),Buffer.concat(tx.slice(armStart)),
        'success means every candidate byte actually reached the device, including short/EINTR retry');
    }
    const tx=await transactions();
    await writeFile(join(directory,'check.json'),JSON.stringify({passed:!sameCounts||sameCounts[0]===sameCounts[1],code,signal,transactions:tx.map(b=>b.toString('hex')),utc:new Date().toISOString()},null,2));
    if(sameCounts) {
      await writeFile(join(directory,'same-frame.json'),JSON.stringify({before:sameCounts[0],after:sameCounts[1],expectedAdditionalTransactions:0}));
      assert.equal(sameCounts[1],sameCounts[0],'same frame/profile/caret emits zero screen bytes');
    }
    outcomes.push({name,passed:true,code});return tx;
  } finally {
    await writeFile(join(directory,'session.raw'),raw);await writeFile(join(directory,'stderr.txt'),stderr);await writeFile(join(directory,'exit.json'),JSON.stringify({code,signal,finished}));
    if(!finished){if(pid)try{process.kill(pid,'SIGKILL');}catch{}child.kill('SIGKILL');}child.stdin.destroy();
  }
}

// These rows/styles are hand-written before native output can enumerate cut positions.
function verifyGrid(bytes,text,emphasized=false){
  const screen=new Screen(4,1);screen.feed(bytes);const rows=screen.finalize();assert.equal(rows[0].text,text);
  const first=rows[0].cells[0];assert.equal(first.fg,emphasized?'rgb:1,128,254':'default');assert.deepEqual(first.attributes,emphasized?[1]:[]);
}
verifyGrid(full,'Aé  ');verifyGrid(short,'é   ');verifyGrid(style,'Aé  ',true);
// Literal negative controls: tail corruption and a post-fault CAN must be rejected.
assert.throws(()=>verifyGrid(Buffer.from(E+'0m'+E+'1;1HéX  '+E+'0m'),'é   '));
assert.throws(()=>assert.deepEqual(Buffer.from('a\x18'),Buffer.from('a')));
const sizeBuild=spawnSync('cc',['-std=c11','-Wall','-Wextra','-Werror',fileURLToPath(new URL('../support/terminal_size.c',import.meta.url)),'-o',sizeTool],{encoding:'utf8'});
assert.equal(sizeBuild.status,0,sizeBuild.stderr);
const pure=join(artifacts,'pure');await mkdir(pure);
const p=spawnSync(binary,[],{env:{...process.env,CJTUI_RECOVERY_DIR:pure,CJTUI_RECOVERY_CASE:'pure'},encoding:'utf8'});
await writeFile(join(pure,'exit.json'),JSON.stringify({code:p.status,signal:p.signal,error:p.error?.message}));await writeFile(join(pure,'stderr'),p.stderr??'');await writeFile(join(pure,'stdout'),p.stdout??'');assert.equal(p.status,0,(await read(join(pure,'consumer-error'))).toString());
let failures=0;
const only=process.argv.find(a=>a.startsWith('--only='))?.slice(7);
const perform=async config=>{if(only&&!config.name.startsWith(only))return;try{return await run(config);}catch(e){failures++;outcomes.push({name:config.name,passed:false,error:e.stack});console.error(`FAIL ${config.name}: ${e.stack}`);}};
const normal={};
const supplement=process.argv.includes('--supplement');
for(const scenario of supplement?['frame','style']:['frame','style','caret','title','clipboard']) {
  const tx=await perform({name:`normal-${scenario}`,scenario,normal:true});if(tx)normal[scenario]=tx;
}
if(normal.frame){assert.deepEqual(normal.frame[0],protocols.paste);assert.deepEqual(normal.frame[1],protocols.query);assert.deepEqual(normal.frame[2],full);assert.deepEqual(normal.frame[3],short);verifyGrid(normal.frame[3],'é   ');}
if(normal.style){assert.deepEqual(normal.style[3],style);verifyGrid(normal.style[3],'Aé  ',true);}
if(normal.caret)assert.deepEqual(normal.caret[3],protocols.caret);
if(normal.title){assert.deepEqual(normal.title[3],protocols.save);assert.deepEqual(normal.title[4],protocols.set);assert(normal.title.some(b=>b.equals(protocols.restore)));}
if(normal.clipboard)assert.deepEqual(normal.clipboard[3],protocols.clipboard);
if(process.argv.includes('--normal')) { /* Only the bounded normal baseline, useful while authoring. */ }
else {
  const cases=[{scenario:'frame',bytes:short},{scenario:'style',bytes:style},{scenario:'caret',bytes:protocols.caret},
    {scenario:'title',bytes:protocols.save},{scenario:'title',bytes:protocols.set,target:2},{scenario:'clipboard',bytes:protocols.clipboard},
    {scenario:'frame',bytes:protocols.paste,startup:true,target:1},{scenario:'frame',bytes:protocols.query,startup:true,target:2},
    {scenario:'frame',bytes:full,startup:true,target:3}];
  for(const c of supplement?[]:cases)for(const mode of [1,4])for(let offset=0;offset<c.bytes.length;offset++) {
    await perform({...c,mode,offset,name:`cut-${c.scenario}-${c.startup?'startup':'action'}-${c.target??1}-${mode}-${offset}`});
  }
  if(!supplement) {
    for(const scenario of ['frame','style','caret','title','clipboard'])for(const mode of [2,6])await perform({scenario,mode,name:`retry-${scenario}-${mode}`});
    await perform({scenario:'frame',mode:5,name:'allocation-full-retry'});
    await perform({scenario:'frame',mode:1,offset:1,extra:true,name:'primary-plus-ui-native-cleanup'});
  }
  const known=await perform({name:'normal-known-hidden-restored',reply:true});
  if(known){assert.deepEqual(known[3],protocols.caretHide);assert(known.some(b=>b.equals(protocols.caretRestore)));}
  const cleanupCases=[{scenario:'title',bytes:protocols.restore,target:3},
    {scenario:'frame',bytes:protocols.pasteRestore,target:2},
    {scenario:'frame',bytes:protocols.caretRestore,reply:true,target:3}];
  for(const c of cleanupCases)for(const mode of [1,4])for(let offset=0;offset<c.bytes.length;offset++)
    await perform({...c,cleanup:true,mode,offset,name:`restore-cut-${c.scenario}-${c.reply?'caret':c.target}-${mode}-${offset}`});
}
assert(outcomes.length,'requested selection must execute a real case');
await writeFile(join(artifacts,'summary.json'),JSON.stringify({binary,cases:outcomes.length,failures,outcomes,utc:new Date().toISOString()},null,2));
console.log(`output_recovery cases=${outcomes.length} failures=${failures} artifacts=${artifacts}`);if(failures)process.exitCode=1;

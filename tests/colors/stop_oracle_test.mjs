#!/usr/bin/env node
// Oracle-only EOF controls: real child pipes/close; no product or TTY claim.
import assert from 'node:assert/strict';
import { spawn } from 'node:child_process';
import { mkdtemp, mkdir, readFile, writeFile } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { pathToFileURL } from 'node:url';

const artifacts=process.env.CJTUI_COLOR_STOP_ARTIFACTS ?? await mkdtemp(join(tmpdir(),'cjtui-color-stop-'));
await mkdir(artifacts,{recursive:true});
// Expose the existing test-local Session without changing its method bodies or
// adding a product hook. The CLI main guard prevents ordinary sessions here.
const original=await readFile(new URL('pty.mjs',import.meta.url),'utf8');
const helper=new URL('../support/terminal_frames.mjs',import.meta.url).href;
const modulePath=join(artifacts,'current-stop-module.mjs');
await writeFile(modulePath,original.replace("from '../support/terminal_frames.mjs'",`from '${helper}'`)+ '\nexport { Session as ControlledSession };\n');
const {ControlledSession:Session}=await import(pathToFileURL(modulePath));
const frame=Buffer.from(Array.from({length:12},(_,i)=>`\x1b[0m\x1b[${i+1};1H${'T'.repeat(31)}\x1b[0m`).join(''));
const cases=[
 ['late-partial-row',Buffer.from('\x1b[0m\x1b[1;1H'+'T'.repeat(30)+'\x1b[0m'),false],
 ['late-incomplete-escape',Buffer.from('\x1b['),false],
 ['late-wrong-style-row',Buffer.from('\x1b[0m\x1b[1;1H\x1b[31m'+'T'.repeat(31)+'\x1b[0m'),false],
 ['late-incomplete-utf8',Buffer.from([0xf0,0x9f]),false],
 ['late-unreset-style',Buffer.from('\x1b[31m'),false],
 ['legal-quiet-close',Buffer.alloc(0),true],
 ['legal-reset-close',Buffer.from('\x1b[0m'),true],
 ['legal-identical-row',Buffer.from('\x1b[0m\x1b[1;1H'+'T'.repeat(31)+'\x1b[0m'),true]
];
const observations=[];
for(const [name,late,expectedAccepted] of cases) {
 const session=new Session(name,'/oracle-only-no-product',100,40);
 session.screen.beginResize(31,12);session.screen.feed(frame);
 const verified=session.screen.finishResize(31,12);
 session.dir=join(artifacts,name);await mkdir(session.dir,{recursive:true});
 // Deliberately synthetic equal markers, not termios measurement evidence.
 await writeFile(join(session.dir,'before'),'oracle-control-same-marker');
 await writeFile(join(session.dir,'after'),'oracle-control-same-marker');
 const code="process.stdin.once('data',bytes=>{if(bytes.toString()!=='q')process.exit(2);process.stdout.write(Buffer.from(process.argv[1],'base64'),()=>process.exit(0));});";
 session.child=spawn(process.execPath,['-e',code,late.toString('base64')],{stdio:['pipe','pipe','pipe']});
 session.child.stdout.on('data',bytes=>{
  session.raw=Buffer.concat([session.raw,bytes]);session.lastBytes=Date.now();
  try{session.screen.feed(bytes);}catch(error){session.error??=error;}
 });
 session.child.stderr.on('data',bytes=>{session.stderr+=bytes.toString();});
 session.child.on('error',error=>{session.error??=error;session.finished=true;});
 session.child.on('close',(exit,signal)=>{session.code=exit;session.signal=signal;session.finished=true;});
 let accepted=true,error=null;
 try{await session.stop(verified);}catch(e){accepted=false;error=e.message.split('\n')[0];}
 if(!session.finished)session.child.kill('SIGKILL');
 await writeFile(join(session.dir,'late.raw'),session.raw);
 observations.push({name,expectedAccepted,accepted,error,actualChildExit:session.code,
  actualChildSignal:session.signal,qRequiredForChildExit0:true,matched:accepted===expectedAccepted});
}
const result={scope:'oracle-only actual child stdout and close; synthetic equal markers, no product/PTY/GUI success claim',observations};
await writeFile(join(artifacts,'observations.json'),JSON.stringify(result,null,2)+'\n');
console.log(JSON.stringify(result,null,2));
assert(observations.every(o=>o.matched&&o.actualChildExit===0&&o.actualChildSignal===null),
 'EOF must reject malformed/changed final output while accepting legal close');
console.log('PASS colors stop oracle: five invalid tails rejected, three legal closes accepted');

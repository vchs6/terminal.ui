// Temporary execution facility for the actual product minimal example, not a fixture.
import {spawn} from 'node:child_process';
import {readFile,writeFile,mkdir} from 'node:fs/promises';
import assert from 'node:assert/strict';
const dir='/workspace/work/first-slice-execution/minimal-pty';
await mkdir(dir,{recursive:true});
const binary='/workspace/work/first-slice-execution/slice-repo/examples/minimal/target/release/bin/main';
const quote=s=>`'${s.replaceAll("'", "'\\''")}'`;
const wrapper=dir+'/session.sh';
await writeFile(wrapper,'#!/bin/sh\nstty rows 5 cols 24\nstty -g > "$2/before"\ntty > "$2/tty"\n"$1" < /dev/tty &\np=$!\necho "$p" > "$2/pid"\nwait "$p"\nstatus=$?\nprintf "%s\\n" "$status" > "$2/application-exit"\nstty -g > "$2/after"\nexit "$status"\n');
const child=spawn('script',['--quiet','--return','--flush','--command',`sh ${quote(wrapper)} ${quote(binary)} ${quote(dir)}`,'/dev/null'],{stdio:['pipe','pipe','pipe'],env:{...process.env,TERM:'xterm-256color'}});
let out=Buffer.alloc(0),err=Buffer.alloc(0),done=false,exitCode,signal;
child.stdout.on('data',b=>out=Buffer.concat([out,b]));child.stderr.on('data',b=>err=Buffer.concat([err,b]));
child.on('exit',(c,s)=>{done=true;exitCode=c;signal=s;});
const delay=ms=>new Promise(r=>setTimeout(r,ms));
async function until(fn,what){const end=Date.now()+7000;while(Date.now()<end){if(await fn())return;await delay(25);}throw new Error('timeout '+what);}
let outcome={binary,rows:5,columns:24};
try{
 await until(()=>out.includes(Buffer.from('cjtui'))&&out.includes(Buffer.from('中文'))&&out.includes(Buffer.from('👩‍💻')),'actual minimal first frame');
 assert(out.includes(Buffer.from('\x1b[')),'minimal first frame has ANSI');
 console.log('OBSERVED actual minimal first frame: cjtui, 中文, 👩‍💻, ANSI; sending q');
 child.stdin.write('q');await until(()=>done,'actual minimal normal stop');
 const before=(await readFile(dir+'/before','utf8')).trim(),after=(await readFile(dir+'/after','utf8')).trim();
 const applicationExit=Number((await readFile(dir+'/application-exit','utf8')).trim());
 Object.assign(outcome,{script_exit:exitCode,application_exit:applicationExit,signal,before,after,termios_restored:before===after,stdout_bytes:out.length});
 assert(before&&after);assert.equal(after,before);assert.equal(signal,null);assert.equal(exitCode,0);assert.equal(applicationExit,0);
 console.log('PASS actual minimal PTY: application exit=0, script exit=0, exact termios restored, bytes='+out.length);
}catch(e){outcome.failure=e.stack;console.error(e.stack);process.exitCode=1;}
finally{
 if(!done){try{const pid=Number((await readFile(dir+'/pid','utf8')).trim());process.kill(pid,'SIGKILL');}catch{}child.kill('SIGKILL');}
 child.stdin.destroy();await writeFile(dir+'/stdout.bin',out);await writeFile(dir+'/stderr.bin',err);await writeFile(dir+'/result.json',JSON.stringify(outcome,null,2)+'\n');
}

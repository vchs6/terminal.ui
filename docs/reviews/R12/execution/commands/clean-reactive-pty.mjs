import assert from 'node:assert/strict';
import {spawn,spawnSync} from 'node:child_process';
import {mkdir,readFile,writeFile} from 'node:fs/promises';
const [binary,dir]=process.argv.slice(2); assert(binary&&dir);
await mkdir(dir,{recursive:true});
const wrapper=dir+'/run.sh';
await writeFile(wrapper,'#!/bin/sh\nstty rows 8 cols 48\nstty -g > "$2/before"\ntty > "$2/tty"\n"$1" < /dev/tty\nstatus=$?\nstty -g > "$2/after"\nexit "$status"\n');
const quote=s=>"'"+s.replaceAll("'","'\\''")+"'";
const child=spawn('script',['--quiet','--return','--flush','--command',`sh ${quote(wrapper)} ${quote(binary)} ${quote(dir)}`,'/dev/null'],{stdio:['pipe','pipe','pipe'],env:{...process.env,TERM:'xterm-256color'}});
let raw=Buffer.alloc(0),stderr='',done=false,status,signal;
child.stdout.on('data',x=>raw=Buffer.concat([raw,x]));child.stderr.on('data',x=>stderr+=x);child.on('close',(x,s)=>{status=x;signal=s;done=true;});
const delay=ms=>new Promise(r=>setTimeout(r,ms));
async function until(f,label){let deadline=Date.now()+15000;while(Date.now()<deadline){if(await f())return;await delay(15);}throw Error('timeout '+label);}
try {
 await until(()=>raw.includes(Buffer.from('Count: 0')),'initial ordinary example');
 child.stdin.write('c');
 // A real viewport change forces a full public frame, allowing literal state
 // verification without relying on a diff encoder or a private event hook.
 const tty=(await readFile(dir+'/tty','utf8')).trim();
 await delay(150);
 const resized=spawnSync('stty',['-F',tty,'rows','9','cols','49'],{encoding:'utf8'});assert.equal(resized.status,0);
 await until(()=>raw.includes(Buffer.from('Count: 1')),'updated ordinary example');
 child.stdin.write('\x03');await until(()=>done,'default Ctrl-C normal exit');
 assert.equal(signal,null);assert.equal(status,0);
 const before=await readFile(dir+'/before','utf8'),after=await readFile(dir+'/after','utf8');assert.equal(after,before);
 await writeFile(dir+'/result.json',JSON.stringify({binary,status,signal,initialCount:0,updatedCount:1,exactTermiosRestored:true,viewportBefore:[48,8],viewportAfter:[49,9]},null,2)+'\n');
 console.log('PASS clean ordinary reactive PTY: Count0→Count1; Ctrl-C exit0; exact termios restored');
} finally {
 if(!done){child.kill('SIGKILL');}
 await writeFile(dir+'/raw',raw);await writeFile(dir+'/stderr',stderr);
}

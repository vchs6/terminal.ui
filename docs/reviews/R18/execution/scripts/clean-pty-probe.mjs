import assert from 'node:assert/strict';
import {spawn} from 'node:child_process';
import {mkdir,writeFile,readFile} from 'node:fs/promises';
import {resolve,join} from 'node:path';
const [binaryArg,dirArg,kind='allocation']=process.argv.slice(2);
const binary=resolve(binaryArg),dir=resolve(dirArg);
await mkdir(dir);
const quote=s=>`'${s.replaceAll("'","'\\''")}'`;
const wrapper=join(dir,'session.sh');
await writeFile(wrapper,'#!/bin/sh\nstty rows 8 cols 100\nstty -g > "$2/before"\n"$1"\nstatus=$?\nstty -g > "$2/after"\nexit "$status"\n');
const child=spawn('script',['--quiet','--return','--flush','--command',`sh ${quote(wrapper)} ${quote(binary)} ${quote(dir)}`,'/dev/null'],{stdio:['pipe','pipe','pipe']});
let bytes=Buffer.alloc(0),errors='',code=null,finished=false;
child.stdout.on('data',b=>bytes=Buffer.concat([bytes,b]));child.stderr.on('data',b=>errors+=b);
const closed=new Promise(resolve=>child.on('close',c=>{code=c;finished=true;resolve(c);}));
const delay=ms=>new Promise(r=>setTimeout(r,ms));
async function waitFor(text){const until=Date.now()+10000;while(Date.now()<until){if(bytes.includes(Buffer.from(text)))return;assert(!finished,`early exit ${code}: ${errors}; ${bytes}`);await delay(10);}throw Error('timeout '+text);}
try {
  if(kind==='allocation') {await waitFor('ALLOCATION_READY');child.stdin.write('x');await waitFor('ALLOCATION_RECOVERED');}
  else {await waitFor('c: copy');child.stdin.write('c');await waitFor('Sent; the terminal may reject it.');child.stdin.write('t');await waitFor('\x1b]2;cjtui session example\x07');child.stdin.write('r');await waitFor('No safe restoration is available.');}
  child.stdin.write('q');
  await Promise.race([closed,delay(10000).then(()=>{throw Error('timeout close');})]);
  assert.equal(code,0);assert.equal((await readFile(join(dir,'before'),'utf8')).trim(),(await readFile(join(dir,'after'),'utf8')).trim());
  console.log('PASS',kind,'exit',code,'exact termios restored');
} finally {await writeFile(join(dir,'session.raw'),bytes);await writeFile(join(dir,'stderr.txt'),errors);await writeFile(join(dir,'status.json'),JSON.stringify({code,finished}));if(!finished)child.kill('SIGKILL');child.stdin.destroy();}

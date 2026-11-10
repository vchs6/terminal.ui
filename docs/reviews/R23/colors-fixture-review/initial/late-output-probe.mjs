// Targeted oracle-only probe: exact fixed Session.stop and Screen; no product run.
import fs from 'node:fs/promises';
import assert from 'node:assert/strict';
import {pathToFileURL} from 'node:url';
const root='/workspace/work/colors-resize-fixture-review';
process.env.CJTUI_COLOR_ARTIFACTS=root+'/raw/probe-artifacts';
let source=await fs.readFile(root+'/raw/fixed-pty.mjs','utf8');
source=source.replace("from '../support/terminal_frames.mjs'", "from 'file:///workspace/work/colors-resize-fixture/source/tests/support/terminal_frames.mjs'");
source+='\nexport { Session };\n';
await fs.writeFile(root+'/raw/probe-module.mjs',source);
const {Session}=await import(pathToFileURL(root+'/raw/probe-module.mjs'));
const frame=Buffer.from(Array.from({length:12},(_,i)=>`\x1b[0m\x1b[${i+1};1H${'T'.repeat(31)}\x1b[0m`).join(''));
const observations=[];
for(const [name,late] of [
 ['late incomplete row',Buffer.from('\x1b[0m\x1b[1;1H'+'T'.repeat(30)+'\x1b[0m')],
 ['late incomplete escape',Buffer.from('\x1b[')],
 ['late incorrect style',Buffer.from('\x1b[0m\x1b[1;1H\x1b[31m'+'T'.repeat(31)+'\x1b[0m')]
]) {
 const session=new Session(name,'/unused-oracle-only',100,40);
 session.screen.beginResize(31,12);session.screen.feed(frame);
 const expected=session.screen.finishResize(31,12);
 session.dir=root+'/raw/probe-artifacts/'+name.replaceAll(' ','-');
 await fs.mkdir(session.dir,{recursive:true});
 await fs.writeFile(session.dir+'/before','same-termios');await fs.writeFile(session.dir+'/after','same-termios');
 session.child={stdin:{write(){
   try{session.screen.feed(late);}catch(e){session.error??=e;}
   session.code=0;session.signal=null;session.finished=true;
 }}};
 let accepted=true;try{await session.stop();}catch{accepted=false;}
 let finalGridValid=true;
 try{assert.deepEqual(session.screen.snapshot(),expected);}catch{finalGridValid=false;}
 observations.push({name,stopAccepted:accepted,finalGridValid,parserError:session.error?.message??null,pending:session.screen.pending,row:session.screen.row});
}
console.log(JSON.stringify({scope:'oracle-only synthetic close; no product, PTY, or GUI success claim',observations},null,2));
assert(observations.every(x=>x.stopAccepted&&!x.finalGridValid),'all three demonstrate false acceptance by fixed stop');

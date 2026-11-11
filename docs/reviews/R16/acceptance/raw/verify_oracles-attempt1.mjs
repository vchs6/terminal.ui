import fs from 'node:fs';
import vm from 'node:vm';
import assert from 'node:assert/strict';
import crypto from 'node:crypto';
import {verifyLive,parseResults} from './source/tests/session_extensions/oracle.mjs';
const B='/workspace/work/glyph-execution';
const read=p=>fs.readFileSync(p);
const records=[];
// Evaluate only fixed official constants and pure row/profile helpers; never the launcher.
const glyph=read('./source/tests/glyphs/pty.mjs').toString();
const begin=glyph.indexOf('const known =');const end=glyph.indexOf('let active;',begin);
const rowStart=glyph.indexOf('function rows(');const rowEnd=glyph.indexOf('class Session',rowStart);
const frozen=vm.runInNewContext(glyph.slice(rowStart,rowEnd)+glyph.slice(begin,end)+'\n({cases,rows})',{Buffer,assert});
for(const [name,scenario,mode,expected,content] of frozen.cases){
 const p=B+'/raw/glyph-session/'+name;
 const r=JSON.parse(read(p+'/result.json'));assert.equal(r.code,0);assert.equal(r.signal,null);
 const profile=Object.fromEntries(read(p+'/report.txt').toString().trim().split('\n').map(l=>{let i=l.indexOf('=');return[l.slice(0,i),l.slice(i+1)];}));
 for(const [k,v] of Object.entries(expected))assert.equal(profile[k],v,name+' '+k);
 assert.deepEqual(read(p+'/before'),read(p+'/after'));assert.deepEqual(read(p+'/stdout.raw'),read(p+'/stdout-write.raw'));
 const rows=frozen.rows(read(p+'/stdout.raw'));assert.equal(rows.find(r=>r.row===2).text,content+' '.repeat(13));
 const unicodeBorder=mode==='Unicode'||(mode==='Auto'&&expected.nativeVt==='false');
 assert.equal(rows.find(r=>r.row===3).text,(unicodeBorder?'╭───╮':scenario==='empty'?'     ':scenario==='no-border'?'?????':'+---+')+' '.repeat(27));
 const trace=read(p+'/syscalls.txt').toString();assert(!/ioctl fd=(?!1\b)/u.test(trace));
 if(expected.nativeVt==='false')assert(!trace.includes('unimap capacity='));
 else{
  assert.equal((trace.match(/fstat fd=1\n/g)||[]).length,1);assert.equal((trace.match(/allocate bytes=262140\n/g)||[]).length,1);
  if(scenario==='alloc-fail')assert(!trace.includes('unimap capacity='));
  else{assert.equal((trace.match(/unimap capacity=65535\n/g)||[]).length,1);assert.equal((trace.match(/free pairs\n/g)||[]).length,1);}
 }
 assert(read(p+'/report.txt.snapshot').toString().includes('é e\u0301 中文 😀 ✈\ufe0f 👩‍💻 …'));
 records.push({kind:'formalGlyphPersistedRaw',name,scenario,passed:true});
}
for(const scenario of ['wire','unknown-title']){
 const p=B+'/raw/vt/session-'+scenario+'/evidence';
 verifyLive(parseResults(read(p+'/results.tsv').toString()),read(p+'/wire.bin'),read(p+'/native.log').toString(),scenario,'Direct',0,read(p+'/all-wire.bin'));
 records.push({kind:'newKernelSession',scenario,route:'Direct',wireBytes:read(p+'/wire.bin').length,passed:true});
}
const regress=B+'/raw/reused-prior/session-regression';
for(const dir of fs.readdirSync(regress,{withFileTypes:true}).filter(x=>x.isDirectory())){
 const p=regress+'/'+dir.name;const config=JSON.parse(read(p+'/launch.json')).config;
 const wire=fs.existsSync(p+'/wire.bin')?read(p+'/wire.bin'):Buffer.alloc(0);
 const all=fs.existsSync(p+'/all-wire.bin')?read(p+'/all-wire.bin'):Buffer.alloc(0);
 const native=read(p+'/native.tsv').toString();
 // Missing capture is allowed only for a native zero-write screen fault; not generic success.
 if(!fs.existsSync(p+'/wire.bin'))assert.equal(config.scenario,'fault-screen');
 verifyLive(parseResults(read(p+'/results.tsv').toString()),wire,native,config.scenario,config.route,config.offset??0,all);
 assert.deepEqual(read(p+'/before'),read(p+'/after'));
 assert(native.includes('close\t0\t'));
 for(const signal of [28,2,15])assert(native.includes('signal-restored\t'+signal+'\t1'));
 records.push({kind:'reusedFocusedSession',name:dir.name,config,passed:true});
}
const sourceHashes=Object.fromEntries(['./source/tests/glyphs/pty.mjs','./source/tests/session_extensions/oracle.mjs','./source/tests/session_extensions/fixtures/wire.json'].map(p=>[p,crypto.createHash('sha256').update(read(p)).digest('hex')]));
fs.writeFileSync('raw/oracle-verification.json',JSON.stringify({utc:new Date().toISOString(),method:'Read-only original evidence, fixed official pure oracle; no product launch',sourceHashes,records,failed:0},null,2)+'\n');
console.log(JSON.stringify({formalGlyphRaw:records.filter(x=>x.kind==='formalGlyphPersistedRaw').length,newKernelSession:2,reusedSession:records.filter(x=>x.kind==='reusedFocusedSession').length,failed:0}));

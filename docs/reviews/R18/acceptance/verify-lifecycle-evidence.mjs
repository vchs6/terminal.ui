// Read-only verification of the three additional real-host lifecycle originals.
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import assert from 'node:assert/strict';
import {parseResults,verifyLive} from './source/tests/session_extensions/oracle.mjs';
const base='/workspace/work/session-extension-execution/raw/lifecycle-hosts';
const inputs=[],checks=[];
const hash=b=>crypto.createHash('sha256').update(b).digest('hex');
function read(p){const b=fs.readFileSync(path.join(base,p));inputs.push({source:path.join(base,p),sha256:hash(b)});return b;}
const text=p=>read(p).toString(),json=p=>JSON.parse(text(p));
const expected=Buffer.from('1b5b32323b32741b5d323b41071b5d323b42071b5b32333b3274','hex');
for(const scenario of ['ledger-close','ledger-error','ledger-cancel']){
 const f=n=>scenario+'/'+n,launch=json(f('launch.json')),events=json(f('input-events.json'));
 assert.equal(launch.binarySha256,'dc5c0dde2548b9bd9ac74d5a390e82b6a2ee65cdf5777eb6668e2fda74a3677a');
 assert.equal(launch.source,'83094ca92acab37ed0a38042e2e40ead55049f41');
 assert.equal(launch.test,'f8b95815616c850145b647aae57e082c7915dab0');
 assert.equal(launch.hostExitCode,0);
 assert.deepEqual(events.map(e=>e.XTEST),scenario==='ledger-close'?[['x']]:scenario==='ledger-error'?[['x'],['e']]:[['x'],['Control_L','c']]);
 const wire=read(f('consumer/wire.bin')),all=read(f('consumer/all-wire.bin')),native=text(f('consumer/native.tsv')),rows=parseResults(text(f('consumer/results.tsv')));
 verifyLive(rows,wire,native,scenario,'Direct',0,all);
 assert.deepEqual(wire,expected);assert.deepEqual(all,expected);
 assert.equal(rows.get('cleanup.count'),'1');assert.equal(rows.get('cleanup.0'),'RestoreHostTitle|SentUnconfirmed|7|NoIssue|-1|RestoreSentUnconfirmed');
 assert(!rows.has('host.restore')&&!rows.has('restore.1'));
 const parts=native.trim().split('\n');const close=parts.findIndex(x=>x.startsWith('close\t'));
 assert.deepEqual(parts.filter(x=>x.startsWith('write\t')),['write\t1\t7','write\t2\t6','write\t3\t6','write\t4\t7']);
 assert(close>parts.lastIndexOf('sequence-result\t0\t7'));
 assert.equal(parts.filter(x=>x.startsWith('close\t')).length,1);assert.equal(parts[close],'close\t0\t'+(scenario==='ledger-error'?'1':'0'));
 assert.equal(parts.filter(x=>x.startsWith('signal-restored\t')).length,3);
 for(const item of parts.filter(x=>x.startsWith('signal-restored\t')))assert.equal(item.split('\t')[2],'1');
 assert.deepEqual(read(f('consumer/before')),read(f('consumer/after')));assert.equal(text(f('consumer/exit')).trim(),'0');
 assert.equal(rows.get('run.failed'),scenario==='ledger-error'?'true':'false');
 if(scenario==='ledger-error'){assert.equal(rows.get('run.primary'),'SESSION_CALLBACK_SENTINEL');assert.equal(rows.get('run.extras'),'2');assert.equal(rows.get('run.extra0'),'SESSION_UI_CLEANUP_SENTINEL');assert.equal(rows.get('run.extra1'),'terminal restore failed');}
 const captures=json(f('captures.json')),original='TASK151 automatic '+scenario;
 assert.equal(captures.length,scenario==='ledger-close'?2:3);
 for(const c of captures){
  const props=text(f(c.xprop)),m=props.match(/^WM_NAME\([^)]*\) = ?(.*)$/m);assert(m);const title=m[1]?JSON.parse(m[1]):'';
  assert.equal(title,c.phase==='owned-before-exit'?'B':original);assert.equal(title,c.title);
  assert.equal(hash(read(f(c.png))),c.pngSha256);assert(c.captureCommand.includes(c.windowId));
  const grid=read(f(c.nativeGrid));assert.equal(hash(grid),c.nativeGridSha256);assert(grid.includes(Buffer.from('CJTUI_SESSION_READY')));
 }
 const outer=read(f('outer-ansi.bin'));assert(outer.includes(expected));
 const wrapper=text(f('child-wrapper.sh'));assert(!wrapper.includes('printf "\\033'));assert(wrapper.includes('release-window'));
 checks.push({scenario,passed:true,bytes:wire.length,automaticPop:1,actualTitleBefore:original,actualTitleAfter:original,ownedTitleCaptured:scenario!=='ledger-close',captures:captures.length,expectedRuntimeFailure:scenario==='ledger-error'});
}
const summary=json('summary.json');assert.equal(summary.xorgExit,0);assert.equal(summary.displaySocketRemoved,true);
const result={utc:new Date().toISOString(),command:'node /workspace/work/session-extension-acceptance/verify-lifecycle-evidence.mjs',cwd:process.cwd(),scope:'Offline independent check of new real XTerm398 Direct lifecycle evidence; no candidate or host execution',checks,inputs,allPassed:true,remaining:'Final151 manifest seal and source-copy integrity; no final TASK152 verdict yet'};
fs.writeFileSync('/workspace/work/session-extension-acceptance/raw/lifecycle-verification.json',JSON.stringify(result,null,2)+'\n');
console.log(JSON.stringify({checks,hashedInputs:inputs.length},null,2));

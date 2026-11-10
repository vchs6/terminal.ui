import assert from 'node:assert/strict';
import {readFile,writeFile} from 'node:fs/promises';
import {join} from 'node:path';
import {createHash} from 'node:crypto';
import {parseResults,verifyLive} from '../source/tests/session_extensions/oracle.mjs';
const base='/workspace/work/session-extension-execution/raw/lifecycle-hosts';
const summary=JSON.parse(await readFile(join(base,'summary.json'),'utf8'));
assert.equal(summary.xorgExit,0);assert.equal(summary.displaySocketRemoved,true);assert.equal(summary.cases.length,3);
const outcomes=[];
for(const scenario of ['ledger-close','ledger-error','ledger-cancel']) {
 const dir=join(base,scenario),read=name=>readFile(join(dir,name));
 const meta=JSON.parse(await read('launch.json')),captures=JSON.parse(await read('captures.json'));
 const rows=parseResults((await read('consumer/results.tsv')).toString());
 const wire=await read('consumer/wire.bin'),all=await read('consumer/all-wire.bin'),native=(await read('consumer/native.tsv')).toString();
 // The actual, unchanged official runtime oracle supplies public result/wire assertions.
 verifyLive(rows,wire,native,scenario,'Direct',0,all);
 assert.equal(wire.toString('hex'),meta.expectedWireHex,'one save, A, B, one automatic pop');
 assert.equal(rows.get('cleanup.count'),'1','scope owned until cleanup');
 assert.match(rows.get('cleanup.0'),/^RestoreHostTitle\|SentUnconfirmed\|7\|NoIssue\|-1\|RestoreSentUnconfirmed$/);
 assert.equal(rows.has('host.restore'),false,'host r action not used');
 assert.equal(rows.has('restore.1'),false,'ledger explicit restore not used');
 assert.equal(rows.get('run.failed'),scenario==='ledger-error'?'true':'false');
 if(scenario==='ledger-error') {
  assert.match(rows.get('run.primary'),/SESSION_CALLBACK_SENTINEL/);
  assert(Number(rows.get('run.extras'))>=2);
  const extras=[...rows].filter(([k])=>/^run\.extra[0-9]+$/.test(k)).map(([,v])=>v).join('\n');
  assert.match(extras,/SESSION_UI_CLEANUP_SENTINEL/);assert.match(extras,/terminal restore failed/);
 }
 assert(native.includes('close\t0\t'+(scenario==='ledger-error'?'1':'0')),'actual native close0 and optional return fault recorded');
 assert.equal(native.split('\n').filter(x=>x.startsWith('close\t')).length,1,'native close once');
 for(const line of native.split('\n').filter(x=>x.startsWith('signal-restored\t')))assert.equal(line.split('\t')[2],'1');
 assert((await read('consumer/before')).equals(await read('consumer/after')),'actual exact termios restored');
 assert.equal((await read('consumer/exit')).toString().trim(),'0','consumer records expected errors then exits0');
 assert.equal(meta.hostExitCode,0,'real host process exit');
 assert.equal(captures[0].phase,'before');assert.equal(captures[0].title,meta.expectedInitialTitle);
 assert.equal(captures.at(-1).phase,'after-automatic-cleanup');assert.equal(captures.at(-1).title,meta.expectedFinalTitle);
 if(scenario!=='ledger-close')assert.equal(captures.find(x=>x.phase==='owned-before-exit').title,'B');
 for(const item of captures) {
  const bytes=await read(item.png);assert.equal(bytes.subarray(0,8).toString('hex'),'89504e470d0a1a0a');
  assert.equal(createHash('sha256').update(bytes).digest('hex'),item.pngSha256);
  const grid=await read(item.nativeGrid);assert(grid.length>0);assert.equal(createHash('sha256').update(grid).digest('hex'),item.nativeGridSha256);
 }
 const item={scenario,officialOraclePassed:true,actualConsumerExit:0,hostExit:meta.hostExitCode,automaticCleanupCount:1,actualTitleBefore:captures[0].title,actualTitleAfter:captures.at(-1).title,ownedTitleCaptured:scenario!=='ledger-close',originalPngCount:captures.length,termiosExact:true,expectedRuntimeFailure:scenario==='ledger-error',callbackPrimaryPreserved:scenario==='ledger-error',binarySha256:meta.binarySha256};
 outcomes.push(item);console.log(JSON.stringify(item));
}
await writeFile(join(base,'verification.json'),JSON.stringify({utc:new Date().toISOString(),allAssertionsPassed:true,unmodifiedOfficialRuntimeOracle:true,cases:outcomes,limitation:'normal ledger-close completes within one callback; ownership and automatic pop proved by original exact wire/native/results plus before/after actual X properties and PNG'},null,2));

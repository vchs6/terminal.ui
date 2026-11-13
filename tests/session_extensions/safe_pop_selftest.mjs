// Oracle/native-fixture controls only; never a product session implementation.
import assert from 'node:assert/strict';
import { spawnSync } from 'node:child_process';
import { mkdtempSync,readFileSync,writeFileSync,existsSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join,resolve } from 'node:path';
import { verifyLive,verifyKeyboardModeStartup } from './oracle.mjs';
const enable=Buffer.from('1b5b3f3230303468','hex'),disable=Buffer.from('1b5b3f323030346c','hex');
// Collector-only positive: a legitimate mode25 query may precede requested mode enable.
verifyKeyboardModeStartup(Buffer.concat([Buffer.from('1b5b3f32352470','hex'),enable]));
const vectors=[
 ['Direct','1b5b32323b3274','1b5d323b4107','1b5b32333b3274'],
 ['TmuxPassthrough','1b50746d75783b1b1b5b32323b32741b5c','1b50746d75783b1b1b5d323b41071b5c','1b50746d75783b1b1b5b32333b32741b5c'],
 ['ScreenPassthrough','1b501b5b32323b32741b5c','1b501b5d323b41071b5c','1b501b5b32333b32741b5c']
];
function observation(route,save,pop) {
 const n=save.length,p=pop.length;
 const rows=new Map([
  ['completed','yes'],['disposed','yes'],['live.id','1'],['after.id','1'],
  ['after.inactive','CopyLocalText|Failed|0|SessionInactive|-1|NotNeeded'],
  ['live.clipboard',`Unknown|NoEvidence|NoIssue|${route}|osc52-c`],
  ['live.title',`Unknown|NoEvidence|NoIssue|${route}|osc2`],
  ['live.titleStack',`Supported|ExplicitConfiguration|NoIssue|${route}|xterm-title-stack-window`],
  ['live.imageIcon',`Unsupported|KnownUnavailable|NoImageAdapter|${route}|none`],
  ['fault',`SetHostTitle|Failed|${n}|WriteFailed|-1|SaveSentUnconfirmed`],['fault.steps','2'],
  ['fault.step0',`SaveHostTitle|SentUnconfirmed|${n}|NoIssue`],['fault.step1','SetHostTitle|Failed|0|WriteFailed'],
  ['cancelled.after','CopyLocalText|Failed|0|Cancelled|-1|NotNeeded'],
  ['run.failed','true'],['run.error','DEVICE_WRITE_FIRST'],['run.primary','DEVICE_WRITE_FIRST'],['reopen.refused','false'],
  ['cleanup.count','1'],['cleanup.0',`RestoreHostTitle|SentUnconfirmed|${p}|NoIssue|-1|RestoreSentUnconfirmed`],
  ['cleanup.0.steps','1'],['cleanup.0.step0',`RestoreHostTitle|SentUnconfirmed|${p}|NoIssue`],
  ['cleanup.again',`RestoreHostTitle|SentUnconfirmed|${p}|NoIssue|-1|RestoreSentUnconfirmed`],
  ['cleanup.again.steps','1'],['cleanup.again.step0',`RestoreHostTitle|SentUnconfirmed|${p}|NoIssue`]
 ]);
 const native=`arm\t1\t0\nsequence\t1\t0\nwrite\t1\t${n}\nsequence-result\t0\t${n}\nsequence\t2\t0\nfault\t2\t0\nsequence-result\t-1\t0\nsequence\t3\t0\nwrite\t3\t${p}\nsequence-result\t0\t${p}\nsequence\t4\t0\nwrite\t4\t8\nsequence-result\t0\t8\nclose\t0\t0\n`;
 return {rows,native,startup:enable,wire:Buffer.concat([save,pop]),all:Buffer.concat([save,pop,disable])};
}
let positive=0,negative=0,nativeChecks=0;
for(const [route,saveHex,titleHex,popHex] of vectors) {
 const save=Buffer.from(saveHex,'hex'),title=Buffer.from(titleHex,'hex'),pop=Buffer.from(popHex,'hex');
 const check=o=>{verifyKeyboardModeStartup(o.startup);verifyLive(o.rows,o.wire,o.native,'fault-set',route,0,o.all);};
 check(observation(route,save,pop));positive++;
 for(const [label,mutate] of [
  ['no requested enable',o=>{o.startup=Buffer.alloc(0);}],
  ['duplicate enable',o=>{o.startup=Buffer.concat([enable,enable]);}],
  ['premature disable',o=>{o.startup=Buffer.concat([enable,disable]);}],
  ['missing mode restore',o=>{o.all=Buffer.concat([save,pop]);}],
  ['query is not mode restore',o=>{o.all=Buffer.concat([save,pop,Buffer.from('1b5b3f32352470','hex')]);}],
  ['mode restore after close',o=>{o.native=o.native.replace('sequence\t4','close\t0\t0\nsequence\t4').replace(/close\t0\t0\n$/,'');}],
  ['no pop',o=>{o.wire=save;o.all=save;o.native=o.native.slice(0,o.native.indexOf('sequence\t3'))+'close\t0\t0\n';}],
  ['extra pop',o=>{o.wire=Buffer.concat([save,pop,pop]);o.all=o.wire;}],
  ['lost cleanup record',o=>{for(const key of [...o.rows.keys()])if(key.startsWith('cleanup.'))o.rows.delete(key);o.rows.set('cleanup.count','0');}],
  ['wrong cleanup status',o=>{for(const key of ['cleanup.0','cleanup.again']){o.rows.set(key,'RestoreHostTitle|Unknown|0|RestoreUnavailable|-1|Unavailable');o.rows.set(key+'.steps','0');o.rows.delete(key+'.step0');}}],
  ['wrong cleanup step',o=>{for(const key of ['cleanup.0.step0','cleanup.again.step0'])o.rows.set(key,`SaveHostTitle|SentUnconfirmed|${pop.length}|NoIssue`);}],
  ['aliased cleanup requery step',o=>{o.rows.set('cleanup.again.step0',`SaveHostTitle|SentUnconfirmed|${pop.length}|NoIssue`);}],
  ['lost save step',o=>{o.rows.set('fault.steps','1');o.rows.set('fault.step0',`SetHostTitle|Failed|${save.length}|WriteFailed`);o.rows.delete('fault.step1');}],
  ['callback replaces primary',o=>o.rows.set('run.primary','SESSION_LATE_CALLBACK_SENTINEL')],
  ['UI cleanup replaces primary',o=>o.rows.set('run.primary','SESSION_UI_CLEANUP_SENTINEL')],
  ['consumer assertion replaces primary',o=>o.rows.set('run.primary','ASSERT:fault rejects later posts')],
  ['later post replaces primary',o=>o.rows.set('run.primary','POST_AFTER_DEVICE_FAULT')],
  ['pop after native close',o=>{o.native=o.native.replace('sequence\t3','close\t0\t0\nsequence\t3').replace(/close\t0\t0\n$/,'');}]
 ]) {
  const bad=observation(route,save,pop);mutate(bad);
  assert.throws(()=>check(bad),`${route}: reject ${label}`);negative++;
 }
 // The pre-existing unsafe branch must continue to prohibit even a cleanup pop.
 const partial=observation(route,save,pop);
 partial.rows.set('fault',`SetHostTitle|Failed|${save.length+1}|ParserUnsynchronized|-1|Failed`);
 partial.rows.set('fault.step1','SetHostTitle|Failed|1|WriteFailed');
 partial.rows.set('reopen.refused','true');partial.rows.set('reopen.error','ParserUnsynchronized');
 for(const key of ['cleanup.0','cleanup.again']) {
  partial.rows.set(key,'RestoreHostTitle|Failed|0|ParserUnsynchronized|-1|Failed');
  partial.rows.set(key+'.steps','0');partial.rows.delete(key+'.step0');
 }
 partial.native=`sequence\t1\t0\nwrite\t1\t${save.length}\nsequence-result\t0\t${save.length}\nsequence\t2\t0\nwrite\t2\t1\nfault\t2\t1\nsequence-result\t-1\t1\nclose\t0\t0\n`;
 const unsafePrefix=Buffer.concat([save,title.subarray(0,1)]);
 verifyLive(partial.rows,unsafePrefix,partial.native,'fault-set',route,1,unsafePrefix);
 assert.throws(()=>verifyLive(partial.rows,Buffer.concat([unsafePrefix,pop]),partial.native,'fault-set',route,1,Buffer.concat([unsafePrefix,pop])),`${route}: unsafe partial cannot pop`);negative++;
 if(process.argv[2]) {
  const dir=mkdtempSync(join(tmpdir(),'session-safe-pop-fixture-'));
  const files=[save,title,pop].map((bytes,i)=>{const path=join(dir,`${i}.bin`);writeFileSync(path,bytes);return path;});
  const native=join(dir,'native.tsv'),wire=join(dir,'wire.bin'),all=join(dir,'all.bin');
  const run=spawnSync(resolve(process.argv[2]),['safe-set',...files],{env:{...process.env,CJTUI_SESSION_NATIVE:native,CJTUI_SESSION_WIRE:wire,CJTUI_SESSION_ALL_WIRE:all}});
  writeFileSync(join(dir,'driver.stdout'),run.stdout);writeFileSync(join(dir,'driver.stderr'),run.stderr);
  writeFileSync(join(dir,'execution.json'),JSON.stringify({argv:[resolve(process.argv[2]),'safe-set',...files],exit:run.status,signal:run.signal,utc:new Date().toISOString(),scope:'native fault-selector only; literal files through real existing writer, not product Session'},null,2)+'\n');
  assert.equal(run.status,0,run.stderr.toString());
  assert.deepEqual(run.stdout,Buffer.concat([save,pop]));
  assert.deepEqual(existsSync(wire)?readFileSync(wire):Buffer.alloc(0),Buffer.concat([save,pop]));
  assert.deepEqual(readFileSync(all),Buffer.concat([save,pop]));
  const log=readFileSync(native,'utf8');assert.match(log,/fault\t2\t0\n/);
  assert.deepEqual(log.split('\n').filter(s=>s.startsWith('sequence-result\t')),[`sequence-result\t0\t${save.length}`,'sequence-result\t-1\t0',`sequence-result\t0\t${pop.length}`]);
  nativeChecks++;console.log(`PASS fixture-only ${route}: selected sequence2 zero fault, real writer sequence3 pop succeeds; artifacts=${dir}`);
 }
}
console.log(`PASS fixture-only S007 safe-pop oracle: routes=${positive} deliberate-negative-controls=${negative} startup-prefix-controls=1 native-selection-checks=${nativeChecks}; no product runtime PASS`);

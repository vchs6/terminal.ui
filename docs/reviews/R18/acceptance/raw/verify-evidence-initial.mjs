// Offline acceptance checks only. No candidate binary, build, host or suite is executed.
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import cp from 'node:child_process';
import assert from 'node:assert/strict';
import {sessionCases} from './source/tests/session_extensions/cases.mjs';
import {parseResults,verifyHeadless,verifyLive} from './source/tests/session_extensions/oracle.mjs';
const base='/workspace/work/session-extension-execution';
const repo='/workspace/work/terminal.ui';
const out='/workspace/work/session-extension-acceptance';
const product='83094ca92acab37ed0a38042e2e40ead55049f41';
const tests='f8b95815616c850145b647aae57e082c7915dab0';
const expectedBinary='dc5c0dde2548b9bd9ac74d5a390e82b6a2ee65cdf5777eb6668e2fda74a3677a';
const inputs=new Map(),checks=[];
const sha=b=>crypto.createHash('sha256').update(b).digest('hex');
function read(p){const full=path.isAbsolute(p)?p:path.join(base,p);assert(!full.includes('session-extension-implementation'));const data=fs.readFileSync(full);inputs.set(full,sha(data));return data;}
const text=p=>read(p).toString();
const json=p=>JSON.parse(text(p));
function check(name,fn){try{const detail=fn();checks.push({name,passed:true,detail});}catch(e){checks.push({name,passed:false,error:e.message});}}
function fixed(commit,p){return cp.execFileSync('git',['-C',repo,'show',commit+':'+p]);}
check('Fixed product, contract and test inventories agree with actual execution source',()=>{
 let count=0;
 for(const [file,commit] of [['scope/product-source.json',product],['scope/formal-tests.json',tests],['scope/contracts.json',product]]){
  const value=json(file);for(const item of value.files??value){assert.equal(sha(fixed(commit,item.path)),item.sha256,item.path+' fixed object');assert.equal(sha(read(base+'/source/'+item.path)),item.sha256,item.path+' actual source');count++;}
 }
 return {files:count};
});
check('Actual consumer, native archives and clean consumer hashes',()=>{
 const files=json('scope/binaries.json').files;for(const item of files)assert.equal(sha(read(item.path)),item.sha256);
 assert.equal(files[0].sha256,expectedBinary);
 const clean=json('scope/clean-binary.json');assert.equal(sha(read(clean.source)),clean.sha256);return {consumer:expectedBinary,clean:clean.sha256};
});
check('Build, formal execution, bundle, clean consumption and retained full-checker failure',()=>{
 const result={};for(const [stage,expected] of [['build',0],['formal-all',0],['bundle',0],['package-inspect',0],['clean-build',0],['clean-example-pty',0],['full-bundle-check',1]]){const e=json('raw/'+stage+'/execution.json');const rawExit=Number(text('raw/'+stage+'/exit').trim());assert.equal(rawExit,expected);result[stage]={execution:e,exit:rawExit};}
 assert.match(text('raw/full-bundle-check/stderr'),/examples\/composition\/cjpm.toml/);
 const before=read('raw/clean-example-pty-artifacts/before'),after=read('raw/clean-example-pty-artifacts/after');assert.deepEqual(before,after);assert.equal(json('raw/clean-example-pty-artifacts/status.json').code,0);
 return result;
});
for(const [index,c] of sessionCases.entries())check('Retained runtime '+index+' '+JSON.stringify(c),()=>{
 const name=`${String(index).padStart(3,'0')}-${c.scenario}-${c.route}-${c.offset??0}${c.uiFail?'-aggregate':''}`;
 const dir='raw/session-matrix/'+name;
 assert.deepEqual(json(dir+'/launch.json').config,c);
 const rows=parseResults(text(dir+'/results.tsv'));
 if(c.scenario==='headless'){
  assert.equal(text(dir+'/stdout.txt'),'');verifyHeadless(rows,Buffer.alloc(0));
  assert(!fs.existsSync(path.join(base,dir,'native.tsv')) || !text(dir+'/native.tsv').includes('open\t'));
 }else{
  const checkResult=json(dir+'/check.json');assert.equal(checkResult.passed,true);assert.equal(checkResult.code,0);assert.equal(checkResult.signal,null);
  assert.deepEqual(read(dir+'/before'),read(dir+'/after'));
  const native=text(dir+'/native.tsv');
  verifyLive(rows,read(dir+'/wire.bin'),native,c.scenario,c.route,c.offset??0,read(dir+'/all-wire.bin'));
  for(const line of native.split('\n').filter(l=>l.startsWith('signal-restored\t')))assert.equal(line.split('\t')[2],'1');
  if(c.uiFail)assert.match(rows.get('run.error'),/SESSION_UI_CLEANUP_SENTINEL/);
  if(c.closeFail)assert.match(rows.get('run.error'),/terminal restore failed/);
  if(c.callbackFail)assert(!rows.get('run.primary').includes('SESSION_LATE_CALLBACK_SENTINEL'));
  if(c.scenario==='ledger-error')assert.match(rows.get('run.primary')??rows.get('run.error'),/SESSION_CALLBACK_SENTINEL/);
  assert.equal(rows.get('run.failed'),c.scenario==='ledger-error'||c.closeFail||(/^fault/.test(c.scenario)&&!['fault-eintr','fault-short','fault-allocation'].includes(c.scenario))?'true':'false');
 }
 return {directory:dir,scenario:c.scenario,route:c.route,offset:c.offset??0};
});
const payload=Buffer.from('CJTUI_HOST_中😀\nLOCAL');
const inner={copy:Buffer.from('\x1b]52;c;'+payload.toString('base64')+'\x07'),save:Buffer.from('\x1b[22;2t'),A:Buffer.from('\x1b]2;CJTUI_HOST_TITLE_A\x07'),B:Buffer.from('\x1b]2;CJTUI_HOST_TITLE_B\x07'),pop:Buffer.from('\x1b[23;2t')};
function wrap(b,route){if(route==='Direct')return b;if(route==='TmuxPassthrough')return Buffer.concat([Buffer.from('\x1bPtmux;'),Buffer.from(b.toString('binary').replaceAll('\x1b','\x1b\x1b'),'binary'),Buffer.from('\x1b\\')]);assert.equal(route,'ScreenPassthrough');return Buffer.concat([Buffer.from('\x1bP'),b,Buffer.from('\x1b\\')]);}
const profiles=json('results.json').hostProfiles;
for(const profile of profiles)check('Raw host '+profile.profile,()=>{
 const m=json(profile.manifest),d=path.dirname(profile.manifest),f=p=>path.join(d,p),obs=json(f(m.observations));
 assert.equal(m.sourceSha,product);assert.equal(m.binarySha256,expectedBinary);assert.equal(sha(read(path.resolve(base,d,m.binary))),expectedBinary);
 const rows=parseResults(text(f(m.results)));
 for(const [key,value] of rows){if(rows.has(key+'.steps')){assert.notEqual(value.split('|')[1],'Applied');assert.notEqual(value.split('|')[5],'RestoreConfirmed');}}
 assert.equal(rows.get('host.copy').split('|')[1],'SentUnconfirmed');
 const frames=[inner.copy,...(m.declareStack?[inner.save]:[]),inner.A,inner.B,...(m.declareStack?[inner.pop]:[])].map(b=>wrap(b,m.route));
 const wire=Buffer.concat(frames);assert.deepEqual(read(f(m.operationWire)),wire);
 const full=read(f(m.fullStream));assert(full.includes(Buffer.from('CJTUI_SESSION_READY')));
 if(!/^(tmux|screen)/.test(profile.profile))for(const b of [inner.copy,inner.A,inner.B])assert(full.includes(b),'direct outer stream includes actual operation');
 const clip=json(f('clipboard.json'));assert.equal(clip.before.hex,m.expected.seedHex);assert.equal(clip.after.hex,m.expected.clipboardApplied?payload.toString('hex'):m.expected.seedHex);assert.equal(obs.clipboardAfterHex,clip.after.hex);assert.equal(clip.after.bytes_after,0);
 for(const phase of ['initial','A','B','restored']){
  const props=text(f(phase+'-xprop.txt'));const match=props.match(/^WM_NAME\([^)]*\) = ?(.*)$/m);assert(match);const title=match[1]?JSON.parse(match[1]):'';assert.equal(title,m.expected.title[phase]);assert.equal(title,obs.title[phase]);
  assert.equal(sha(read(f(phase+'-icon.txt'))),obs.iconBeforeSha256);
 }
 assert.equal(obs.iconAfterSha256,obs.iconBeforeSha256);assert.equal(text(f('consumer/before')).trim(),obs.termiosBefore);assert.equal(text(f('consumer/after')).trim(),obs.termiosAfter);assert.equal(obs.termiosBefore,obs.termiosAfter);assert.equal(Number(text(f('consumer/exit')).trim()),0);
 for(const s of m.screenshots){const png=read(f(s.file));assert.equal(sha(png),s.sha256);assert.equal(png.subarray(0,8).toString('hex'),'89504e470d0a1a0a');assert(s.captureCommand.includes(s.windowId));}
 const grid=read(f(m.nativeGrid));assert(grid.includes(Buffer.from('CJTUI_SESSION_READY')));
 if(profile.profile.startsWith('vte'))for(let i=0;i<4;i++){const meta=json(f(`native-${i}-meta.json`));assert.equal(meta.candidateCount,1);assert.equal(meta.rows,28);assert.equal(meta.cols,100);assert.equal(meta.widgetType,'TerminalWidget');assert(read(f(`native-${i}-visible.txt`)).includes(Buffer.from('CJTUI_SESSION_READY')));}
 if(m.ssh){const log=text(f(m.ssh.clientLog));assert.match(log,/Authenticated to .* using "publickey"/);assert.match(log,/kex: algorithm:/);assert.match(log,/Exit status 0/);assert.equal(text(f('consumer/tty')).trim(),m.ssh.remoteTty);assert.match(m.ssh.remoteCommand,/script.*--command/);assert.match(text(f('consumer/environment.txt')),/TERM=dumb/);}
 return {manifest:profile.manifest,wireBytes:wire.length,clipboardApplied:m.expected.clipboardApplied,title:obs.title,nativeGrid:m.nativeGrid};
});
check('Real process trace contains only consumer execs and runtime threads',()=>{
 const dir='raw/no-product-process';const traces=fs.readdirSync(path.join(base,dir)).filter(n=>/^trace\.\d+$/.test(n));let execs=0,clones=0;
 for(const f of traces)for(const line of text(dir+'/'+f).split('\n')){if(/execve\(/.test(line)){execs++;assert(line.includes('/tests/session_extensions/target/release/bin/main'));}if(/\bclone3?\(/.test(line)){clones++;assert(line.includes('CLONE_THREAD'));}assert(!/\b(?:fork|vfork)\(/.test(line));}
 assert.equal(execs,3);return {files:traces.length,execs,clones};
});
check('Host teardown recorded after final profiles',()=>{
 return ['hosts2','hosts3','hosts4'].map(group=>{const s=json('raw/'+group+'/summary.json');assert.equal(s.xorgExit,0);assert.equal(s.sshdExit,0);assert.equal(s.displaySocketRemoved,true);return {group,end:s.end};});
});
const report={utc:new Date().toISOString(),command:'node /workspace/work/session-extension-acceptance/verify-evidence.mjs',cwd:process.cwd(),purpose:'Offline reassertion of retained independent151 evidence; no candidate execution',finalAcceptanceVerdict:null,checks,inputs:[...inputs].map(([source,sha256])=>({source,sha256}))};
fs.mkdirSync(out+'/raw',{recursive:true});fs.writeFileSync(out+'/raw/semantic-verification.json',JSON.stringify(report,null,2)+'\n');
console.log(JSON.stringify({checks:checks.length,failed:checks.filter(c=>!c.passed),hashedInputs:inputs.size},null,2));
if(checks.some(c=>!c.passed))process.exitCode=1;

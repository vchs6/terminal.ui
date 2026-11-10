import fs from 'node:fs';
import assert from 'node:assert/strict';
import crypto from 'node:crypto';
import {completeFrames} from '/workspace/work/terminal.ui/tests/support/terminal_frames.mjs';
const base='/workspace/work/runtime-execution/r12-execution-draft/evidence';
const hash=b=>crypto.createHash('sha256').update(b).digest('hex');
const result={resize:[],runtimePTY:[],gui:[]};
for(const [sub,mode,old] of [['r019/cjtui-resize-eCER8j','coherence',false],['r019/cjtui-resize-eCER8j','inflight',false],['r019-author-red/cjtui-resize-QLuMDr','coherence',true],['r019-author-red/cjtui-resize-5ftANm','inflight',true]]){
 const d=`${base}/${sub}/${mode}`; const bytes=fs.readFileSync(`${d}/session.raw`);const frames=completeFrames(bytes);const pairs=frames.map(f=>[f.width,f.height]);
 assert.deepEqual(frames.at(-1).rows,['CJTUI_CO','01234567','        ']);
 assert.equal(fs.readFileSync(`${d}/before`,'utf8'),fs.readFileSync(`${d}/after`,'utf8'));
 assert.equal(fs.readFileSync(`${d}/close-record.txt`,'utf8'),'real_result=0 injected=0\n');
 const queries=fs.readFileSync(`${d}/queries.log`,'utf8');
 const obs=JSON.parse(fs.readFileSync(`${d}/observations.json`));assert.equal(obs.code,0);assert.equal(obs.signal,null);assert.equal(obs.finalSettled,true);
 const mixed=pairs.filter(p=>!((p[0]===24&&p[1]===5)||(p[0]===8&&p[1]===3)));
 if(old&&mode==='coherence')assert.deepEqual(mixed,[[24,3]]);else assert.deepEqual(mixed,[]);
 result.resize.push({path:d,rawSha256:hash(bytes),pairs,mixed,queries,normalExit:0,termiosEqual:true,oneRealClose:true});
}
for(const [sub,rows] of [['r019/integration-resize-raw',['cjtui   ','中文 👩‍💻 ','01234567']],['r019/lifecycle/resize-success',['CJTUI_LI','01234567','        ']]]){
 const d=`${base}/${sub}`;const bytes=fs.readFileSync(`${d}/session.raw`);const frames=completeFrames(bytes);assert.deepEqual(frames.at(-1).rows,rows);
 assert.equal(fs.readFileSync(`${d}/before`,'utf8'),fs.readFileSync(`${d}/after`,'utf8'));assert.equal(fs.readFileSync(`${d}/close-record.txt`,'utf8'),'real_result=0 injected=0\n');
 result.resize.push({path:d,rawSha256:hash(bytes),pairs:frames.map(f=>[f.width,f.height]),exactFinalGrid:rows,termiosEqual:true,oneRealClose:true});
}
for(const mode of fs.readdirSync(`${base}/c3/cjtui-runtime-pty-83QyUX`)){
 const d=`${base}/c3/cjtui-runtime-pty-83QyUX/${mode}`;if(!fs.statSync(d).isDirectory())continue;
 const r=JSON.parse(fs.readFileSync(`${d}/result.json`));assert.equal(r.passed,true);assert.equal(r.signal,null);
 assert.equal(fs.readFileSync(`${d}/before`,'utf8'),fs.readFileSync(`${d}/after`,'utf8'));
 const close=fs.readFileSync(`${d}/close-record.txt`,'utf8');assert.equal(close.trim().split('\n').length,1);assert.ok(close.startsWith('real_result=0'));
 result.runtimePTY.push({...r,path:d,termiosEqual:true,oneRealClose:true,close});
}
assert.equal(result.runtimePTY.length,12);
for(const host of ['xterm-default','xfce-vte']){
 const d=`${base}/c3/gui-reactive/${host}/interrupt`;const meta=JSON.parse(fs.readFileSync(host==='xfce-vte'?'/workspace/work/runtime-acceptance/metadata/xfce-vte-metadata.normalized.json':`${d}/metadata.json`));const exits=JSON.parse(fs.readFileSync(`${d}/exit-verification.json`));
 for(const k of ['applicationExitStatus','recorderExitStatus','hostWaitStatus'])assert.equal(exits[k],0);
 assert.equal(meta.source_commit,'c3d743d2dd5cb125e4ca435b2842d1b10c501281');
 assert.equal(hash(fs.readFileSync(`${d}/inner-tty.raw`)),meta.inner_tty_raw_sha256);
 const stages=[];
 for(const [i,stage] of ['initial','increment-one','increment-two','resized'].entries()){
  const raw=fs.readFileSync(`${d}/example-${stage}.raw`);const output=JSON.parse(fs.readFileSync(`${d}/example-${stage}-output.json`));assert.equal(hash(raw),output.sha256);assert.ok(raw.toString().includes(`Count: ${i}`));
  const png=fs.readFileSync(`${d}/example-${stage}.png`);assert.equal(png.subarray(0,8).toString('hex'),'89504e470d0a1a0a');stages.push({stage,count:i,rawSha256:hash(raw),pngSha256:hash(png)});
 }
 result.gui.push({host,source:meta.source_commit,hostVersion:meta.host_version,viewportBefore:meta.inner_tty_before,viewportAfter:meta.inner_tty_after,exits,stages});
}
const failure=fs.readFileSync(`${base}/c3/lifecycle-raw/resize-success/session.raw`);assert.equal(hash(failure),'e246929ecf8675be06fc70a6a4abd00f25fd5e7e8a44a91bdb63b93700c0a4c7');result.originalFailure={sha256:hash(failure),preserved:true,claim:'historical failure, not rewritten to PASS'};
fs.writeFileSync('/workspace/work/runtime-acceptance/raw/semantic-raw-audit.json',JSON.stringify(result,null,2)+'\n');console.log(JSON.stringify({resize:result.resize.length,runtimePTY:result.runtimePTY.length,gui:result.gui.length,oldFailurePreserved:true}));

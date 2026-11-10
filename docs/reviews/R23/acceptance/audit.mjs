import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import {execFileSync} from 'node:child_process';
const here='/workspace/work/glyph-advance-acceptance', exe='/workspace/work/glyph-advance-execution', repo='/workspace/work/terminal.ui';
const product='199f00076c1a79cfa6d0be92e7be09366e1a06af', formal='614d0a2f0e33e54ecc07bd783eaeb0b9957ca557', root='b08c92d130f8d066a6db11c9ca1bf4c9af17e3f0';
const colorIntegration='216bb9f35bdf70b621a0d30a4df32fe3c267f90b', colorTest='0d46c35456db148f08bd407825a4fd559467249a';
const hash=b=>crypto.createHash('sha256').update(b).digest('hex');
const reviewed=new Map(), checks=[], issues=[];
function read(p){const b=fs.readFileSync(p);reviewed.set(p,{path:p,sha256:hash(b),bytes:b.length});return b;}
function json(p){return JSON.parse(read(p));}
function check(name,ok,detail={}){checks.push({name,ok,...detail});if(!ok)issues.push(checks.at(-1));}
function git(...args){return execFileSync('git',['-C',repo,...args],{maxBuffer:32*1024*1024});}
function verify(p,expected,label=p){check(label,hash(read(p))===expected,{path:p,expected_sha256:expected});}
for(const p of [repo+'/AGENTS.md',repo+'/openspec/changes/fix-uncertain-glyph-advance/design.md',repo+'/openspec/changes/fix-uncertain-glyph-advance/tasks.md',repo+'/openspec/changes/implement-linux-vt-glyph-fallback/design.md',repo+'/openspec/changes/implement-incremental-rendering/design.md','/workspace/work/glyph-advance-review/report.md','/workspace/work/glyph-advance-review/findings.json','/workspace/work/glyph-advance-tests/report.md','/workspace/work/glyph-advance-tests/summary.json','/workspace/work/colors-resize-fixture-review/report.md','/workspace/work/colors-resize-fixture-review/findings.json',repo+'/docs/reviews/R14/execution-initial/report.md','/workspace/work/terminal-width-recon/findings.json'])read(p);
for(const name of ['old-root-build','old-public-final','old-existing-device','old-internal-final']){const d='/workspace/work/glyph-advance-tests/raw/'+name;const meta=json(d+'/execution.json');check('formal163 '+name,meta.exit===(name==='old-existing-device'||name==='old-internal-final'?1:0));read(d+'/stdout');read(d+'/stderr');}
const colorReview='/workspace/work/colors-resize-fixture-review/scoped-r1';
for(const line of read(colorReview+'/review-artifacts.sha256').toString().trim().split('\n')){const m=line.match(/^([a-f0-9]{64})  (.+)$/);verify(colorReview+'/'+m[2],m[1],'CRF001 scoped-review '+m[2]);}
const tracked=git('ls-tree','-r','--name-only',product).toString().trim().split('\n');
check('colors integration leaves product and glyph tests unchanged',git('diff',product,colorIntegration,'--','src','native','examples','docs/product','build.cj','cjpm.toml','tests/glyph_advance').length===0);
check('colors integration formal fixture identity',git('rev-parse',colorIntegration+':tests/colors').equals(git('rev-parse',colorTest+':tests/colors')));
const productPaths=tracked.filter(p=>p.startsWith('src/')||p.startsWith('native/')||p.startsWith('examples/')||p.startsWith('docs/product/')||['build.cj','cjpm.toml'].includes(p));
for(const p of productPaths){const fixed=git('show',product+':'+p);verify(exe+'/source/'+p,hash(fixed),'execution fixed '+p);check('root integration '+p,git('show',root+':'+p).equals(fixed));}
check('formal test tree identity',git('rev-parse',formal+':tests/glyph_advance').equals(git('rev-parse',product+':tests/glyph_advance')));
for(const x of json(exe+'/sourcehashes.json')){verify(exe+'/source/'+x.path,x.sha256,'source manifest '+x.path);check('manifest bound to product '+x.path,hash(git('show',product+':'+x.path))===x.sha256);}
for(const x of json(exe+'/dependency-reuse-proof.json').files)verify(exe+'/cache/'+x.path,x.expected_sha256,'dependency '+x.path);
for(const x of json(exe+'/reuse-originals.json')){verify(exe+'/'+x.copy,x.sha256,'reuse copy '+x.copy);verify(x.origin,x.sha256,'reuse original '+x.origin);}
const pre=read('/workspace/work/glyph-advance-reuse-proof/pre-lint-terminal_projected_row.cj').toString();
const post=read(exe+'/source/src/terminal_projected_row.cj').toString();
check('semantic hoist exact reconstruction',pre.replace('    var previous = Style()','    let defaultStyle = Style()\n    var previous = defaultStyle').replace('previous != Style()','previous != defaultStyle')===post);
check('pre-lint hash',hash(Buffer.from(pre))==='6f98c3ff7d1afdd7fe95abbafebff25aba36c118737caf9321b911b7f7ebd9ae');
const preManifest=read('/workspace/work/glyph-advance-implementation/pre-lint-fix-tested-runtime-source-SHA256SUMS').toString().trim().split('\n');
for(const line of preManifest){const m=line.match(/^([a-f0-9]{64})  (.+)$/);const rel=m[2].replace(/^\.\//,'');check('pre-lint content '+rel,hash(rel==='src/terminal_projected_row.cj'?Buffer.from(pre):read(exe+'/source/'+rel))===m[1]);}
const cjp=exe+'/source/target/cjtui-0.0.0.cjp';read(cjp);
const members=execFileSync('tar',['-tzf',cjp]).toString().trim().split('\n').filter(p=>!p.endsWith('/'));
const inventory=[];
for(const m of members){const rel=m.replace(/^cjtui-0\.0\.0\//,'');const b=execFileSync('tar',['-xOzf',cjp,m],{maxBuffer:32*1024*1024});const fixed=git('show',product+':'+rel);check('package member '+rel,b.equals(fixed));inventory.push({path:rel,sha256:hash(b),bytes:b.length});}
check('package file count 115+3',members.length===118,{actual:members.length});
const packageRoot=read(exe+'/package-root.txt').toString().trim();
for(const x of inventory)verify(packageRoot+'/'+x.path,x.sha256,'extracted package '+x.path);
const images=json(exe+'/original-images.json');for(const x of images)verify(exe+'/'+x.path,x.sha256,'original PNG '+x.path);
check('80 original PNG entries',images.length===80);
const oldFixtures=here+'/source/tests/glyph_advance/physical/fixtures';
for(const x of json(oldFixtures+'/origins.json').entries){verify(oldFixtures+'/'+x.path,x.sha256,'old frozen evidence '+x.path);verify(x.original,x.sha256,'old original evidence '+x.original);}
const dsrSummary=[], guiSummary=[];
for(const scene of ['rich','heart','basic8','truecolor']){
  for(const x of json(exe+'/gui/'+scene+'-dsr/frame-origins.json')){const a=read(x.original), b=read(x.derived);verify(x.original,x.original_sha256);verify(x.derived,x.derived_sha256);const expected=a.toString().startsWith('Script started on ')?a.subarray(a.indexOf(10)+1):a;check('exact replay derivation '+x.derived,b.equals(expected));}
  for(const host of ['xterm-default','xfce-vte']){
    const d=exe+'/gui/'+scene+'/'+host+'/q', meta=json(d+'/metadata.json');
    check('GUI source '+scene+'/'+host,meta.source_commit===product);
    const src=scene==='rich'?packageRoot+'/examples/rich-text/src/main.cj':exe+'/packaged-consumer/src/main.cj';
    const bin=scene==='rich'?packageRoot+'/examples/rich-text/target/release/bin/main':exe+'/packaged-consumer/target/release/bin/main';
    verify(src,meta.fixture_source_sha256,'CAPSRC '+scene+'/'+host);verify(bin,meta.fixture_binary_sha256,'GUI binary '+scene+'/'+host);
    const exit=json(d+'/exit-verification.json');check('true exits '+scene+'/'+host,exit.applicationExitStatus===0&&exit.recorderExitStatus===0&&exit.hostWaitStatus===0);
    for(const tty of ['inner','outer']){const text=read(d+'/'+tty+'-tty.txt').toString();check('termios '+scene+'/'+host+'/'+tty,text.match(/^ready_termios=(.+)$/m)?.[1]===text.match(/^exit_termios=(.+)$/m)?.[1]&&/^exit_status=0$/m.test(text));}
    const reap=read(d+'/process-reaping.txt').toString();check('reaped record '+scene+'/'+host,/reaped=true/.test(reap));
    for(const pid of [...reap.matchAll(/(?:host|xorg)=(\d+)/g)].map(x=>x[1]))check('host PID gone '+pid,!fs.existsSync('/proc/'+pid));
    check('events '+scene+'/'+host,JSON.stringify(meta.events)===JSON.stringify(['initial','t','t','actual resize','t','q']));
    guiSummary.push({scene,host,source_sha256:meta.fixture_source_sha256,binary_sha256:meta.fixture_binary_sha256,events:meta.events});
    const r=exe+'/gui/'+scene+'-dsr/raw/'+host, input=read(r+'/input.bin'),output=read(r+'/output.bin');
    const frameDir=exe+'/gui/'+scene+'-dsr/frames/'+host;
    const replayBytes=[Buffer.from('\x1b[2J\x1b[H'),read(frameDir+'/initial.bin'),Buffer.from('\x1b[6n')];
    for(const stage of ['green','red']){const payload=read(frameDir+'/'+stage+'.bin');const split=scene==='rich'?payload.indexOf(Buffer.from(' '.repeat(80))):payload.indexOf(90);check('replay insertion boundary '+scene+'/'+host+'/'+stage,split>=0);replayBytes.push(payload.subarray(0,split),Buffer.from('\x1b[6n'),payload.subarray(split),Buffer.from('\x1b[6n'));}
    check('actual native output exactly product frames plus declared queries '+scene+'/'+host,output.equals(Buffer.concat(replayBytes)));
    const records=read(r+'/dsr.jsonl').toString().trim().split('\n').map(JSON.parse);let off=0;
    for(const x of records){const bytes=Buffer.from(x.raw_hex,'hex');check('complete actual DSR '+scene+'/'+host+'/'+x.name,x.matched_full_csi&&/^\x1b\[\d+;\d+R$/.test(bytes.toString())&&bytes.toString()===`\x1b[${x.row};${x.col}R`&&input.subarray(off,x.input_end_offset).equals(bytes)&&output.subarray(x.output_end_offset-4,x.output_end_offset).equals(Buffer.from('\x1b[6n')));off=x.input_end_offset;
      const expected=x.name==='initial'?[28,100]:x.name.endsWith('prefix')?[3,scene==='rich'?12:3]:[3,100];check('DSR position '+scene+'/'+host+'/'+x.name,x.row===expected[0]&&x.col===expected[1]);
    }
    check('DSR count/tail '+scene+'/'+host,records.length===5&&off===input.length);
    const replayMeta=json(r+'/metadata.json');check('replay exit '+scene+'/'+host,replayMeta.host_exit===0&&read(r+'/exit.txt').toString()==='0\n');
    const events=read(r+'/events.txt').toString().trim().split('\n');check('replay termios '+scene+'/'+host,events[0].split(' utc=')[0].split('termios=')[1]===events.at(-1).split(' utc=')[0].split('termios=')[1]);
    read(r+'/driver-exit-utc.txt');dsrSummary.push({scene,host,positions:records.map(x=>[x.name,x.row,x.col])});
  }
}
const commands=json(exe+'/command-results.json');for(const x of commands){let d=exe+'/raw/'+x.name;check('command exit '+x.name,Number(read(d+'/exit').toString().trim())===x.expected_exit);for(const n of ['command','cwd','start','end','stdout','stderr'])read(d+'/'+n);}
const colorOverlay=json(exe+'/colors-test-overlay.json');check('final color fixture SHA',colorOverlay.test_sha===colorTest);
for(const x of colorOverlay.files){verify(exe+'/source/'+x.path,x.sha256,'final colors source '+x.path);check('final colors git blob '+x.path,hash(git('show',colorTest+':'+x.path))===x.sha256);}
const binaries=json(exe+'/colors-final-binaries.json');
for(const x of binaries.before_execution){verify(exe+'/source/'+x.path,x.binary_sha256,'final colors actual binary '+x.path);check('final colors binary unchanged '+x.path,binaries.after_execution.find(y=>y.path===x.path)?.binary_sha256===x.binary_sha256);}
for(const x of binaries.source_files){verify(exe+'/source/'+x.path,x.sha256,'final colors consumer source '+x.path);check('final colors consumer bound199 '+x.path,hash(git('show',product+':'+x.path))===x.sha256);}
for(const x of binaries.actual_sessions){const d=exe+'/raw/28-final-colors-actual/artifacts/'+x.name;const result=json(d+'/result.json');check('actual color exit '+x.name,result.code===0&&result.signal===null);verify(d+'/before',x.before_sha256);verify(d+'/after',x.after_sha256);check('actual color termios '+x.name,read(d+'/before').equals(read(d+'/after')));verify(d+'/session.raw',x.session_raw_sha256);const pid=read(d+'/pid').toString().trim();check('actual color PID gone '+x.name,!fs.existsSync('/proc/'+pid));}
const stop=JSON.parse(read(exe+'/raw/26-final-stop-controls/stdout').toString().split('\nPASS colors stop oracle:')[0]);check('8 actual-child final controls',stop.observations.length===8&&stop.observations.every(o=>o.matched&&o.actualChildExit===0&&o.actualChildSignal===null));
const colorExample=exe+'/raw/28-final-colors-actual/artifacts/actual-example';check('color actual restored complete grid',JSON.stringify(json(colorExample+'/initial.json'))===JSON.stringify(json(colorExample+'/restored.json')));
for(const size of ['31x12','8x4','100x40'])read(colorExample+'/resize-'+size+'-frames.json');
const manifest=read(exe+'/artifacts.sha256').toString().trim().split('\n');for(const line of manifest){const m=line.match(/^([a-f0-9]{64})  (.+)$/);if(m)verify(exe+'/'+m[2],m[1],'sealed '+m[2]);else check('manifest syntax',false,{line});}
let strictJsonCount=0;for(const line of manifest){const p=line.slice(66);try{if(p.endsWith('.json')){json(exe+'/'+p);strictJsonCount++;}else if(p.endsWith('.jsonl')){for(const l of read(exe+'/'+p).toString().trim().split('\n'))if(l.trim())JSON.parse(l);strictJsonCount++;}}catch(error){check('strict JSON '+p,false,{error:error.message});}}
const curated=exe+'/r23-execution-draft';const cm=read(curated+'/artifacts.sha256').toString().trim().split('\n');for(const line of cm){const m=line.match(/^([a-f0-9]{64})  (.+)$/);verify(curated+'/'+m[2],m[1],'curated sealed '+m[2]);}
check('final full manifest supplied SHA',hash(read(exe+'/artifacts.sha256'))==='ae0dc6befbad005a60bd6507a5ea2e1ddd6f1b1e45428b271658ef1d58b31a05');
check('final curated manifest supplied SHA',hash(read(curated+'/artifacts.sha256'))==='9620ad563107f08894cd119f049f8a54a3498b7c2f4fb3518f16bcadf304c909');
fs.writeFileSync(here+'/raw/strict-json-audit.json',JSON.stringify({checked:strictJsonCount,invalid:issues.filter(i=>i.name.startsWith('strict JSON'))},null,2)+'\n');
fs.writeFileSync(here+'/raw/package-inventory.json',JSON.stringify(inventory,null,2)+'\n');
fs.writeFileSync(here+'/raw/integrity-audit.json',JSON.stringify({utc:new Date().toISOString(),product,formal,root,status:issues.length?'FAIL':'PASS',counts:{checks:checks.length,issues:issues.length,product_paths:productPaths.length,package_members:members.length,images:images.length,dsr_replies:40},issues,gui:guiSummary,dsr:dsrSummary,checks},null,2)+'\n');
fs.writeFileSync(here+'/reviewed-hashes.json',JSON.stringify({generated_utc:new Date().toISOString(),files:[...reviewed.values()]},null,2)+'\n');
console.log(JSON.stringify({checks:checks.length,issues,reviewed:reviewed.size,package_members:members.length}));
process.exitCode=issues.length?1:0;

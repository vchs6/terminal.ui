import fs from 'node:fs';import cp from 'node:child_process';import crypto from 'node:crypto';
const repo='/workspace/work/glyph-tests-refresh/source',out='/workspace/work/glyph-observable-fixture-review',raw='/workspace/work/glyph-tests-refresh/observable-report';
const base='df21f3def32de39a415d1d8d9845b83514dc2902',head='bfd0715cc342fe7c334bd7ce222cdda9c4fb37d5',file='tests/glyphs/session/src/main.cj';
const git=(...a)=>cp.execFileSync('git',['-C',repo,...a],{encoding:'utf8'});
const sha=b=>crypto.createHash('sha256').update(b).digest('hex');
const result={utc:new Date().toISOString(),cwd:out,command:'node verify.mjs',base,head,checks:[],inputs:[]};
const check=(ok,detail)=>{result.checks.push({ok,detail});if(!ok)process.exitCode=1;};
check(git('rev-parse',head+'^').trim()===base,'fixed parent');
check(git('diff','--name-only',base,head).trim()===file,'one test source changed');
check(git('diff','--numstat',base,head).trim()==='8\t8\t'+file,'8 additions / 8 removals');
check(git('diff','--check',base,head)==='','diff whitespace check');
for(const p of ['src','native','cjpm.toml','build.cj','openspec/changes/implement-linux-vt-glyph-fallback','tests/glyphs/pty.mjs','tests/glyphs/session/native/glyph_syscall_wrap.c','tests/glyphs/internal/glyph_conservative_test.cj']){
 const a=git('rev-parse',base+':'+p).trim(),b=git('rev-parse',head+':'+p).trim();check(a===b,{unchanged:p,gitObject:b});
}
const before=git('show',base+':'+file),after=git('show',head+':'+file);
const transformed=before.replaceAll('text.value = "文"','text.set("文")').replaceAll('text.value = "??"','text.set("??")').replaceAll('text.value = "👩\\u{200d}💻"','text.set("👩\\u{200d}💻")').replaceAll('text.value = "❤\\u{fe0f}"','text.set("❤\\u{fe0f}")').replaceAll('text.value = "A"','text.set("A")').replaceAll('foreground.value = Color.Blue','foreground.set(Color.Blue)').replaceAll('text.value','text.get()').replaceAll('foreground.value','foreground.get()');
check(transformed===after,'entire fixture equals only intended public-accessor replacements');
check(JSON.stringify(before.match(/"(?:\\.|[^"\\])*"/g))===JSON.stringify(after.match(/"(?:\\.|[^"\\])*"/g)),'all string literals and event names identical');
const observable=git('show',head+':src/observable.cj');
const rootAuthority=cp.execFileSync('git',['-C','/workspace/work/terminal.ui','show','4a1dac52936da971bf42d4052c5dad4220ae6667:src/observable.cj'],{encoding:'utf8'});
check(observable===rootAuthority,'Observable identical to root authoritative fixed commit; object is in root repository');
check(observable.includes('private var value: T')&&observable.includes('public func get(): T')&&observable.includes('public func set(value: T): Unit'),'public API authority');
for(const p of [file,'src/observable.cj','tests/glyphs/README.md','openspec/changes/implement-linux-vt-glyph-fallback/tasks.md'])result.inputs.push({gitCommit:head,path:p,sha256:sha(git('show',head+':'+p)),retained:false,reason:'Fixed source/contract, hash only'});
const pack='/workspace/work/terminal.ui/.superpowers/sdd/tasks-implement-linux-vt-glyph-fallback/review-df21f3d..bfd0715.diff';const packageText=fs.readFileSync(pack,'utf8');
check(packageText.slice(packageText.indexOf('diff --git'))===git('diff','-U10',base,head),'provided full technical diff equals fixed commit diff despite FETCH_HEAD header shorthand');
result.inputs.push({path:pack,sha256:sha(packageText),retained:false,reason:'Original technical package'});
const allowed=['environment.json','environment.log','control-cjpm.toml','manifest.json','sourcehash.sha256','observable-private-value-red.cj','observable-private-value-red.json','observable-private-value-red.log','observable-getset-green.cj','observable-getset-build.json','observable-getset-build.log','observable-getset-run.json','observable-getset-run.log','original-session-direct-fail.log'];
const manifest=JSON.parse(fs.readFileSync(raw+'/manifest.json'));
const evidence=new Map(fs.readFileSync(raw+'/evidence-sha256.txt','utf8').trim().split('\n').map(l=>[l.slice(66),l.slice(0,64)]));
for(const f of allowed){const hash=sha(fs.readFileSync(raw+'/'+f));check(hash===evidence.get(f),{originalEvidenceHash:f});result.inputs.push({path:raw+'/'+f,sha256:hash,retained:false,reason:'Original execution evidence retained externally; no report/self-assessment read'});}
check(sha(fs.readFileSync(raw+'/original-session-direct-fail.log'))===manifest.originalFailureSha256,'original direct compile failure copy hash');
check(sha(after)===manifest.fixedFixtureSha256&&sha(observable)===manifest.observableSourceSha256,'fixed fixture / API authority hashes');
for(const [name,expected] of [['observable-private-value-red',1],['observable-getset-build',0],['observable-getset-run',0]]){const info=JSON.parse(fs.readFileSync(raw+'/'+name+'.json'));check(info.code===expected&&info.signal===null,{originalExecution:name,exit:info.code,argv:info.argv,cwd:info.cwd,start:info.start,end:info.end});}
check(fs.readFileSync(raw+'/observable-private-value-red.log','utf8').includes("can not access field 'value'"),'RED is private-field compiler rejection');
check(fs.readFileSync(raw+'/observable-getset-run.log','utf8').split('\n').filter(l=>l.startsWith('PASS ')).length===9,'nine original public Observable reactive assertions');
const binary='/workspace/work/glyph-tests-refresh/observable-consumer/target/release/bin/main';const hash=sha(fs.readFileSync(binary));check(hash===manifest.controlBinarySha256,'actual existing normal control binary hash');result.inputs.push({path:binary,sha256:hash,retained:false,reason:'ELF original omitted; no rerun needed under AGENTS11.1'});
fs.writeFileSync(out+'/raw/verification.json',JSON.stringify(result,null,2)+'\n');console.log(JSON.stringify({utc:result.utc,checks:result.checks.length,failed:result.checks.filter(c=>!c.ok),productRuntimeExecuted:false}));

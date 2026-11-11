import {readFileSync,readdirSync,statSync,writeFileSync,existsSync} from 'node:fs';
import {createHash} from 'node:crypto';
import {execFileSync,spawnSync} from 'node:child_process';
import assert from 'node:assert/strict';
const out='/workspace/work/glyph-review', repo='/workspace/work/terminal.ui';
const head='1f67e27358254e9daef637b5c2f5a93707ee7cef', base='7681999e501ca3a6d019648bca34528e6eaa990c';
const git=(...args)=>execFileSync('git',['-C',repo,...args]);
const hash=x=>createHash('sha256').update(x).digest('hex');
const walk=(dir,prefix='')=>readdirSync(dir).flatMap(name=>statSync(dir+'/'+name).isDirectory()?walk(dir+'/'+name,prefix+name+'/'):[prefix+name]);
const manifest={utc:new Date().toISOString(),base,product:head,official_test_base:'df21f3def32de39a415d1d8d9845b83514dc2902',test_repairs:['bfd0715cc342fe7c334bd7ce222cdda9c4fb37d5','dc6fdbfb4003a3151dab21d8de7cf7e54a1598b9'],root_test_commit:git('rev-parse','HEAD').toString().trim(),product_files:{},contracts:{},official_tests:{},raw:{},package:{},checks:[]};
const changed=git('diff','--name-only',base,head).toString().trim().split('\n');
for(const p of changed){const fixed=git('show',head+':'+p);assert.deepEqual(readFileSync(out+'/source/'+p),fixed);manifest.product_files[p]=hash(fixed);}
for(const p of ['AGENTS.md','openspec/changes/implement-linux-vt-glyph-fallback/design.md','openspec/changes/fix-uncertain-glyph-advance/design.md','openspec/changes/implement-linux-vt-glyph-fallback/specs/terminal-output/spec.md'])manifest.contracts[p]=hash(readFileSync(repo+'/'+p));
for(const p of git('ls-tree','-r','--name-only','HEAD','tests/glyphs').toString().trim().split('\n')){
 const fixed=git('show',(p==='tests/glyphs/session/src/main.cj'?manifest.test_repairs[1]:manifest.official_test_base)+':'+p);
 assert.deepEqual(readFileSync(repo+'/'+p),fixed);manifest.official_tests[p]=hash(fixed);
}
const pkg=out+'/package/cjtui-0.0.0', members=walk(pkg), mismatches=[];
for(const p of members){const actual=readFileSync(pkg+'/'+p), fixed=git('show',head+':'+p);if(!actual.equals(fixed))mismatches.push(p);}
assert.deepEqual(mismatches,[]);
const cjp='/workspace/work/glyph-implementation/source/target/cjtui-0.0.0.cjp';
assert.equal(hash(readFileSync(cjp)),'66c740eefb3dc4162295df0f23450b25a60d748ad3d2193b5f935cfa66f5408c');
manifest.package={path:cjp,sha256:hash(readFileSync(cjp)),files:members.length,all_member_bytes_match_fixed_product:true,member_sha256:Object.fromEntries(members.map(p=>[p,hash(readFileSync(pkg+'/'+p))])),contains_benchmarks:members.some(p=>p.startsWith('benchmarks/')),contains_composition_example:members.some(p=>p.startsWith('examples/composition/'))};
const raw='/workspace/work/glyph-implementation';
for(const name of ['baseline-build.log','baseline-api.log','api.log','negative.log','public-current.log','rich-current.log','internal-current.log','bundle-current.log','package-current.log','package-current-inventory.txt','session-final.log','session-regression.log','runtime-current.log','regression-runtime.log','product-content-sha256.txt','log-sha256.txt','log-utc.txt','artifacts.sha256'])manifest.raw[name]=existsSync(raw+'/'+name)?hash(readFileSync(raw+'/'+name)):{status:'not_present'};
for(const dir of ['glyph-session-final','session-regression'])for(const p of walk(raw+'/'+dir))manifest.raw[dir+'/'+p]=hash(readFileSync(raw+'/'+dir+'/'+p));
const sessions=[];
for(const name of readdirSync(raw+'/glyph-session-final')){
 const dir=raw+'/glyph-session-final/'+name;if(!statSync(dir).isDirectory())continue;
 const result=JSON.parse(readFileSync(dir+'/result.json'));assert.equal(result.code,0);assert.equal(result.signal,null);
 assert.equal(readFileSync(dir+'/before','utf8').trim(),readFileSync(dir+'/after','utf8').trim());
 assert.deepEqual(readFileSync(dir+'/stdout.raw'),readFileSync(dir+'/stdout-write.raw'));
 sessions.push({name,code:result.code,stdout_bytes:statSync(dir+'/stdout.raw').size,termios_equal:true,capture_equal:true});
}
const regression=[];
for(const name of readdirSync(raw+'/session-regression')){
 const dir=raw+'/session-regression/'+name;if(!statSync(dir).isDirectory())continue;
 const result=JSON.parse(readFileSync(dir+'/check.json'));assert.equal(result.passed,true);
 assert.equal(readFileSync(dir+'/before','utf8').trim(),readFileSync(dir+'/after','utf8').trim());
 regression.push({name,...result,termios_equal:true});
}
manifest.checks.push({name:'fixed changed-source bytes',passed:true,files:changed.length},{name:'formal test lineage bytes',passed:true,files:Object.keys(manifest.official_tests).length},{name:'CJP all-file bytes',passed:true,files:members.length},{name:'persisted glyph branches and termios/write capture',passed:true,cases:sessions.length},{name:'persisted session regression and termios',passed:true,cases:regression.length});
const warningCount=(readFileSync(raw+'/bundle-current.log','utf8').match(/warning/g)||[]).length;
let verifiedLogHashes=0;
for(const line of readFileSync(raw+'/log-sha256.txt','utf8').trim().split('\n')){
 const m=line.match(/^([a-f0-9]{64})  (.*)$/);if(!m)continue;
 const name=m[2].slice(raw.length+1);
 if(typeof manifest.raw[name]==='string'){assert.equal(manifest.raw[name],m[1]);verifiedLogHashes++;}
}
manifest.checks.push({name:'supplied raw-log hashes independently recomputed',passed:true,logs:verifiedLogHashes});
const negatives=readFileSync(raw+'/negative.log','utf8').replace(/\x1b\[[0-9;]*m/g,'');
assert(negatives.startsWith('cjpm build success\n'));
for(const field of ['nativeVt','mapKnown','entryCount','source','reason','nativeError'])assert(negatives.includes('local.'+field+' ='));
assert(negatives.includes('PASS public capabilities snapshot is immutable'));
manifest.checks.push({name:'readonly positive gate and six mutable-local compiler rejections',passed:true,fields:6});
writeFileSync(out+'/evidence-check.json',JSON.stringify({utc:manifest.utc,sessions,session_regression:regression,bundle_warning_occurrences:warningCount,checks:manifest.checks},null,2)+'\n');
writeFileSync(out+'/reviewed-hashes.json',JSON.stringify(manifest,null,2)+'\n');
console.log(JSON.stringify({utc:manifest.utc,checks:manifest.checks,bundle_warning_occurrences:warningCount,missing_future_package_members:{benchmarks:!manifest.package.contains_benchmarks,composition:!manifest.package.contains_composition_example}},null,2));

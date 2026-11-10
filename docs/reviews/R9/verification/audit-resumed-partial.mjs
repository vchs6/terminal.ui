import {readFileSync,writeFileSync,readdirSync,mkdirSync,existsSync} from 'node:fs';
import {execFileSync} from 'node:child_process';
import {createHash} from 'node:crypto';
import assert from 'node:assert/strict';
const dest='/workspace/work/layout-acceptance',root=dest+'/repo';
const base='/workspace/work/layout-execution',final=base+'/final-40aa4db';
const fixed='40aa4db6c2b7673bb3e8c9a80fdb5b4e385cb940';
const hash=b=>createHash('sha256').update(b).digest('hex');
const read=f=>readFileSync(f,'utf8');
const git=(...args)=>execFileSync('git',args,{cwd:root});
const inventory=[], lines=[];
function freeze(source,relative){const b=readFileSync(source),target=dest+'/frozen-resumed-partial/'+relative;mkdirSync(target.slice(0,target.lastIndexOf('/')),{recursive:true});if(existsSync(target))assert.equal(hash(readFileSync(target)),hash(b),target);else writeFileSync(target,b);inventory.push({source,copy:relative,bytes:b.length,sha256:hash(b)});}
const source=JSON.parse(read(final+'/source-hashes.json'));assert.equal(source.testedCommit,fixed);
for(const entry of source.files){assert.equal(hash(git('show',`${fixed}:${entry.path}`)),entry.sha256,entry.path);assert.equal(hash(readFileSync(base+'/repo/'+entry.path)),entry.sha256,entry.path);}
const sman=read(final+'/source.sha256').trim().split('\n');assert.equal(sman.length,source.files.length);
for(const line of sman){const [,sha,path]=line.match(/^(\w+)  (.+)$/);assert.equal(source.files.find(x=>x.path===path)?.sha256,sha,path);}
freeze(final+'/source-hashes.json','source-hashes.json');freeze(final+'/source.sha256','source.sha256');
lines.push(`PASS all ${source.files.length} source entries equal fixed git objects and actual executor checkout; text/JSON manifests agree`);
const checks={};
for(const name of ['lifecycle','native-session','root-build','root-check']){
  const prefix=base+'/logs/final-'+name;assert.equal(read(prefix+'.exit').trim(),'0',name);
  for(const ext of ['command','cwd','exit','log'])freeze(prefix+'.'+ext,'logs/final-'+name+'.'+ext);
  checks[name]={exit:0,command:read(prefix+'.command').trim()};
}
assert.equal(checks.lifecycle.command,'bash tests/run-slice.sh application-lifecycle');
assert.equal(checks['native-session'].command,'bash tests/run-slice.sh native-session');
assert.equal(checks['root-build'].command,'cjpm build');assert.equal(checks['root-check'].command,'cjpm check');
assert(read(base+'/logs/final-native-session.log').includes('PASS owner'));assert(read(base+'/logs/final-native-session.log').includes('PASS setup-signal'));
const modes=['q-success','q-close-failure','callback-success','callback-close-failure','ctrl-c-success','resize-success'];
const cases=[];
for(const mode of modes){
 const dir=final+'/lifecycle/'+mode,r=JSON.parse(read(dir+'/result.json')),output=read(dir+'/session.raw')+read(dir+'/stderr.txt');
 const closeFail=mode.endsWith('close-failure'),callback=mode.startsWith('callback-');
 assert.equal(r.mode,mode);assert.equal(r.passed,true);assert.equal(r.signal,null);assert.equal(r.code,closeFail||callback?1:0);
 assert.equal(read(dir+'/before').trim(),read(dir+'/after').trim());assert(read(dir+'/before').trim());
 assert.equal(read(dir+'/close-record.txt'),`real_result=0 injected=${closeFail?1:0}\n`);
 assert.equal(output.includes('CJTUI_CALLBACK_SENTINEL'),callback);assert.equal(output.includes('terminal restore failed'),closeFail);
 assert(output.includes('CJTUI_LIFECYCLE_READY'));assert(output.includes('\x1b['));assert.equal(read(dir+'/stderr.txt'),'');
 if(mode==='resize-success'){assert(output.includes('0123456789ABCDEFGHIJKLMN'));assert(output.includes('01234567'));}
 for(const file of readdirSync(dir))freeze(dir+'/'+file,'lifecycle/'+mode+'/'+file);
 cases.push({...r,exact_termios:true,real_close_calls:1,business_marker:callback,restore_marker:closeFail,raw_sha256:hash(readFileSync(dir+'/session.raw'))});
}
assert(read(base+'/logs/final-lifecycle.log').includes('failures=0'));lines.push('PASS six independent lifecycle raw/result/termios/one-real-close artifacts; direct expected 0/1 statuses and dual error text retained');
lines.push('PASS original native-session owner/setup-signal and ordinary root cjpm build/check logs each exit 0');
const review='/workspace/work/cleanup-scoped-review',projection='/workspace/work/terminal.ui/docs/reviews/R9/cleanup-review';
const reviewFiles=['review.md','findings.json','evidence/reuse-audit.json','evidence/static-checks.json'];
for(const file of reviewFiles){assert.equal(hash(readFileSync(review+'/'+file)),hash(readFileSync(projection+'/'+file)),file);freeze(review+'/'+file,'cleanup-review/'+file);}
assert.deepEqual(JSON.parse(read(review+'/findings.json')),[]);
const audit=JSON.parse(read(review+'/evidence/reuse-audit.json'));assert.equal(audit.revision,fixed);
const diff=git('diff','--unified=10','dabd60b8a7216531d37582ff623aa50ed263a1b6',fixed,'--','src','tests','openspec/changes/implement-layout-decoration/design.md');
assert.equal(hash(diff),audit.technical_diff_sha256);assert.equal(hash(readFileSync(projection+'/cleanup-technical-review.diff')),hash(diff));
freeze(projection+'/cleanup-technical-review.diff','cleanup-review/cleanup-technical-review.diff');
const red=root+'/docs/reviews/R9/lifecycle-test';
let failures=0;const redCases=[];
for(const mode of modes){const dir=red+'/lifecycle-red-artifacts/'+mode,r=JSON.parse(read(dir+'/result.json'));if(!r.passed)failures++;assert.equal(r.passed,mode!=='callback-close-failure');const text=read(dir+'/session.raw')+read(dir+'/stderr.txt');if(mode==='callback-close-failure'){assert(!text.includes('CJTUI_CALLBACK_SENTINEL'));assert(text.includes('terminal restore failed'));assert(r.error.includes('original callback exception'));}assert.equal(read(dir+'/before').trim(),read(dir+'/after').trim());assert.equal(read(dir+'/close-record.txt'),`real_result=0 injected=${mode.endsWith('close-failure')?1:0}\n`);for(const file of ['result.json','before','after','close-record.txt','session.raw','stderr.txt'])freeze(dir+'/'+file,'lifecycle-red/'+mode+'/'+file);redCases.push(r);}
assert.equal(failures,1);freeze(red+'/lifecycle-red.log','lifecycle-red.log');
lines.push('PASS independent scoped review fixed diff/hash and main projection copies agree; findings empty; original RED raw independently confirms 5 pass / dual error information loss fails');
writeFileSync(dest+'/frozen-resumed-partial/inventory.json',JSON.stringify(inventory,null,2)+'\n');
writeFileSync(dest+'/logs/resumed-partial-audit.json',JSON.stringify({status:'partial-audited-final-pending',fixed,source_entries:source.files.length,checks,cases,redCases,review:{spec:'passed',quality:'passed',fixed,diff_sha256:hash(diff)},inventory:'frozen-resumed-partial/inventory.json'},null,2)+'\n');
writeFileSync(dest+'/logs/resumed-partial-audit.log',lines.join('\n')+'\nEXIT=0\n');
const result=JSON.parse(read(dest+'/results.json'));result.stage='resumed-lifecycle-review-source-audited-awaiting-package-and-final-execution';result.partial_evidence.resumed_lifecycle={status:'independently-raw-audited',fixed,cases:cases.length,audit:'logs/resumed-partial-audit.json',raw_inventory:'frozen-resumed-partial/inventory.json'};result.partial_evidence.scoped_cleanup_review={spec:'passed',quality:'passed',fixed,projection_byte_identical:true};writeFileSync(dest+'/results.json',JSON.stringify(result,null,2)+'\n');console.log(lines.join('\n'));

import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import {execFileSync} from 'node:child_process';
const review='/workspace/work/glyph-advance-review';
const repo='/workspace/work/terminal.ui';
const impl='/workspace/work/glyph-advance-implementation';
const fixed='199f00076c1a79cfa6d0be92e7be09366e1a06af';
const base='23ac7aa602187428b6e4d297f38fca614df717fe';
const tests='614d0a2f0e33e54ecc07bd783eaeb0b9957ca557';
const hash=p=>crypto.createHash('sha256').update(fs.readFileSync(p)).digest('hex');
const git=(...args)=>execFileSync('git',['-C',repo,...args],{encoding:'utf8'});
const entries=p=>fs.readFileSync(p,'utf8').trim().split('\n').map(l=>({sha256:l.slice(0,64),path:l.slice(66)}));
const verify=(manifest,root)=>entries(manifest).map(e=>({...e,actual:hash(path.resolve(root,e.path)),match:hash(path.resolve(root,e.path))===e.sha256}));
const runtime=verify(impl+'/tested-runtime-source-SHA256SUMS',review+'/source');
const product=verify(impl+'/product-source-SHA256SUMS',review+'/source');
const deps=verify(impl+'/dependency-source-SHA256SUMS',impl+'/cache');
const env=verify(impl+'/dependency-hashes.txt',impl);
// CJPM rewrites map entry order. Prove the recorded lock is precisely a
// permutation of today's identical dependency entries, preserving mismatch.
const lockEntry=env.find(e=>e.path.endsWith('/cjpm.lock'));
const lockText=fs.readFileSync(lockEntry.path,'utf8');
const lockLines=lockText.split('\n').filter(l=>l.startsWith('  '));
const permutations=a=>a.length?a.flatMap((v,i)=>permutations(a.filter((_,j)=>i!==j)).map(p=>[v,...p])):[[]];
const priorLock=permutations(lockLines).map(p=>'version = 0\n\n[requires]\n'+p.join('\n')+'\n').find(s=>crypto.createHash('sha256').update(s).digest('hex')===lockEntry.sha256);
const lockOrderOnly=Boolean(priorLock);
fs.writeFileSync(review+'/raw/lock-order-proof.json',JSON.stringify({recorded_sha256:lockEntry.sha256,current_sha256:lockEntry.actual,exact_recorded_content_reconstructed:priorLock,only_dependency_entry_order_differs:lockOrderOnly},null,2)+'\n');
const binaries=verify(impl+'/binary-package-SHA256SUMS',impl);
const changed=git('diff','--name-only',base,fixed).trim().split('\n');
const testDiff=git('diff',tests,fixed,'--','tests/glyph_advance');
const formalTestFiles=git('ls-tree','-r','--name-only',tests,'--','tests/glyph_advance').trim().split('\n').filter(p=>p.endsWith('.cj')||p.endsWith('run.sh')||p.endsWith('cjpm.toml')).map(p=>({path:p,sha256:hash(review+'/source/'+p)}));
const actualDiff=git('diff','-U10',base,fixed);
fs.writeFileSync(review+'/raw/actual-product.diff',actualDiff);
const supplied=fs.readFileSync(repo+'/.superpowers/sdd/tasks-fix-uncertain-glyph-advance/review-23ac7aa..199f000.diff','utf8');
const diffMatch=supplied.slice(supplied.indexOf('diff --git'))===actualDiff;
const selected=['00-environment','14-formal-final','15-bundle-final','17-clean-consumer-build','18-clean-consumer-direct','04-colors','09-capabilities','08-colors-session','08b-colors-example-rerun','16-archive-boundary'];
const artifactEntries=new Map(entries(impl+'/artifacts-SHA256SUMS').map(e=>[e.path,e.sha256]));
const evidence=[];
const commands=[];
for(const name of selected){
  const folder=impl+'/raw/'+name;
  commands.push({name,command:fs.readFileSync(folder+'/command.txt','utf8').trim(),exit:Number(fs.readFileSync(folder+'/exit','utf8')),start_utc:fs.readFileSync(folder+'/start.utc','utf8').trim(),end_utc:fs.readFileSync(folder+'/end.utc','utf8').trim()});
  for(const file of ['command.txt','cwd.txt','exit','stdout','stderr','start.utc','end.utc']){
    const p=folder+'/'+file;
    if(!fs.existsSync(p))continue;
    const relative=path.relative(impl,p),sha256=hash(p);
    evidence.push({path:p,sha256,bytes:fs.statSync(p).size,recorded_sha256:artifactEntries.get(relative),match:sha256===artifactEntries.get(relative)});
  }
}
const supplemental=[repo+'/openspec/changes/fix-uncertain-glyph-advance/design.md',repo+'/openspec/changes/fix-uncertain-glyph-advance/tasks.md',repo+'/openspec/changes/implement-linux-vt-glyph-fallback/design.md',repo+'/AGENTS.md',repo+'/.superpowers/sdd/tasks-fix-uncertain-glyph-advance/task-165-brief.md','/workspace/work/glyph-advance-preflight/raw/scalar-widths.tsv','/workspace/work/colors-resize-fixture/classification.json',impl+'/raw/stty-resize-ioctl.trace','/workspace/work/rich-text-execution/report.md','/workspace/work/terminal-width-recon/report.md',impl+'/source/cangjie-repo.toml',impl+'/source/tests/glyph_advance/public/cangjie-repo.toml'];
for(const p of supplemental)evidence.push({path:p,sha256:hash(p),bytes:fs.statSync(p).size});
const strip=s=>s.replace(/\x1b\[[0-9;?]*[A-Za-z]/g,'');
const formal=strip(fs.readFileSync(impl+'/raw/14-formal-final/stdout','utf8'));
const bundle=strip(fs.readFileSync(impl+'/raw/15-bundle-final/stdout','utf8'));
const summary={fixed,base,test_commit:tests,changed_files:changed,diff_package_exact_match:diffMatch,test_source_diff_empty:testDiff==='',runtime_hashes_match:runtime.every(e=>e.match),runtime_count:runtime.length,product_hashes_match:product.every(e=>e.match),dependency_hashes_match:deps.every(e=>e.match),dependency_count:deps.length,environment_hashes_match:env.every(e=>e.match),binary_hashes_match:binaries.every(e=>e.match),raw_hashes_match:evidence.filter(e=>'match'in e).every(e=>e.match),formal_public_pass_count:(formal.match(/^PASS:/gm)||[]).length,formal_private_pass_count:(formal.match(/\[ PASSED \] CASE:/g)||[]).length,bundle_warning_count:(bundle.match(/: warning:/g)||[]).length,bundle_error_count:(bundle.match(/: error:/g)||[]).length,commands};
summary.environment_same_content_after_lock_order_proof=env.every(e=>e.match||e===lockEntry&&lockOrderOnly);
fs.writeFileSync(review+'/reviewed-sourcehashes.json',JSON.stringify({fixed,base,test_commit:tests,product,runtime,formal_test_files:formalTestFiles,dependencies:deps,environment:env,binaries},null,2)+'\n');
fs.writeFileSync(review+'/raw/manifest.json',JSON.stringify({created_utc:new Date().toISOString(),evidence},null,2)+'\n');
fs.writeFileSync(review+'/raw/audit.json',JSON.stringify(summary,null,2)+'\n');
console.log(JSON.stringify(summary,null,2));
if(!diffMatch||testDiff!==''||!summary.environment_same_content_after_lock_order_proof||[...runtime,...product,...deps,...binaries,...evidence.filter(e=>'match'in e)].some(e=>!e.match))process.exitCode=1;

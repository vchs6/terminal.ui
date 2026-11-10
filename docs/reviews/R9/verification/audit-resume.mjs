import {readFileSync,writeFileSync,copyFileSync,existsSync} from 'node:fs';
import {execFileSync} from 'node:child_process';
import {createHash} from 'node:crypto';
import assert from 'node:assert/strict';
const root='/workspace/work/layout-acceptance/repo', dest='/workspace/work/layout-acceptance';
const old='425626a1b6556b16837cb0744d5a5f46ebd54814';
const fix='40aa4db6c2b7673bb3e8c9a80fdb5b4e385cb940';
const checkout='6ffc6d7600142928baa4a1aeeeca4690e8872c94';
const git=(...args)=>execFileSync('git',args,{cwd:root});
const hash=b=>createHash('sha256').update(b).digest('hex');
const lines=[];
assert.equal(git('rev-parse','HEAD').toString().trim(),checkout);
for(const line of readFileSync(dest+'/logs.sha256','utf8').trim().split('\n')){
  const [,sha,file]=line.match(/^(\w+)  (.+)$/); assert.equal(hash(readFileSync(file)),sha,file);
}
lines.push('PASS all original logs.sha256 entries retained byte-for-byte; no original evidence regenerated');
const tracked=git('ls-tree','-r','--name-only',fix,'--','src','native','build.cj','cjpm.toml','tests','examples').toString().trim().split('\n');
const changes=git('diff','--name-only',old,fix,'--','src','native','build.cj','cjpm.toml','tests','examples').toString().trim().split('\n');
const expected=['src/application.cj','tests/README.md','tests/application-lifecycle/.gitignore','tests/application-lifecycle/cjpm.toml','tests/application-lifecycle/native/close_wrap.c','tests/application-lifecycle/pty.mjs','tests/application-lifecycle/run.sh','tests/application-lifecycle/src/main.cj','tests/run-slice.sh'];
assert.deepEqual(changes,expected);
assert.equal(git('diff',fix,checkout,'--','src','native','build.cj','cjpm.toml','tests','examples').length,0);
lines.push('PASS fixed 40aa4db technical scope equals current checkout 6ffc6d7 byte-for-byte');
const manifest=tracked.map(f=>`${hash(git('show',`${fix}:${f}`))}  ${f}`).join('\n')+'\n';
writeFileSync(dest+'/technical-40aa4db.sha256',manifest);
const original=readFileSync(dest+'/technical.sha256','utf8').trim().split('\n');
let reused=0;
for(const line of original){const [,sha,path]=line.match(/^(\w+)  (.+)$/);assert.equal(hash(git('show',`${old}:${path}`)),sha,path);if(!changes.includes(path)){assert.equal(hash(git('show',`${fix}:${path}`)),sha,path);reused++;}}
lines.push(`PASS ${reused}/${original.length} prior technical files identical; changed old files are Application, tests README and runner; six lifecycle files newly added`);
const structure=[];
for(const file of tracked.filter(f=>f.startsWith('src/')&&f.endsWith('.cj'))){
  const s=git('show',`${fix}:${file}`).toString();
  const types=[...s.matchAll(/^\s*(?:(?:public|protected|private|internal|open|abstract|sealed)\s+)*(class|struct|enum|interface)\s+(\w+)/gm)].map(m=>({kind:m[1],name:m[2]}));
  const expectedPackage='cjtui'+file.slice(3,file.lastIndexOf('/')).replaceAll('/','.');
  const actual=s.match(/^package\s+(\S+)/m)?.[1];
  assert(types.length<=1,file);assert.equal(actual,expectedPackage,file);assert(/^src\/(?:[a-z_]+\/)*[a-z_]+\.cj$/.test(file),file);
  if(types.length)assert.equal(file.split('/').at(-1),types[0].name.replace(/([a-z0-9])([A-Z])/g,'$1_$2').toLowerCase()+'.cj',file);
  structure.push({file,package:actual,types});
}
writeFileSync(dest+'/logs/source-organization-40aa4db.json',JSON.stringify(structure,null,2)+'\n');
assert.equal(git('show',`${fix}:src/exports.cj`).toString(),git('show',`${old}:src/exports.cj`).toString());
lines.push(`PASS ${structure.length} source files / ${structure.reduce((n,x)=>n+x.types.length,0)} entities retain single type per correctly named file/package; root public exports unchanged`);
writeFileSync(dest+'/logs/resume-scope-audit.log',lines.join('\n')+'\nEXIT=0\n');
for(const file of ['verification.md','results.json']){const backup=dest+'/pre-resume-'+file;if(!existsSync(backup))copyFileSync(dest+'/'+file,backup);}
const result=JSON.parse(readFileSync(dest+'/results.json','utf8'));
result.status='pending';result.stage='resumed-contract-and-identity-audited-awaiting-final-independent-execution';
result.checkout=checkout;result.technical_sha=fix;result.technical_manifest_sha256=hash(manifest);
result.scope=['AC-011','AC-012','AC-054','AC-055','AC-056','AC-057','AC-058','AC-059','AC-060'];
result.checks.push({name:'resume-scope-identity',exit:0,log:'logs/resume-scope-audit.log'});
for(const ac of result.scope)result.acceptance[ac]={status:'pending',reason:'Await independent repair review, fixed-source affected execution, standard bundle, clean consumer, archive hashes and final integration metadata.'};
result.reused_evidence={original_technical_sha:old,original_checkout:'e27b154decf97239d1f86d7a3900a4eedfe16e8c',scope:'Unchanged Unicode/Frame/layout/decoration numerical and golden consumers; original cold/PTY raw remains historical. Session/Application paths require the new independent affected runs.',identical_prior_files:reused,total_prior_files:original.length,original_manifest:'technical.sha256',current_manifest:'technical-40aa4db.sha256',preserved_inventory:'logs.sha256'};
result.source_organization={files:structure.length,types:structure.reduce((n,x)=>n+x.types.length,0),status:'static-checked-runtime-package-pending',inventory:'logs/source-organization-40aa4db.json'};
writeFileSync(dest+'/results.json',JSON.stringify(result,null,2)+'\n');
console.log(lines.join('\n'));

import {execFileSync, spawnSync} from 'node:child_process';
import {writeFileSync, readFileSync, readdirSync} from 'node:fs';
import {createHash} from 'node:crypto';
const root='/workspace/work/layout-acceptance/repo';
const dest='/workspace/work/layout-acceptance';
const sha='425626a1b6556b16837cb0744d5a5f46ebd54814';
const git=(...a)=>execFileSync('git',a,{cwd:root});
const digest=b=>createHash('sha256').update(b).digest('hex');
const checks=[];
function run(name,cmd,args){const r=spawnSync(cmd,args,{cwd:root,encoding:'utf8'});writeFileSync(`${dest}/logs/${name}.log`, `$ ${cmd} ${args.join(' ')}\n${r.stdout||''}${r.stderr||''}\nEXIT=${r.status}\n`);checks.push({name,exit:r.status,log:`logs/${name}.log`});return r.status;}
run('technical-identity','git',['diff','--exit-code',sha,'HEAD','--','src','native','build.cj','cjpm.toml','tests','examples']);
run('repository-metadata','node',['scripts/check-repository.mjs']);
run('openspec-strict','/workspace/work/terminal.ui/node_modules/.bin/openspec',['validate','--all','--strict','--no-interactive']);
run('whitespace','git',['diff','--check','c502c9fe64422095d7a37e741d8756af3bbc9873','HEAD']);
const files=git('ls-tree','-r','--name-only','HEAD','--','src','native','build.cj','cjpm.toml','tests','examples').toString().trim().split('\n');
const manifest=files.map(f=>`${digest(git('show',`HEAD:${f}`))}  ${f}`).join('\n')+'\n';writeFileSync(`${dest}/technical.sha256`,manifest);
const structure=[];
for(const f of files.filter(f=>f.startsWith('src/')&&f.endsWith('.cj'))){const s=readFileSync(`${root}/${f}`,'utf8');const types=[...s.matchAll(/^\s*(?:(?:public|protected|private|internal|open|abstract|sealed)\s+)*(class|struct|enum|interface)\s+(\w+)/gm)].map(m=>({kind:m[1],name:m[2]}));const expected='cjtui'+f.slice(3,f.lastIndexOf('/')).replaceAll('/','.');const actual=s.match(/^package\s+(\S+)/m)?.[1];if(types.length>1||actual!==expected||!/^src\/(?:[a-z_]+\/)*[a-z_]+\.cj$/.test(f))throw Error('Structure mismatch '+f);structure.push({file:f,package:actual,types});}
writeFileSync(`${dest}/logs/source-organization.json`,JSON.stringify(structure,null,2)+'\n');
writeFileSync(`${dest}/results.json`,JSON.stringify({status:'pending',stage:'prepared-awaiting-independent-execution',checkout:git('rev-parse','HEAD').toString().trim(),technical_sha:sha,technical_manifest_sha256:digest(manifest),scope:['AC-011','AC-012','AC-054','AC-055','AC-056','AC-057','AC-058'],checks,source_organization:{files:structure.length,types:structure.reduce((n,x)=>n+x.types.length,0),status:'static-checked-runtime-pending'},acceptance:Object.fromEntries(['AC-011','AC-012','AC-054','AC-055','AC-056','AC-057','AC-058'].map(x=>[x,{status:'pending',reason:'Final executor raw, fixed execution revision, cold package and consumer evidence not yet delivered.'}])),full_release_status:'not-passed; composition, benchmark, M2 and other complete-product obligations remain pending'},null,2)+'\n');
console.log(JSON.stringify(checks));

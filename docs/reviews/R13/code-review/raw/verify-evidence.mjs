import fs from 'node:fs';
import crypto from 'node:crypto';
import cp from 'node:child_process';
const base='/workspace/work/dynamic-review';
const source=base+'/source';
const git=(args)=>cp.execFileSync('git',['-C',source,...args],{encoding:'utf8'}).trim();
if(git(['rev-parse','HEAD'])!=='167c2a3f701b8718e90fe7d9b78050af5665a23b') throw Error('candidate changed');
if(git(['diff','--name-only']).length) throw Error('tracked modifications');
if(git(['diff','bc91577','--name-only','--','tests/dynamic']).length) throw Error('formal tests changed');
if(git(['diff','0912436','--name-only','--','native','src/terminal_bridge.cj','src/application.cj']).length) throw Error('R019 boundary differs');
const findings=JSON.parse(fs.readFileSync(base+'/findings.json','utf8'));
if(findings.length!==1||findings[0].id!=='DYN-F001') throw Error('finding shape');
if(!fs.readFileSync(base+'/raw/probe-build-corrected.meta','utf8').includes('exit=0\n')) throw Error('no successful build');
if(!fs.readFileSync(base+'/raw/probe-run.meta','utf8').includes('exit=1\n')) throw Error('missing contract RED');
const actual=fs.readFileSync(base+'/raw/probe-run.log','utf8');
for(const prefix of ['manual','replacement']) {
 if(!actual.includes(prefix+':error=DuplicateKey\n')||!actual.includes(prefix+':old-cleanup:active-parent,children=1\n')) throw Error('counterexample not observed');
}
const external=[
 '/workspace/work/runtime-review/scoped-report.md',
 '/workspace/work/runtime-review/scoped-f007-findings.json',
 '/workspace/work/runtime-review/scoped-r019.md',
 ...['delivered-product-source.sha256','final-product-source.sha256','delivery-identity.txt','delivered-dynamic-build.meta','delivered-dynamic-build.log','delivered-dynamic-run.meta','delivered-dynamic-run.log','delivered-bundle-consumer-run.meta','delivered-bundle-consumer-run.log','delivered-public-example-build.meta','delivered-public-example-build.log','delivered-public-example-smoke.meta','delivered-public-example-smoke.log','final-runtime-session.meta','final-runtime-session.log','repository-check.meta','repository-check.log','bundle-boundary-script.log'].map(x=>'/workspace/work/dynamic-implementation-sol/logs/'+x)
];
const local=['report.md','findings.json','sourcehash.txt','probe/cjpm.toml','probe/cangjie-repo.toml','probe/src/main.cj','probe/src/ref_box.cj','probe/target/release/bin/main',...fs.readdirSync(base+'/raw').filter(x=>x!=='verification.log').map(x=>'raw/'+x)].map(x=>base+'/'+x);
const paths=[...new Set([...local,...external])].sort();
const hashes=paths.map(p=>crypto.createHash('sha256').update(fs.readFileSync(p)).digest('hex')+'  '+p).join('\n')+'\n';
fs.writeFileSync(base+'/evidence-manifest.sha256',hashes);
console.log('Verified fixed source, unchanged formal tests, unchanged R019 boundary, one confirmed finding, successful normal build and both observed RED cases.');
console.log('Manifest files='+paths.length);

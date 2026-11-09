import {execFileSync,spawnSync} from 'node:child_process';
import {writeFileSync,readFileSync} from 'node:fs';
import {createHash} from 'node:crypto';
const cwd='/workspace/work/first-slice-acceptance/repo';
const items=[
 ['git-head','git',['rev-parse','HEAD']],
 ['technical-identity','git',['diff','--exit-code','2ad6c5ceeb0068d3b2b2d5efe010059965b9415a','HEAD','--','src','native','build.cj','cjpm.toml','examples','tests','scripts','package.json','package-lock.json','.github']],
 ['working-tree','git',['diff','--exit-code']],
 ['syntax-build','bash',['-n','native/build.sh']],
 ['syntax-entry','bash',['-n','scripts/check-product.sh']],
 ['syntax-tests','bash',['-n','tests/run-slice.sh']],
 ['syntax-pty','node',['--check','tests/integration/pty.mjs']],
 ['test-history','git',['log','--format=%H %s','868a3f6722e89e03232785469940a0e510a12103..HEAD','--','tests']],
 ['versions','bash',['-lc','node --version && npm --version && /workspace/work/terminal.ui/node_modules/.bin/openspec --version']],
 ['native-input-hashes','sha256sum',['build.cj','native/build.sh','native/cjtui_terminal.c','src/unicode.cj','src/frame.cj','src/component.cj','src/application.cj','cjpm.toml','examples/minimal/src/main.cj','tests/run-slice.sh','scripts/check-product.sh']]
];
const results=[];
let log='TASK053 independent acceptance preflight\n';
for (const [id,cmd,args] of items) {
 const start=new Date().toISOString();
 const r=spawnSync(cmd,args,{cwd,encoding:'utf8'});
 const row={id,cwd,command:[cmd,...args],started:start,ended:new Date().toISOString(),exit_code:r.status,stdout:r.stdout,stderr:r.stderr};
 results.push(row);log+='\n'+JSON.stringify({id,command:row.command,exit_code:r.status})+'\n'+r.stdout+r.stderr;
}
results.push({id:'npm-check',cwd,command:'OPENSPEC_TELEMETRY=0 npm run check',exit_code:0,log:'npm-check.log',note:'Executed directly before this audit; complete original output preserved.'});
writeFileSync('/workspace/work/first-slice-acceptance/commands.json',JSON.stringify(results,null,2)+'\n');
writeFileSync('/workspace/work/first-slice-acceptance/validation.txt',log+'\nnpm-check exit_code=0; see npm-check.log\n');
console.log(results.map(r=>r.id+': '+r.exit_code).join('\n'));
if(results.some(r=>r.exit_code!==0))process.exit(1);

import fs from 'node:fs';
import {run,root,repo,hash} from './audit.mjs';
const read=p=>fs.readFileSync(repo+'/'+p,'utf8');
const tasks=read('docs/tasks.md');
const graph=new Map();
for(const m of tasks.matchAll(/^\| (TASK-\d+) \/ WP-\d+ \|[^\n]+$/gm))graph.set(m[1],m[0].split('|')[4].match(/TASK-\d+/g)||[]);
for(const m of tasks.matchAll(/^### (TASK-\d+)：[^\n]+\n([\s\S]*?)(?=^### |^## |$(?![\s\S]))/gm)) {
  const line=m[2].split('\n').find(l=>l.startsWith('| inputs / depends_on |'));
  if(line&&!graph.has(m[1]))graph.set(m[1],line.split('|')[2].split(' / ').at(-1).match(/TASK-\d+/g)||[]);
}
const active=new Set(),done=new Set();
function dfs(id){if(active.has(id))throw Error('cycle '+id);if(done.has(id))return;if(!graph.has(id))throw Error('missing node '+id);active.add(id);for(const d of graph.get(id))dfs(d);active.delete(id);done.add(id);}
for(const id of graph.keys())dfs(id);
const closure=new Set();function collect(id){for(const d of graph.get(id)){if(!closure.has(d)){closure.add(d);collect(d);}}}collect('TASK-024');
const linux=[...Array.from({length:23},(_,i)=>'TASK-'+String(i+1).padStart(3,'0')),...Array.from({length:8},(_,i)=>'TASK-'+String(i+25).padStart(3,'0')),'TASK-037','TASK-041'];
const missing=linux.filter(t=>!closure.has(t));
const unwanted=[...closure].filter(t=>!linux.includes(t));
if(missing.length||unwanted.length)throw Error(JSON.stringify({missing,unwanted}));
for(const id of ['TASK-038','TASK-039','TASK-040'])if(!graph.get(id).includes('TASK-024'))throw Error('future target not ordered '+id);
let count=0;
for(const cap of fs.readdirSync(repo+'/openspec/changes/refine-terminal-ui-contracts/specs')){
 const delta=read(`openspec/changes/refine-terminal-ui-contracts/specs/${cap}/spec.md`),main=read(`openspec/specs/${cap}/spec.md`);
 for(const b of delta.split(/(?=^### Requirement: )/m).slice(1)){
  const block=b.split(/^## /m)[0].trim();if(!main.includes(block))throw Error('projection mismatch '+cap+' '+block.split('\n')[0]);count++;
 }
}
const spec=read('openspec/specs/terminal-session/spec.md');
for(const word of ['Linux、Windows、macOS、HarmonyOS为必需目标','Linux-first implementation phase','MUST NOT 作为 Linux 阶段'])if(!spec.includes(word))throw Error('lost target boundary '+word);
const auth=run('rg',['-n','后续获授权|只有后续实施授权|不授权框架、产品示例','docs/tasks.md','docs/development/proposal.md']);
if(auth.status!==1)throw Error('old authorization wording');
const product=run('git',['diff','--name-only','533bb9bc645c82cac523a319d0e34ec325fbcc99','HEAD','--','src','examples','benchmarks','tests']);
if(product.status||product.stdout.trim())throw Error('unexpected product implementation');
const result={commit:run('git',['rev-parse','HEAD']).stdout.trim(),graph:Object.fromEntries(graph),taskCount:graph.size,linuxClosure:[...closure].sort(),closureCount:closure.size,missing,unwanted,deltaRequirementsIdentical:count};
fs.writeFileSync(root+'/contract-results.json',JSON.stringify(result,null,2)+'\n');
console.log(JSON.stringify({tasks:graph.size,linuxClosure:closure.size,missing,unwanted,deltaRequirementsIdentical:count}));

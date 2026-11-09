import fs from 'node:fs';import cp from 'node:child_process';
const read=p=>fs.readFileSync(p,'utf8');
const tasks=read('docs/tasks.md');const old=[...tasks.matchAll(/^\| (TASK-\d+) \/ WP-\d+ \|[^\n]+$/gm)];const graph=new Map();
for(const m of old){const cols=m[0].split('|').map(s=>s.trim());graph.set(m[1],cols[4].match(/TASK-\d+/g)||[]);}
for(const m of tasks.matchAll(/^### (TASK-\d+)：[^\n]+\n([\s\S]*?)(?=^### |^## |$(?![\s\S]))/gm)){if(graph.has(m[1]))continue;const line=m[2].split('\n').find(l=>/^\| inputs \/ depends_on \|/.test(l));if(line)graph.set(m[1],line.split('|')[2].split(' / ').at(-1).match(/TASK-\d+/g)||[]);}
const visiting=new Set(),done=new Set();function visit(id){if(visiting.has(id))throw Error('Task dependency cycle '+id);if(done.has(id))return;if(!graph.has(id))throw Error('Unmapped dependency '+id);visiting.add(id);for(const dep of graph.get(id))visit(dep);visiting.delete(id);done.add(id);}for(const id of graph.keys())visit(id);
for(const id of ['TASK-027','TASK-031'])if(!graph.get(id).includes('TASK-037'))throw Error('Missing scroll integration '+id);
for(const id of ['TASK-027','TASK-031','TASK-032'])if(!graph.get('TASK-023').includes(id))throw Error('Missing final integration '+id);
const base='openspec/changes/refine-terminal-ui-contracts/specs';let checked=0;for(const cap of fs.readdirSync(base)){const d=read(`${base}/${cap}/spec.md`);const main=read(`openspec/specs/${cap}/spec.md`);for(const b of d.split(/(?=^### Requirement: )/m).slice(1)){const block=b.split(/^## /m)[0].trim();if(!main.includes(block))throw Error('Delta/main drift '+cap+' '+block.split('\n')[0]);checked++;}}
const changed=cp.execFileSync('git',['diff','b8ce41857e37186cadfbbbc3586a9f8f5e67ece4','--name-only'],{encoding:'utf8'}).trim().split('\n');if(changed.some(p=>/^(src|examples|benchmarks|tests)\//.test(p)))throw Error('Product implementation outside scope');
console.log(`PASS: ${graph.size} product task dependencies are acyclic; new scrolling/final integration edges present`);
console.log(`PASS: ${checked} delta requirements match main specs; no product source changes`);

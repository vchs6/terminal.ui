// Run from the repository root; checks planned responsibility, not OS support.
import fs from 'node:fs';
const tasks=fs.readFileSync('docs/tasks.md','utf8');
const ac=fs.readFileSync('docs/acceptance.md','utf8');
for(const[id,os]of [['038','Windows'],['039','macOS'],['040','HarmonyOS'],['041','Linux']]){
 if(!tasks.includes(`### TASK-${id}：${os}平台会话适配`))throw Error('Missing platform owner '+os);
 const row=ac.split('\n').find(l=>l.startsWith(`| AC-${id} |`));
 if(!row?.includes(os)||!row.endsWith('| pending |'))throw Error('Missing/premature platform acceptance '+os);
 const table=tasks.split('\n').find(l=>l.startsWith('| TASK-020 /'));
 if(!table?.includes('TASK-'+id))throw Error('Missing session integration '+id);
}
for(const file of ['docs/requirements.md','openspec/specs/terminal-session/spec.md','openspec/changes/refine-terminal-ui-contracts/specs/terminal-session/spec.md']){
 const s=fs.readFileSync(file,'utf8');for(const os of ['Linux','Windows','macOS','HarmonyOS'])if(!s.includes(os))throw Error('Missing required OS '+file+' '+os);
 if(!s.includes('OpenHarmony'))throw Error('Missing HarmonyOS evidence distinction '+file);
}
console.log('PASS: four required OS targets have separate planned owners, pending acceptance, shared session integration and explicit HarmonyOS evidence boundaries');

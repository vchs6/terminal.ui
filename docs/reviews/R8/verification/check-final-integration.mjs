import {readFileSync,writeFileSync} from 'node:fs';
import {execFileSync,spawnSync} from 'node:child_process';
import {createHash} from 'node:crypto';
import assert from 'node:assert/strict';
const dir='/workspace/work/first-slice-acceptance/',repo=dir+'repo';
const sha='e68f4cee3273d8428c7d991b00eb5323b0a48077';
const hash=b=>createHash('sha256').update(b).digest('hex');
const result={task:'TASK-053',phase:'final integration',source:sha,technical_source:'2ad6c5ceeb0068d3b2b2d5efe010059965b9415a',commands:[],technical:[],copies:[],scope:{},verdict:'pending'};
let log='TASK053 final integration: '+sha+'\n';
function run(id,cmd,args,env={}){const r=spawnSync(cmd,args,{cwd:repo,encoding:'utf8',env:{...process.env,...env}});result.commands.push({id,command:[cmd,...args],exit_code:r.status,stdout:r.stdout,stderr:r.stderr});log+='\n'+JSON.stringify({id,command:[cmd,...args],exit_code:r.status})+'\n'+r.stdout+r.stderr;assert.equal(r.status,0,id);return r.stdout;}
assert.equal(run('head','git',['rev-parse','HEAD']).trim(),sha);
run('technical-diff','git',['diff','--exit-code',result.technical_source,'HEAD','--','src','native','build.cj','cjpm.toml','examples','tests','scripts','package.json','package-lock.json','.github']);
for(const f of JSON.parse(readFileSync(dir+'mapping.json','utf8')).technical_files){const actual=hash(readFileSync(repo+'/'+f.path));assert.equal(actual,f.sha256,f.path);result.technical.push({path:f.path,sha256:actual});}
const evidence=execFileSync('git',['ls-files','docs/reviews/R8/execution','docs/reviews/R8/verification'],{cwd:repo,encoding:'utf8'}).trim().split('\n');
for(const path of evidence){const area=path.startsWith('docs/reviews/R8/execution/')?'execution':'verification';const rel=path.replace('docs/reviews/R8/'+area+'/','');if(area==='execution'&&rel==='slice-report.md')continue;let source=area==='execution'?'/workspace/work/first-slice-execution/'+rel:dir+rel;if(rel==='slice-report.original.md.txt')source='/workspace/work/first-slice-execution/slice-report.md';if(rel==='native-report.original.md.txt')source='/workspace/work/first-slice-execution/native-report.md';const a=readFileSync(repo+'/'+path),b=readFileSync(source);assert(a.equals(b),path+' copied bytes');result.copies.push({path,source,sha256:hash(a),size:a.length});}
const original=readFileSync(repo+'/docs/reviews/R8/execution/slice-report.original.md.txt','utf8');
const projection=readFileSync(repo+'/docs/reviews/R8/execution/slice-report.md','utf8');
const split=projection.indexOf('\n\n');assert(projection.startsWith('> 本文件仅将独立执行报告的绝对链接改为仓库相对链接；'));
assert.equal(projection.slice(split+2),original.replaceAll('](/workspace/work/first-slice-execution/',']('));
result.scope.report_projection='One documented prefatory paragraph and exact absolute-link-prefix replacement only; original byte-identical';
const acceptance=readFileSync(repo+'/docs/acceptance.md','utf8');
const old=execFileSync('git',['show','14370a107d6e5558e5ec31aea7edd2de9f3c43b3:docs/acceptance.md'],{cwd:repo,encoding:'utf8'});
assert.equal(acceptance.split('## 首个Linux产品切片验收')[0],old.split('## 首个Linux产品切片验收')[0]);
for(const id of [48,49,50,51,52])assert(new RegExp('^\\| AC-0'+id+' \\|[^\\n]*\\| passed \\|$','m').test(acceptance));
assert(/^\| AC-053 \|[^\n]*\| pending \|$/m.test(acceptance));
const tasks=readFileSync(repo+'/openspec/changes/implement-linux-first-slice/tasks.md','utf8');
for(const id of [48,49,50,51,52])assert(new RegExp('^- \\[x\\] [^\\n]*TASK-0'+id+'：','m').test(tasks));
assert(/^- \[ \] [^\n]*TASK-053：/m.test(tasks));
assert.equal(JSON.parse(readFileSync(repo+'/package.json','utf8')).version,'0.0.0');assert(/version = "0.0.0"/.test(readFileSync(repo+'/cjpm.toml','utf8')));
const changed=run('changed-files','git',['diff','--name-only','14370a107d6e5558e5ec31aea7edd2de9f3c43b3','HEAD']).trim().split('\n');
assert(changed.every(p=>p.startsWith('docs/')||p==='openspec/changes/implement-linux-first-slice/progress.md'||p==='openspec/changes/implement-linux-first-slice/tasks.md'));
assert(!changed.some(p=>/\.(?:a|o|so|cjp|cjo)$/.test(p)));
for(const path of changed){const b=readFileSync(repo+'/'+path);assert(!b.subarray(0,4).equals(Buffer.from([0x7f,0x45,0x4c,0x46])),path+' ELF');}
assert.equal(readFileSync(repo+'/docs/reviews/R8/execution/minimal-pty/stdout.bin').length,182);
run('repository-openspec-strict','npm',['run','check'],{OPENSPEC_TELEMETRY:'0'});
const apply=JSON.parse(run('apply-progress','./node_modules/.bin/openspec',['instructions','apply','--change','implement-linux-first-slice','--json'],{OPENSPEC_TELEMETRY:'0'}));assert.equal(apply.progress.total,6);assert.equal(apply.progress.complete,5);assert.equal(apply.state,'ready');
run('tracked-clean','git',['diff','--exit-code']);
result.scope={...result.scope,old_full_ac_rows_byte_unchanged:true,ac048_052:'passed',ac053_at_examined_commit:'pending as required before this independent result',tasks_complete:5,tasks_total:6,version:'0.0.0',compiled_artifacts_committed:false,markdown_links_and_openspec_strict:'passed',runtime_retests:'not run; same technical content'};
result.verdict='passed; AC-053 may be registered passed and TASK-053 completed for this finite slice';
log+='\n35 technical file hashes matched; '+result.copies.length+' evidence files byte-identical; report projection exact; old full AC block unchanged; strict exit0; 5/6 before result as required.\nVERDICT='+result.verdict+'\n';
writeFileSync(dir+'final-integration-check.json',JSON.stringify(result,null,2)+'\n');writeFileSync(dir+'final-integration.log',log);
console.log(JSON.stringify({source:sha,technical:result.technical.length,evidence_copies:result.copies.length,scope:result.scope,verdict:result.verdict},null,2));

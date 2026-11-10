import fs from 'node:fs';
import crypto from 'node:crypto';
import {execFileSync} from 'node:child_process';
const d='/workspace/work/colors-resize-fixture',repo=d+'/source';
const base='3138d1a549c5941793b24183bd71cad74d2c688c',fixed='0d46c35456db148f08bd407825a4fd559467249a';
const hash=b=>crypto.createHash('sha256').update(b).digest('hex');
const git=(...a)=>execFileSync('git',['-C',repo,...a],{encoding:'utf8'});
const data=JSON.parse(fs.readFileSync(d+'/raw/crf001/summary.json','utf8'));
const source=Object.entries(data.file_sha256).map(([file,expected])=>({file,expected,actual:hash(git('show',fixed+':'+file))}));
const diff=git('diff','-U10',base,fixed);
fs.writeFileSync('fixed.diff',diff);
const diffMatches=diff===fs.readFileSync('/workspace/work/terminal.ui/.superpowers/sdd/tasks-fix-uncertain-glyph-advance/colors-crf001-round1.diff','utf8');
const evidence=fs.readFileSync(d+'/evidence.sha256','utf8').trim().split('\n').map(l=>({file:l.slice(66),expected:l.slice(0,64)})).filter(e=>e.file.startsWith('raw/crf001/')).map(e=>({...e,actual:hash(fs.readFileSync(d+'/'+e.file))}));
const transform=s=>s.replace("from '../support/terminal_frames.mjs'",`from 'file://${repo}/tests/support/terminal_frames.mjs'`)+'\nexport { Session as ControlledSession };\n';
const sourceModules={};
for(const [folder,commit] of [['old-stop-red',base],['fixed-stop-green',fixed],['final-stop-controls',fixed]]) {
 const module=fs.readFileSync(d+'/raw/crf001/'+folder+'/artifacts/current-stop-module.mjs','utf8');
 sourceModules[folder]={expected:hash(transform(git('show',commit+':tests/colors/pty.mjs'))),actual:hash(module),matches:module===transform(git('show',commit+':tests/colors/pty.mjs'))};
}
const final=JSON.parse(fs.readFileSync(d+'/raw/crf001/final-stop-controls/artifacts/observations.json','utf8'));
const old=JSON.parse(fs.readFileSync(d+'/raw/crf001/old-stop-red/artifacts/observations.json','utf8'));
const commands={};for(const name of ['old-stop-red','final-stop-controls','resize-controls','actual-old91-colors'])commands[name]=JSON.parse(fs.readFileSync(d+'/raw/crf001/'+name+'/execution.json','utf8'));
const summary={base,fixed,parent:git('rev-parse',fixed+'^').trim(),changed_files:git('diff','--name-only',base,fixed).trim().split('\n'),diff_package_matches:diffMatches,source_hashes_match:source.every(e=>e.expected===e.actual),raw_count:evidence.length,raw_hashes_match:evidence.every(e=>e.expected===e.actual),sourceModules,old_invalid_false_accept_count:old.observations.filter(o=>!o.expectedAccepted&&o.accepted).length,new_invalid_reject_count:final.observations.filter(o=>!o.expectedAccepted&&!o.accepted).length,new_legal_accept_count:final.observations.filter(o=>o.expectedAccepted&&o.accepted).length,all_final_actual_children_exit0:final.observations.every(o=>o.actualChildExit===0&&o.actualChildSignal===null&&o.matched),commands};
fs.writeFileSync('hashes.json',JSON.stringify({summary,source,evidence},null,2)+'\n');
console.log(JSON.stringify(summary,null,2));
if(!diffMatches||!summary.source_hashes_match||!summary.raw_hashes_match||Object.values(sourceModules).some(x=>!x.matches)||!summary.all_final_actual_children_exit0||summary.new_invalid_reject_count!==5||summary.new_legal_accept_count!==3)process.exitCode=1;

// Sole binding entrypoint. Execution still needs root's independent actual GO.
import assert from 'node:assert/strict';
import {readFileSync} from 'node:fs';
import {createHash} from 'node:crypto';
import {resolve,join} from 'node:path';
import {pathToFileURL,fileURLToPath} from 'node:url';
import * as binding from './binding.mjs';
assert.equal(process.env.C008_ROOT_ACTUAL_GO,'1','NOTEXECUTED until root actual GO');
const own=fileURLToPath(new URL('.',import.meta.url));
const manifest=JSON.parse(readFileSync(join(own,'transport-interfaces.json'),'utf8'));
for(const entry of manifest.interfaces)assert.equal(createHash('sha256').update(readFileSync(entry.path)).digest('hex'),entry.sha256,'frozen transport drift '+entry.path);
const profile=binding.config();
assert.equal(profile.hostKind,process.env.C008_HOST_KIND,'actual kind/profile identity');
assert(process.env.C008_SOURCE,'fixed final source required');assert.equal(resolve(process.cwd()),resolve(process.env.C008_SOURCE),'cwd must resolve final public binary paths');
const root=resolve(process.env.C008_TEST_INPUT_ROOT??join(own,'inputs'));
const index=JSON.parse(readFileSync(join(own,'index.json'),'utf8'));
for(const item of index.files.filter(x=>x.role==='fixed-source-input')){
 const relative=item.path.slice('inputs/'.length);assert.equal(createHash('sha256').update(readFileSync(join(root,relative))).digest('hex'),item.sha256,'frozen test input drift '+relative);
}

const [group,name,directory,...sizes]=process.argv.slice(2);
assert(['composition','showcase','modal'].includes(group),'case group');
binding.setApplication(group==='composition'?'composition':'theme_showcase');
const app=await import(pathToFileURL(join(root,'tests/composition/application/pty.mjs')));
const transport=await import(pathToFileURL(manifest.interfaces.find(x=>x.path.endsWith(binding.isVT()?'/vt-session.mjs':'/actual-session.mjs')).path));
if(binding.isVT())transport.installVTSession(app.Session);else transport.installActualSession(app.Session);
binding.attach(app.Session);
const table={composition:{module:app,cases:['startup','interactions','minimal']},showcase:{path:'tests/theme_showcase/pty.mjs',cases:['startup','fullCycle','retainedState','fileReload','absentFile']},modal:{path:'tests/theme_showcase/modal-keys.mjs',cases:['previewSwitch','popupSwitch']}};
const entry=table[group];assert(entry.cases.includes(name),'existing frozen case only');
const module=entry.module??await import(pathToFileURL(join(root,entry.path)));
const args=name==='startup'?binding.dimensions(Number(sizes[0]??80),Number(sizes[1]??24)):[];
assert(directory,'owned evidence directory required');await module[name](resolve(directory),...args);
console.log(JSON.stringify({case:group+'/'+name,status:binding.records().length?'COMPLETED_WITH_EXPLICIT_SUBASSERTION_LIMITS':'APPLICABLE_ASSERTIONS_PASSED',subassertions:binding.records(),finalAcceptance:false}));

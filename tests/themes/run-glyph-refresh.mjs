#!/usr/bin/env node
// Append-only runner: hashes/selects just this refresh; old run.py remains intact.
import { spawnSync } from 'node:child_process';
import { createHash } from 'node:crypto';
import { mkdirSync, readFileSync, writeFileSync, appendFileSync, readdirSync } from 'node:fs';
import { resolve, join } from 'node:path';
import { fileURLToPath } from 'node:url';
const here=fileURLToPath(new URL('.',import.meta.url)),root=resolve(here,'../..');
const mode=process.argv[2]??'all',logs=resolve(process.argv[3]??'/tmp/theme-glyph-refresh');
if(!['control','target','offline','session','all'].includes(mode)) throw Error('usage: run-glyph-refresh.mjs [control|target|offline|session|all] LOGDIR');
mkdirSync(logs,{recursive:true});
const sha=spawnSync('git',['rev-parse','HEAD'],{cwd:root,encoding:'utf8'}).stdout.trim();
const hashes={};
function hashTree(path) {
  for(const entry of readdirSync(path,{withFileTypes:true})) {
    if(['target','__pycache__','build-script-cache','.cjtui-build'].includes(entry.name)) continue;
    const full=join(path,entry.name);
    if(entry.isDirectory()) hashTree(full);
    else if(!/\.(a|o)$/.test(entry.name)&&!['cjpm.lock','cangjie-repo.toml'].includes(entry.name))
      hashes[full.slice(root.length+1)]=createHash('sha256').update(readFileSync(full)).digest('hex');
  }
}
for(const name of ['glyph-refresh','glyph-session','glyph-language','glyph-target']) hashTree(join(here,name));
for(const name of ['glyph-pty.mjs','run-glyph-refresh.mjs','GLYPH-REFRESH.md']) {
  hashes['tests/themes/'+name]=createHash('sha256').update(readFileSync(join(here,name))).digest('hex');
}
const fixture='tests/glyphs/session/native/glyph_syscall_wrap.c';
hashes[fixture]=createHash('sha256').update(readFileSync(join(root,fixture))).digest('hex');
writeFileSync(join(logs,'source-hashes.json'),JSON.stringify(hashes,null,2)+'\n');
function run(name,argv,cwd=root,extra={}) {
  const utc=new Date().toISOString();
  const result=spawnSync(argv[0],argv.slice(1),{cwd,env:{...process.env,...extra}});
  writeFileSync(join(logs,name+'.stdout'),result.stdout??Buffer.alloc(0));
  writeFileSync(join(logs,name+'.stderr'),result.stderr??Buffer.from(String(result.error??'')));
  appendFileSync(join(logs,'commands.jsonl'),JSON.stringify({name,utc,sha,cwd,argv,exit:result.status,signal:result.signal})+'\n');
  console.log(`${name}: exit ${result.status}`);
  if(result.status!==0) process.exit(result.status??1);
}
run('root-build',['cjpm','build']);
run('glyph-api-build',['cjpm','build'],join(root,'tests/glyphs/api'));
run('glyph-api-run',[join(root,'tests/glyphs/api/target/release/bin/main')]);
const native=join(here,'glyph-session/native');
run('adapter-compile',['gcc','-std=c11','-Wall','-Wextra','-Werror','-fPIC','-O2','-c',join(native,'theme_glyph_wrap.c'),'-o',join(native,'theme_glyph_wrap.o')]);
run('adapter-archive',['ar','rcs',join(native,'libtheme_glyph_wrap.a'),join(native,'theme_glyph_wrap.o')]);
run('language-build',['cjpm','build'],join(here,'glyph-language'));
run('language-run',[join(here,'glyph-language/target/release/bin/main')]);
run('native-input-control',['node',join(here,'glyph-pty.mjs'),'control',join(logs,'control-pty')]);
if(mode==='control') process.exit(0);
if(mode==='target'||mode==='all') {
  run('theme-target-build',['cjpm','build'],join(here,'glyph-target'));
  run('theme-target-run',[join(here,'glyph-target/target/release/bin/main')]);
  if(mode==='target') process.exit(0);
}
if(mode==='offline'||mode==='all') {
  run('theme-offline-build',['cjpm','build'],join(here,'glyph-refresh'));
  const files=join(logs,'files');mkdirSync(files,{recursive:true});
  run('theme-offline-run',[join(here,'glyph-refresh/target/release/bin/main')],root,{CJTUI_THEME_GLYPH_FILES:files});
}
if(mode==='session'||mode==='all') {
  run('theme-session-build',['cjpm','build'],join(here,'glyph-session'));
  run('theme-session-run',['node',join(here,'glyph-pty.mjs'),'session',join(logs,'theme-pty')]);
}
console.log('PASS selected appended public Theme/Glyph cases');

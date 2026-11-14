import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import zlib from 'node:zlib';
import {spawn,spawnSync} from 'node:child_process';
import {pipeline} from 'node:stream/promises';
import {Readable} from 'node:stream';
import {safe,digest,logical,load,groupData,fail} from './core.mjs';
import {verifyShard} from './tar.mjs';
const run=(root,args)=>{const r=spawnSync('git',['-C',root,...args],{encoding:'buffer',maxBuffer:64*1024*1024});if(r.status!==0) fail(`git ${args[0]} failed`);return r.stdout.toString();};
const syncDir=p=>{const fd=fs.openSync(p,'r');try{fs.fsyncSync(fd);}finally{fs.closeSync(fd);}};
const atomic=(p,data)=>{const tmp=p+'.'+crypto.randomBytes(8).toString('hex')+'.tmp'; const fd=fs.openSync(tmp,'wx',0o600);try{fs.writeFileSync(fd,data);fs.fsyncSync(fd);}finally{fs.closeSync(fd);}fs.renameSync(tmp,p);syncDir(path.dirname(p));};
function inventory(root,group,keepFile,removing=false) {
  if(!/^[A-Za-z0-9_-]+$/.test(group)) fail('invalid or protected group');
  const all=run(root,['ls-files','-z']).split('\0').filter(Boolean), prefix=`docs/reviews/${group}/`;
  const files=all.filter(p=>p.startsWith(prefix)&&!p.includes('/.archive-v1/')).sort(); if(!files.length) fail('empty group');
  if(!removing && run(root,['status','--porcelain=v1','--untracked-files=all','--',prefix]).trim()) fail('group has changed or untracked files');
  if(removing && run(root,['ls-files','--others','--exclude-standard','-z','--',prefix]).split('\0').filter(p=>p&&!p.startsWith(prefix+'.archive-v1/')).length) fail('untracked files in group');
  const supplied=JSON.parse(fs.readFileSync(keepFile,'utf8')); const entries=Array.isArray(supplied)?supplied:supplied?.version===1&&Array.isArray(supplied.keep)&&Array.isArray(supplied.keepDirectories)?supplied.keep:null; if(!entries) fail('invalid keep inventory');
  const keep=new Set(entries.map(p=>logical(p,root)).filter(p=>p.startsWith(prefix))); for(const p of keep) if(!files.includes(p)) fail(`unknown keep entry: ${p}`);
  const suppliedDirectories=Array.isArray(supplied)?[]:supplied.keepDirectories.filter(p=>p.startsWith(prefix)); for(const p of suppliedDirectories) {logical(p,root);if(!fs.statSync(safe(root,p)).isDirectory()) fail(`not a directory: ${p}`);}
  for(const p of files) {let s; try{s=fs.lstatSync(safe(root,p));}catch(e){if(removing&&e.code==='ENOENT')continue;throw e;} if(!s.isFile()) fail(`not regular: ${p}`); if(/\.(?:md|png|sha|sha256|sha512)$/i.test(p)||/\/(?:[^/]*(?:index|manifest)[^/]*)\.jsonl?$/i.test(p)||(s.mode&0o111)||p==='docs/reviews/R16/execution/raw/host-xorg-dummy.conf') keep.add(p);}
  // Conservative scan: retain exact tracked paths occurring anywhere in tracked text.
  const fileSet=new Set(files); for(const source of all) { if(source.startsWith('docs/reviews/')) continue; let b; try {const f=safe(root,source); if(!fs.statSync(f).isFile()) continue; b=fs.readFileSync(f);}catch(e){throw new Error(`cannot scan tracked file ${source}: ${e.message}`);} if(b.includes(0)) continue; const text=b.toString('utf8'); for(const match of text.matchAll(/docs\/reviews\/[A-Za-z0-9_./+@%=-]+/g)) {let p=match[0]; while(p&&!fileSet.has(p)) p=p.slice(0,-1); if(fileSet.has(p)) keep.add(p);}}
  // Match the repository checker, including untracked Markdown in docs and openspec.
  function walk(dir) {if(!fs.existsSync(dir)) return []; const out=[]; for(const d of fs.readdirSync(dir,{withFileTypes:true})) {const p=path.join(dir,d.name); if(d.isSymbolicLink()) continue; if(d.isDirectory()) out.push(...walk(p)); else if(d.isFile()&&p.endsWith('.md')) out.push(p);} return out;}
  const linkedDirectories=new Set(suppliedDirectories);
  const markdown=['AGENTS.md','BATTLE_PROTOCOL.md','ENGINEERING_TASK_DECOMPOSITION.md','CONTRIBUTING.md','README.md'].map(p=>path.join(root,p)).filter(fs.existsSync).concat(walk(path.join(root,'docs')),walk(path.join(root,'openspec')));
  for(const f of markdown) {const text=fs.readFileSync(f,'utf8'); for(const m of text.matchAll(/\]\(([^)]+)\)/g)) {const link=m[1].split('#')[0]; if(!link||/^(?:https?:|app:|mailto:|<)/.test(link)||link.includes('<'))continue; const target=path.resolve(path.dirname(f),link); if(!fs.existsSync(target)) fail(`broken link: ${f} -> ${link}`); const rel=path.relative(root,target).split(path.sep).join('/'); if(fileSet.has(rel)) keep.add(rel); if(rel.startsWith(prefix)&&fs.statSync(target).isDirectory()) linkedDirectories.add(rel); }}
  return {files,keep,linkedDirectories};
}
async function tar(root,paths,dest) {
  const list=dest+'.list'; fs.writeFileSync(list,paths.join('\0')+'\0',{flag:'wx'});
  try { const child=spawn('tar',['--create','--gzip','--format=gnu','--no-recursion','--null','--verbatim-files-from','--files-from',list,'--file',dest],{cwd:root,stdio:['ignore','ignore','pipe'],env:{...process.env,GZIP:'-n'}}); let error='';child.stderr.on('data',c=>error+=c); const code=await new Promise((resolve,reject)=>{child.on('error',reject);child.on('close',resolve);});if(code!==0)fail(`tar failed: ${error}`); } finally {fs.unlinkSync(list);}
}
export async function pack(root,group,keepFile) {
  const {files,keep,linkedDirectories}=inventory(root,group,keepFile), base=`docs/reviews/${group}/.archive-v1`, dir=path.join(root,base); if(fs.existsSync(dir)) fail('archive already exists; inspect and recover before retry');
  const parent=path.dirname(dir), tmp=path.join(parent,`.archive-v1-pending-${crypto.randomBytes(6).toString('hex')}`);fs.mkdirSync(tmp);
  try {
    const records=[]; for(const p of files) {const f=safe(root,p),s=fs.lstatSync(f),d=await digest(f);records.push({path:p,type:'file',mode:s.mode&0o7777,size:d.size,sha256:d.sha256,shard:'',member:p,inline:keep.has(p)});}
    const shards=[]; let batch=[], bytes=0; const flush=async()=>{if(!batch.length)return;const name=`part-${String(shards.length+1).padStart(6,'0')}.tar.gz`, dest=path.join(tmp,name), sp=`${base}/${name}`; const stat=fs.statfsSync(root); if(stat.bavail*stat.bsize < bytes*2+4*1024*1024) fail('insufficient free space'); await tar(root,batch.map(r=>r.path),dest);for(const r of batch)r.shard=sp;const d=await digest(dest);shards.push({path:sp,sha256:d.sha256});batch=[];bytes=0;};
    for(const r of records) {if(batch.length&&(batch.length>=500||bytes+r.size>4*1024*1024))await flush();batch.push(r);bytes+=r.size;}await flush();
    for(const s of shards) await verifyShard(root,s,records.filter(r=>r.shard===s.path),undefined,undefined,path.join(tmp,path.basename(s.path)));
    for(const r of records){const d=await digest(safe(root,r.path));if(d.sha256!==r.sha256||d.size!==r.size)fail(`input changed: ${r.path}`);}
    fs.writeFileSync(path.join(tmp,'retention.json'),JSON.stringify({group,keep:[...keep].sort(),linkedDirectories:[...linkedDirectories].sort()},null,2)+'\n',{flag:'wx'});
    const manifest=path.join(tmp,'manifest.jsonl.gz'); await pipeline(Readable.from([records.map(r=>JSON.stringify(r)+'\n').join('')]),zlib.createGzip({mtime:0}),fs.createWriteStream(manifest,{flags:'wx'})); const md=await digest(manifest);
    for(const name of fs.readdirSync(tmp)) {const fd=fs.openSync(path.join(tmp,name),'r');try{fs.fsyncSync(fd);}finally{fs.closeSync(fd);}} syncDir(tmp); fs.renameSync(tmp,dir); syncDir(parent);
    const catDir=path.join(root,'docs/reviews/archive-v1');fs.mkdirSync(catDir,{recursive:true});const catFile=path.join(catDir,'catalog.json');let catalog=fs.existsSync(catFile)?await load(root):{version:1,groups:{}};if(Object.hasOwn(catalog.groups,group))fail('group already cataloged');catalog.groups[group]={baselineHead:run(root,['rev-parse','HEAD']).trim(),manifest:{path:`${base}/manifest.jsonl.gz`,sha256:md.sha256},shards};atomic(catFile,JSON.stringify(catalog,null,2)+'\n');
    console.log(JSON.stringify({group,files:records.length,retained:keep.size,shards:shards.length}));
  } finally {if(fs.existsSync(tmp))fs.rmSync(tmp,{recursive:true,force:true});}
}
export async function remove(root,group,keepFile) {
  const {files,keep}=inventory(root,group,keepFile,true), catalog=await load(root), data=await groupData(root,catalog,group);
  if(files.length!==data.records.length || files.some((p,i)=>p!==data.records[i].path)) fail('tracked inventory changed');
  for(const r of data.records) if(keep.has(r.path)&&!r.inline) fail(`retention inventory changed: ${r.path}`);
  for(const s of data.shards.values())await verifyShard(root,s,data.records.filter(r=>r.shard===s.path));
  for(const r of data.records) {if(r.inline||keep.has(r.path))continue; let f; try {f=safe(root,r.path);}catch(e){if(e.code==='ENOENT')continue;throw e;} const s=fs.lstatSync(f),d=await digest(f); if(!s.isFile()||(s.mode&0o7777)!==r.mode||d.size!==r.size||d.sha256!==r.sha256)fail(`changed before removal: ${r.path}`); fs.unlinkSync(f);}
}

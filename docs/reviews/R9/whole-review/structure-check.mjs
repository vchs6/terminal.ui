import {execFileSync} from 'node:child_process';
import {createHash} from 'node:crypto';
const git=(...a)=>execFileSync('git',a,{encoding:'utf8'});
const files=rev=>git('ls-tree','-r','--name-only',rev,'src').trim().split('\n').filter(x=>x.endsWith('.cj'));
const tokenize=s=>(s.replace(/^\s*(?:package|(?:public )?import)\b[^\n]*/gm,'').match(/"(?:\\.|[^"\\])*"|'(?:\\.|[^'\\])*'|\/\/[^\n]*|\/\*[\s\S]*?\*\/|[A-Za-z_][A-Za-z_0-9]*|[0-9]+|[^\s]/g)||[]).filter(x=>!x.startsWith('//')&&!x.startsWith('/*')&&x!==';');
function definitions(rev){ const out=new Map(); for(const f of files(rev)){const ts=tokenize(git('show',`${rev}:${f}`)); let start=0,depth=0; for(let i=0;i<ts.length;i++){if(ts[i]==='{')depth++; if(ts[i]==='}'&&--depth===0){ const body=ts.slice(start,i+1), key=body.slice(0,body.indexOf('{')).join(' '); if(out.has(key))throw Error('duplicate '+key);out.set(key,{f,body:JSON.stringify(body),hash:createHash('sha256').update(JSON.stringify(body)).digest('hex')});start=i+1;}} if(start!==ts.length)throw Error('unparsed '+f); } return out; }
const before=definitions('HEAD^'),after=definitions('HEAD');
for(const [k,v] of before){const n=after.get(k);if(!n)throw Error('missing '+k);if(n.body!==v.body)throw Error('changed '+k);console.log(`${k}\n  ${v.f} -> ${n.f} ${v.hash}`);}
for(const k of after.keys())if(!before.has(k))throw Error('added '+k);
console.log(`PASS ${before.size} top-level definition token streams preserved (imports/package/comments/whitespace/semicolons excluded)`);
for(const f of files('HEAD')){const s=git('show',`HEAD:${f}`);const types=[...s.matchAll(/^(?:public )?(?:class|struct|enum)\s+(\w+)/gm)].map(m=>m[1]);if(types.length>1)throw Error('multiple types '+f);const expected='cjtui'+f.slice(3,f.lastIndexOf('/')).replaceAll('/','.');const actual=s.match(/^package (.*)$/m)?.[1];if(actual!==expected)throw Error(`package ${f} ${actual} != ${expected}`);console.log(`PACKAGE ${f} ${actual} TYPES ${types.join(',')||'(pure functions/re-exports)'}`);}
console.log('PASS single type per file and package-directory correspondence');

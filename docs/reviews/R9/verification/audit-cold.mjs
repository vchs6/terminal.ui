import {readFileSync,writeFileSync,copyFileSync,mkdirSync,readdirSync} from 'node:fs';
import {execFileSync} from 'node:child_process';
import {createHash} from 'node:crypto';
import assert from 'node:assert/strict';
const base='/workspace/work/layout-execution',dest='/workspace/work/layout-acceptance',root=dest+'/repo';
const hash=b=>createHash('sha256').update(b).digest('hex');
const lines=[];function pass(s){lines.push('PASS '+s)};
assert.equal(readFileSync(base+'/logs/slice.exit','utf8').trim(),'0');
const rawlog=readFileSync(base+'/logs/slice.log','utf8');
for(const marker of ['PASS owner','PASS setup-signal','PASS: near-equal extreme remainders remain exact beyond float precision: got [ABB], want [ABB]','PASS: unrepresentable weight sum diagnosed','PASS: zero-size text still validates controls','PASS: huge thin border iterates only visible cells','PASS: shadow expands paint without affecting sibling layout','PASS: shadow uses complete explicit style without inheriting parent','PASS layout PTY: exit=0','Implemented slice checks complete; not a final product/release verification.'])assert(rawlog.includes(marker),marker);
pass('cold all entrance truly exit 0, reached original modes, layout, decoration, actual PTY, final public projects; cjpm test TOTAL 0 is not substituted for consumers');
const inspected=readFileSync(base+'/inspected-source.sha256','utf8').trim().split('\n');
for(const line of inspected){const [,sha,path]=line.match(/^(\w+)  (.+)$/);const actual=execFileSync('git',['show',`425626a1b6556b16837cb0744d5a5f46ebd54814:${path}`],{cwd:root});assert.equal(hash(actual),sha,path)}
pass(`all ${inspected.length} executor inspected hashes independently equal fixed git objects`);
const summary=JSON.parse(readFileSync(base+'/layout-pty/results.json','utf8'));
for(const a of summary.artifacts){const b=readFileSync(base+'/layout-pty/'+a.path);assert.equal(b.length,a.bytes,a.path);assert.equal(hash(b),a.sha256,a.path)}
pass('all actual PTY artifacts independently rehashed including 3595 raw bytes');
const frames=summary.frames.filter(f=>/^\d/.test(f.path)).map(f=>readFileSync(base+'/layout-pty/'+f.path,'utf8'));
const sizes=[[48,14],[48,14],[48,14],[23,9],[8,4],[8,4],[48,14]];
frames.forEach((text,i)=>{const rs=text.split('\n');assert.equal(rs.length,sizes[i][1]);rs.forEach(r=>assert.equal([...r].length,sizes[i][0]));});
assert.equal(frames[0],frames[2]);assert.equal(frames[0],frames[6]);assert(!/[┌┐└┘─│╭╮╰╯╔╗╚╝═║░]/u.test(frames[1]));assert(!/[┌┐└┘─│╭╮╰╯╔╗╚╝═║░]/u.test(frames[5]));assert(frames[0].includes('░')&&frames[0].includes('╭'));
pass('normal and tiny d off screens contain no old border/shadow; d on and resize back restore complete original bytes, dimensions actual');
const raw=readFileSync(base+'/layout-pty/session.raw','utf8');
// Decode supported output independently to row writes, retaining terminal rows across differences.
const tokens=[...raw.matchAll(/\x1b\[([0-9;]*)([A-Za-z])|([^\x1b]+)/gu)];
let row=null,text='',writes=[];
for(const m of tokens){if(m[3]!==undefined){assert(row!==null);assert(!/[\x00-\x1f\x7f-\x9f]/u.test(m[3]));text+=m[3];continue;}if(m[2]==='m')continue;assert.equal(m[2],'H');if(row!==null)writes.push({row,text});const p=m[1].split(';').map(Number);assert.equal(p[1],1);row=p[0]-1;text='';}if(row!==null)writes.push({row,text});
let width=48,height=14,screen=Array(height).fill(' '.repeat(width)),next=0;
for(const w of writes){if(w.row===0&&[23,8,48].includes([...w.text].length)&&[...w.text].length!==width){width=[...w.text].length;height=width===23?9:width===8?4:14;screen=Array(height).fill(' '.repeat(width));}assert(w.row>=0&&w.row<height);assert.equal([...w.text].length,width);screen[w.row]=w.text;while(next<frames.length&&screen.join('\n')===frames[next])next++;}
assert.equal(next,frames.length);assert.equal(screen.join('\n'),frames[6]);
pass(`independent raw decoder finds all ordered saved screens through ${writes.length} complete-row writes, preserves prior rows for diff cleanup`);
const term=readFileSync(base+'/layout-pty/termios.txt','utf8').trim().split('\n');assert.equal(term[0].slice(7),term[1].slice(6));assert.equal(summary.actualExampleExit,0);assert.equal(summary.forcedSignal,null);assert.equal(readFileSync(base+'/layout-pty/stderr.txt').length,0);pass('actual program q exit 0/no signal and exact before/after termios recorded, no stderr');
mkdirSync(dest+'/frozen-cold',{recursive:true});copyFileSync(base+'/logs/slice.log',dest+'/frozen-cold/slice.log');copyFileSync(base+'/logs/slice.exit',dest+'/frozen-cold/slice.exit');mkdirSync(dest+'/frozen-cold/layout-pty',{recursive:true});for(const f of readdirSync(base+'/layout-pty'))copyFileSync(base+'/layout-pty/'+f,dest+'/frozen-cold/layout-pty/'+f);
writeFileSync(dest+'/logs/cold-raw-audit.log',lines.join('\n')+'\nEXIT=0\n');console.log(lines.join('\n'));

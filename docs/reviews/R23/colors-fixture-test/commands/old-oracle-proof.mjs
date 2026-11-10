import assert from 'node:assert/strict';
import { execFileSync } from 'node:child_process';
import { readFile, writeFile } from 'node:fs/promises';
const root = '/workspace/work/colors-resize-fixture/source';
const source=execFileSync('git',['show','91c22f82adcd2412d9509b9872ff63450ba81af9:tests/colors/pty.mjs'],{cwd:root,encoding:'utf8'});
const body=source.slice(source.indexOf('function width('),source.indexOf('class Session'));
const url='data:text/javascript;base64,'+Buffer.from("import assert from 'node:assert/strict'; import { StringDecoder } from 'node:string_decoder';\n"+body+'\nexport { Screen };').toString('base64');
const {Screen}=await import(url);
const raw=await readFile('/workspace/work/colors-resize-fixture/raw/original-failure/08-colors-session/pty-artifacts/actual-example/session.raw');
const actualMiddle=raw.subarray(5189,6705);
const middle=new Screen(100,12);middle.feed(actualMiddle);assert.equal(middle.snapshot().length,12);
const coherentOld=Buffer.from(Array.from({length:40},(_,i)=>`\x1b[0m\x1b[${i+1};1H${'O'.repeat(100)}\x1b[0m`).join(''));
for(const [name,frame] of [['actual-intermediate-100x12',actualMiddle],['coherent-old-inflight-100x40',coherentOld]]) {
 const parser=new Screen(100,40);parser.resize(31,12);
 assert.throws(()=>parser.feed(frame),/complete row 1/);
 console.log(`CONFIRMED old oracle rejects lawful ${name}`);
}
await writeFile('/workspace/work/colors-resize-fixture/raw/old-oracle-proof.json',JSON.stringify({actualIntermediateAcceptedAtRealPair:[100,12],oldPrematureTarget:[31,12],oldMisrejects:['actual-intermediate-100x12','coherent-old-inflight-100x40'],oldSource:'91c22f82adcd2412d9509b9872ff63450ba81af9',actualMiddleOffsets:[5189,6705]},null,2));

// Oracle replay of immutable existing observations only; no product execution.
import {readFileSync,writeFileSync} from 'node:fs';
import {resolve} from 'node:path';
import {pathToFileURL} from 'node:url';
const base=resolve(process.argv[2]);
const {verifyLive,verifyKeyboardModeStartup,parseResults}=await import(pathToFileURL(base+'/source/tests/session_extensions/oracle.mjs'));
const proof=JSON.parse(readFileSync(base+'/raw/proof.json'));
let count=0;
for(const item of proof.cases){
 const d=item.directory,wire=readFileSync(d+'/wire.bin'),raw=readFileSync(d+'/session.raw');
 const firstSave=raw.indexOf(wire.subarray(0,Math.min(wire.length,7)));
 if(firstSave<8)throw Error('startup boundary missing before armed save');
 verifyKeyboardModeStartup(raw.subarray(0,firstSave));
 verifyLive(parseResults(readFileSync(d+'/results.tsv','utf8')),wire,readFileSync(d+'/native.tsv','utf8'),'fault-set',item.route,0,readFileSync(d+'/all-wire.bin'));
 console.log('PASS oracle-only stored observation '+item.group+' '+d);count++;
}
console.log('PASS oracle-only replay observations='+count+'; no new product runtime/build');

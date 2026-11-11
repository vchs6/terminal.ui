import {readFileSync as read,writeFileSync as write} from 'node:fs';
import {verifyLive,parseResults} from '../source/tests/session_extensions/oracle.mjs';
const results=[];
for(const scenario of ['wire','unknown-title']) {
 const p=`/workspace/work/glyph-execution/raw/vt/session-${scenario}/evidence`;
 verifyLive(parseResults(read(p+'/results.tsv','utf8')),read(p+'/wire.bin'),read(p+'/native.log','utf8'),scenario,'Direct',0,read(p+'/all-wire.bin'));
 results.push({scenario,route:'Direct',formalOracle:'verifyLive',passed:true,wireBytes:read(p+'/wire.bin').length});
}
write('/workspace/work/glyph-execution/raw/vt-session-formal-oracle.json',JSON.stringify(results,null,2));
console.log('PASS formal148 verifyLive on two actual kernelVT result/native/exactwire datasets');

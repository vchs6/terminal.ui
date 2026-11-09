import {readFileSync,writeFileSync} from 'node:fs';
import {createHash} from 'node:crypto';
const base='/workspace/work/first-slice-execution/';
const report=JSON.parse(readFileSync(base+'native-report.json','utf8'));
const checks=report.artifacts.map(a=>{const bytes=readFileSync(base+a.path);const actual=createHash('sha256').update(bytes).digest('hex');return {path:a.path,expected:a.sha256,actual,size:bytes.length,ok:actual===a.sha256&&bytes.length===a.size};});
writeFileSync('/workspace/work/first-slice-acceptance/native-artifact-check.json',JSON.stringify(checks,null,2)+'\n');
console.log(JSON.stringify({checked:checks.length,failed:checks.filter(x=>!x.ok)},null,2));
if(checks.some(x=>!x.ok))process.exit(1);

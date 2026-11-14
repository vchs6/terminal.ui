import assert from 'node:assert/strict';
import {spawnSync} from 'node:child_process';
import {mkdirSync,readFileSync,writeFileSync} from 'node:fs';
import {createHash} from 'node:crypto';
import {resolve,join} from 'node:path';
import {smokeGoldens,presets,frame} from './fixtures.mjs';
const binary=resolve('examples/theme_showcase/target/release/bin/main');
const artifacts=resolve(process.env.CJTUI_SHOWCASE_ARTIFACTS??'tests/theme_showcase/target/evidence');
mkdirSync(artifacts,{recursive:true});
const expected=()=>{
  let out='';
  for(const name of presets){
    for(const [w,h] of [[80,24],[40,12],[16,6]])
      out+=`BEGIN ${name} ${w}x${h}\n${frame(smokeGoldens,name,w,h).join('\n')}\nEND ${name}\n`;
    out+=`INFO ${name} revision=0 request=0\n`;
  }
  return out+'PASS theme showcase\n';
};
export function verify(result,success){
  assert.equal(result.error,undefined,'ordinary executable exists and completes');
  assert.equal(result.signal,null,'signal is not a valid direct exit');
  assert(Number.isInteger(result.status),'direct exit available');
  if(success){
    assert.equal(result.status,0);
    assert.equal(result.stderr,'');
    assert(!result.stdout.includes('\x1b'),'headless output is plain');
    assert.equal(result.stdout,expected(),'four complete literal grids at three sizes');
  }else{
    assert.notEqual(result.status,0,'invalid CLI must return nonzero');
    assert((result.stdout+result.stderr).trim().length>0,'invalid CLI diagnoses');
  }
}
if(process.argv[1]===new URL(import.meta.url).pathname){
  const cases=[['smoke',['--smoke'],true],['unknown',['--invalid'],false],
    ['missing-path',['--theme-file'],false],['mixed',['--smoke','--theme-file','anything'],false]];
  let failures=0;
  for(const [label,args,success] of cases){
    const result=spawnSync(binary,args,{encoding:'utf8',timeout:15000,maxBuffer:2*1024*1024,
      env:{...process.env,TERM:'dumb',COLORTERM:''}});
    const prefix=join(artifacts,`direct-${label}`);
    writeFileSync(prefix+'.stdout',result.stdout??'');writeFileSync(prefix+'.stderr',result.stderr??'');
    writeFileSync(prefix+'.json',JSON.stringify({command:[binary,...args],status:result.status,signal:result.signal,
      error:result.error?.message??null,utc:new Date().toISOString(),
      binarySha256:result.error?null:createHash('sha256').update(readFileSync(binary)).digest('hex')},null,2)+'\n');
    try{verify(result,success);console.log(`PASS showcase direct ${label}`)}
    catch(error){failures++;console.error(`FAIL showcase direct ${label}: ${error.message}`)}
  }
  if(failures)process.exitCode=1;
}

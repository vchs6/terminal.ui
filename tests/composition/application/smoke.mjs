import assert from 'node:assert/strict';
import {spawnSync} from 'node:child_process';
import {mkdirSync,writeFileSync,readFileSync} from 'node:fs';
import {createHash} from 'node:crypto';
import {resolve,join} from 'node:path';
import {goldens} from './fixtures.mjs';
const artifacts=resolve(process.env.CJTUI_APPLICATION_ARTIFACTS ?? 'tests/composition/application/target/evidence');
mkdirSync(artifacts,{recursive:true});
const expected = project => goldens.filter(f=>project==='minimal'?f.scene==='minimal':f.scene!=='minimal')
  .map(f=>`BEGIN ${f.scene} ${f.width}x${f.height}\n${f.rows.join('\n')}\nEND ${f.scene}\n`).join('')+
  (project==='minimal'?'PASS minimal\n':'STATE tasks ready=2 done=1 visible=3 notes=Check input\n'+
    'STATE logs total=24 visible=24 query= errorsOnly=false order=oldest\nPASS composition\n');
export function verify(result,wantSuccess,project) {
  assert.equal(result.error,undefined,'direct binary starts and completes within finite deadline');
  assert.equal(result.signal,null,'signal/timeout is not a CLI result');
  assert(Number.isInteger(result.status),'direct exit available');
  if(wantSuccess) {
    assert.equal(result.status,0,'direct --smoke true exit');
    assert.equal(result.stderr,'','successful smoke has no diagnostic');
    assert(!result.stdout.includes('\x1b'),'headless smoke is plain');
    assert.equal(result.stdout,expected(project),'literal startup frames and business-state checks');
  } else {
    assert.notEqual(result.status,0,'invalid CLI must not be hidden by CJPM or wrapper');
    assert((result.stdout+result.stderr).trim().length>0,'invalid CLI has a diagnostic');
  }
}
if(process.argv[1]===new URL(import.meta.url).pathname) {
  let failures=0;
  for(const project of ['minimal','composition']) {
    const binary=resolve(`examples/${project}/target/release/bin/main`);
    for(const [name,args,success] of [['smoke',['--smoke'],true],['invalid',['--invalid'],false],
      ['smoke-invalid',['--smoke','--invalid'],false]]) {
      const result=spawnSync(binary,args,{encoding:'utf8',timeout:15000,maxBuffer:1024*1024,
        env:{...process.env,TERM:'dumb',COLORTERM:''}});
      const prefix=join(artifacts,`${project}-${name}`);
      writeFileSync(prefix+'.stdout',result.stdout??''); writeFileSync(prefix+'.stderr',result.stderr??'');
      writeFileSync(prefix+'.json',JSON.stringify({command:[binary,...args],status:result.status,signal:result.signal,
        error:result.error?.message??null,utc:new Date().toISOString(),
        binarySha256:result.error?.code==='ENOENT'?null:createHash('sha256').update(readFileSync(binary)).digest('hex')},null,2)+'\n');
      try {verify(result,success,project); console.log(`PASS ${project} direct ${name}`);}
      catch(error) {failures++; console.error(`FAIL ${project} direct ${name}: ${error.message}`);}
    }
  }
  if(failures)process.exitCode=1;
}

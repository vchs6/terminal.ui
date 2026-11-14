import { stat, readFile } from 'node:fs/promises';
import { resolve } from 'node:path';
import { fileURLToPath } from 'node:url';
const root=resolve(process.argv[2] ?? fileURLToPath(new URL('../../..',import.meta.url)));
const missing=[];
for(const project of ['composition','minimal']) for(const name of ['cjpm.toml','src/main.cj','README.md']) {
  const path=`examples/${project}/${name}`;
  try { if(!(await stat(resolve(root,path))).isFile())missing.push(path); }
  catch(error) { if(error.code==='ENOENT')missing.push(path); else throw error; }
}
if(missing.length) {
  console.error('FAIL C005 actual example delivery: missing '+missing.join(', '));
  console.error('PENDING: consumer build, direct CLI, smoke, real keys/background/resize, construction review.');
  process.exitCode=1;
} else {
  for(const project of ['minimal','composition']) {
    const text=await readFile(resolve(root,`examples/${project}/cjpm.toml`),'utf8');
    if(!/cjtui\s*=\s*\{\s*path\s*=\s*"\.\.\/\.\."\s*\}/.test(text)) {
      throw Error(`${project} must consume cjtui by ordinary relative project dependency`);
    }
  }
  console.log('PASS C005 required example project/README delivery (construction review still required)');
}

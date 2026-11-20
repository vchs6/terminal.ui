import assert from 'node:assert/strict';
import {readFileSync} from 'node:fs';
import {fileURLToPath, pathToFileURL} from 'node:url';
import {resolve,join} from 'node:path';
import {transform,targetPaths} from './transform.mjs';
const root=resolve(process.env.C008_TEST_INPUT_ROOT??fileURLToPath(new URL('./inputs',import.meta.url)));
const sourceRoot=process.env.C008_SOURCE&&resolve(process.env.C008_SOURCE);
export async function load(url,context,nextLoad){
 const result=await nextLoad(url,context);
 if(!url.startsWith('file:'))return result;
 const path=fileURLToPath(url);
 for(const relative of targetPaths){
  if(path!==resolve(root,relative)&&(!sourceRoot||path!==resolve(sourceRoot,relative)))continue;
  const fixed=readFileSync(new URL('./inputs/'+relative,import.meta.url),'utf8');
  assert.equal(String(result.source),fixed,'INSUFFICIENT_EVIDENCE frozen source drift '+relative);
  return {...result,source:transform(relative,fixed)};
 }
 return result;
}

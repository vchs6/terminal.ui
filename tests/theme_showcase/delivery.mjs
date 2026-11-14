import assert from 'node:assert/strict';
import {existsSync,readFileSync} from 'node:fs';
import {createHash} from 'node:crypto';
import {resolve} from 'node:path';
const files=['examples/theme_showcase/cjpm.toml','examples/theme_showcase/src/main.cj',
  'examples/theme_showcase/README.md','themes/classic.toml','themes/dark.toml',
  'themes/light.toml','themes/high-contrast.toml'];
const missing=files.filter(p=>!existsSync(resolve(p)));
if(missing.length){
  console.error(`RED TASK027 product delivery missing: ${missing.join(', ')}`);
  process.exitCode=1;
}else{
  const manifest=readFileSync('examples/theme_showcase/cjpm.toml','utf8');
  assert.match(manifest,/cjtui\s*=\s*\{\s*path\s*=\s*"\.\.\/\.\."\s*\}/,'ordinary relative dependency');
  const hashes={
    'themes/classic.toml':'73491254d0fc5b7624677b9b40216d3c82664c7c4784964b384b6a9d55a4aac9',
    'themes/dark.toml':'1a6feada861eefb42e9d6598138c2010d7f1e34b65ecece893b66e680d5cb8d0',
    'themes/light.toml':'677951bafdc3d9d0dce62031ebe63f44254e0a5c13bfc05d079b5ef087176bcd',
    'themes/high-contrast.toml':'e933cb0c54ef211c41c2b6cc83c16dc5eb091151e706dfbf439eddec8d48166c'
  };
  for(const [path,expected] of Object.entries(hashes))
    assert.equal(createHash('sha256').update(readFileSync(path)).digest('hex'),expected,`${path} canonical bytes`);
  const readme=readFileSync('examples/theme_showcase/README.md','utf8');
  for(const phrase of ['--theme-file','--smoke','F6','F7','F10'])assert(readme.includes(phrase),`document ${phrase}`);
  console.log('PASS TASK027 delivery files and canonical presets');
}

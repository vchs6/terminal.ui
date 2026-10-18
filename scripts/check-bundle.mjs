import {execFileSync} from 'node:child_process';
import {readFileSync} from 'node:fs';
import {parse} from 'smol-toml';
const archive = process.argv[2];
if (!archive) throw new Error('Usage: npm run check:bundle -- path/to/package.cjp');
const entryTypes = execFileSync('tar', ['-tvzf', archive], {encoding:'utf8'}).trim().split('\n');
if (entryTypes.some(line => !/^[-d]/.test(line))) throw new Error('Product archive must contain only regular files/directories, no links or special entries');
const raw = execFileSync('tar', ['-tzf', archive], {encoding:'utf8'}).trim().split('\n').map(p=>p.replace(/^\.\//,''));
if (raw.some(p=>p.startsWith('/') || p.split('/').includes('..'))) throw new Error('Unsafe archive path');
const manifestEntries = raw.filter(p=>p==='cjpm.toml'||/^[^/]+\/cjpm\.toml$/.test(p));
if (manifestEntries.length!==1) throw new Error('Expected one root manifest');
const prefix = manifestEntries[0].slice(0,-'cjpm.toml'.length);
if (raw.some(p=>!p.startsWith(prefix) && p!==prefix.replace(/\/$/,''))) throw new Error('Files outside product root');
const paths = raw.map(p=>p.slice(prefix.length)).filter(p=>p&&!p.endsWith('/'));
const allowed = /^(?:src\/|examples\/|benchmarks\/|docs\/product\/|cjpm\.toml$|README(?:_zh)?\.md$|LICENSE$|NOTICE$|CHANGELOG\.md$)/;
for (const p of paths) {
  if (!allowed.test(p) || p.split('/').some(s=>s.startsWith('.')||s==='target'||s==='node_modules') || /(?:^|\/)(?:AGENTS\.md|BATTLE_PROTOCOL\.md|ENGINEERING_TASK_DECOMPOSITION\.md|cangjie-repo\.toml|cjpm\.lock)$/.test(p)) throw new Error('Development/unexpected file in bundle: '+p);
}
const required=['cjpm.toml','README.md','LICENSE','NOTICE','docs/product/README.md','examples/minimal/cjpm.toml','examples/composition/cjpm.toml','benchmarks/rendering/cjpm.toml'];
for (const p of required) if (!paths.includes(p)) throw new Error('Incomplete product bundle: '+p);
for (const dir of ['src/','examples/minimal/src/','examples/composition/src/','benchmarks/rendering/src/']) if (!paths.some(p=>p.startsWith(dir)&&p.endsWith('.cj'))) throw new Error('Missing product source: '+dir);
for (const path of paths.filter(p=>p.endsWith('cjpm.toml'))) {
  const data=parse(execFileSync('tar',['-xOzf',archive,prefix+path],{encoding:'utf8'}));
  function dependencies(value) {
    if (!value || typeof value !== 'object') return [];
    return Object.entries(value).flatMap(([key, child]) =>
      ['dependencies','test-dependencies','script-dependencies'].includes(key)
        ? Object.entries(child || {})
        : dependencies(child));
  }
  for (const [name,dep] of dependencies(data)) {
    if (dep.git) throw new Error('Git dependency in product: '+name);
    if (path==='cjpm.toml' && dep.path) throw new Error('Root dependencies must be central');
    if (dep.path) {
      const base=path.split('/').slice(0,-1);
      for(const part of dep.path.split('/')) {
        if(part==='..') {if(!base.length) throw new Error('Dependency escapes product: '+path);base.pop();}
        else if(part && part!=='.') base.push(part);
      }
      if(dep.path.startsWith('/')||dep.path.includes('\\')) throw new Error('Invalid product path dependency');
      const target=[...base,'cjpm.toml'].join('/');
      if(!paths.includes(target)) throw new Error('Missing internal dependency manifest: '+target);
    }
  }
}
console.log('Actual product archive content boundary passed ('+paths.length+' files). Build/run from clean extraction is a separate required check.');

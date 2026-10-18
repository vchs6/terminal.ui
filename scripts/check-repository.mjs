import {readFileSync, existsSync, readdirSync} from 'node:fs';
import {resolve, dirname} from 'node:path';
import {parse} from 'smol-toml';
const root = resolve(import.meta.dirname, '..');
const read = p => readFileSync(resolve(root, p), 'utf8');
const manifest = parse(read('cjpm.toml'));
const p = manifest.package;
if (manifest.workspace || !p || p['src-dir'] !== 'src') throw new Error('Root must be the product package');
for (const path of ['/src','/examples','/benchmarks','/docs/product','/LICENSE','/NOTICE']) {
  if (!p.include.includes(path)) throw new Error('Missing distribution include: ' + path);
}
for (const path of ['/legacy','/openspec','/AGENTS.md','/BATTLE_PROTOCOL.md','/ENGINEERING_TASK_DECOMPOSITION.md','/scripts','/tests']) {
  if (!p.exclude.includes(path)) throw new Error('Missing development exclusion: ' + path);
}
const packages = JSON.parse(read('docs/development/central-packages.json')).packages;
for (const name of ['ansies','unicode']) {
  const dep = manifest.dependencies[name];
  if (dep.version !== packages[name].version || dep.path || dep.git) throw new Error('Must use pinned central dependency: ' + name);
}
if (!read('AGENTS.md').includes('ENGINEERING_TASK_DECOMPOSITION.md')) throw new Error('Missing governance link');
function walk(dir) {
  return readdirSync(resolve(root,dir),{withFileTypes:true}).flatMap(e => e.isDirectory() ? walk(dir+'/'+e.name) : [dir+'/'+e.name]);
}
const markdown = ['AGENTS.md','BATTLE_PROTOCOL.md','ENGINEERING_TASK_DECOMPOSITION.md','CONTRIBUTING.md','README.md',...walk('docs'),...walk('openspec')].filter(p=>p.endsWith('.md'));
for (const file of markdown) {
  const text = read(file);
  if ((text.match(/^```/gm)||[]).length % 2) throw new Error('Unclosed code fence: '+file);
  for (const match of text.matchAll(/\]\(([^)]+)\)/g)) {
    const path = match[1].split('#')[0];
    if (!path || /^(?:https?:|app:|mailto:|<)/.test(path) || path.includes('<')) continue;
    if (!existsSync(resolve(root,dirname(file),path))) throw new Error('Broken local link: '+file+' -> '+path);
  }
}
const tasks = read('docs/tasks.md');
if ((tasks.match(/^- \[ \] \d+\.\d+ TASK-/gm)||[]).length !== 24) throw new Error('Expected 24 planned product tasks');
for (let i=1;i<=24;i++) if (!read('docs/acceptance.md').includes('AC-'+String(i).padStart(3,'0'))) throw new Error('Missing acceptance reference');
console.log('Repository/configuration/links/task mapping checks passed; no product capability verified.');

import {readFileSync, existsSync, mkdirSync, lstatSync, symlinkSync, realpathSync} from 'node:fs';
import {resolve} from 'node:path';
import {execFileSync} from 'node:child_process';
const root = resolve(import.meta.dirname, '..');
const lock = JSON.parse(readFileSync(resolve(root, 'docs/development/tools.lock.json')));
const run = (cmd, args, cwd = root) => execFileSync(cmd, args, {cwd, stdio: 'inherit', env: {...process.env, OPENSPEC_TELEMETRY: '0'}});
const vendor = resolve(root, '.dev-tools/superpowers');
mkdirSync(resolve(root, '.dev-tools'), {recursive: true});
if (!existsSync(vendor)) run('git', ['clone', lock.superpowers.repository, vendor]);
const remote = execFileSync('git', ['remote', 'get-url', 'origin'], {cwd: vendor, encoding: 'utf8'}).trim();
if (remote !== lock.superpowers.repository) throw new Error('Superpowers origin differs from tools.lock.json');
if (execFileSync('git', ['status', '--porcelain'], {cwd: vendor, encoding: 'utf8'}).trim()) throw new Error('Refusing to overwrite modified Superpowers checkout');
run('git', ['fetch', '--depth', '1', 'origin', lock.superpowers.revision], vendor);
run('git', ['checkout', '--detach', lock.superpowers.revision], vendor);
const target = resolve(vendor, 'skills');
const link = resolve(root, '.agents/skills/superpowers');
mkdirSync(resolve(root, '.agents/skills'), {recursive: true});
try {
  const stat = lstatSync(link);
  if (!stat.isSymbolicLink() || realpathSync(link) !== realpathSync(target)) throw new Error('Refusing to replace existing skill entry');
} catch (error) {
  if (error.code !== 'ENOENT') throw error;
  symlinkSync(target, link, process.platform === 'win32' ? 'junction' : 'dir');
}
for (const name of ['using-superpowers', 'brainstorming', 'writing-plans', 'verification-before-completion']) {
  const text = readFileSync(resolve(link, name, 'SKILL.md'), 'utf8');
  if (!text.includes('name: ' + name)) throw new Error('Unreadable skill: ' + name);
}
const cli = resolve(root, 'node_modules/.bin/openspec');
run(cli, ['--version']);
if (existsSync(resolve(root, 'openspec/config.yaml'))) run(cli, ['update']);
else run(cli, ['init', '--tools', 'codex', '--language', 'zh-CN', '--no-animation']);
console.log('Development tools installed; skills are readable via .agents/skills. Reload agent discovery if needed, then explicitly invoke applicable skills. Installation is not evidence of their use.');

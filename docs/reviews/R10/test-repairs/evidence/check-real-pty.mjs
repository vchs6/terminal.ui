import assert from 'node:assert/strict';
import { spawn, execFile } from 'node:child_process';
import { mkdir, writeFile, readFile, stat } from 'node:fs/promises';
import { promisify } from 'node:util';
import { resolve, join } from 'node:path';
const exec = promisify(execFile);
const root = resolve('.'), dir = resolve('evidence/pty-fence');
await mkdir(dir);
const binary = '/workspace/work/auto-harness-repair-validation/tests/terminals/fixture/target/release/bin/main';
const wrapper = join(dir, 'wrapper.sh'), raw = join(dir, 'session.raw');
await writeFile(wrapper, `#!/bin/sh\nstty rows 8 cols 80\nstty -g > '${dir}/before'\ntty > '${dir}/tty'\n'${binary}'\nstatus=$?\nstty -g > '${dir}/after'\nexit "$status"\n`);
const env = { ...process.env, TERM: 'xterm', CJTUI_TERMINAL_EVIDENCE: dir }; delete env.COLORTERM;
const child = spawn('script', ['--quiet', '--return', '--flush', '--log-out', raw, '--command', `sh '${wrapper}'`], { stdio: ['pipe','pipe','pipe'], env });
let done = false, code, stderr = '';
child.stdout.resume(); child.stderr.on('data', bytes => stderr += bytes.toString());
child.on('exit', status => { done = true; code = status; });
const read = async path => { try { return await readFile(path,'utf8'); } catch { return ''; } };
async function until(predicate, name) {
  const deadline = Date.now() + 8000;
  while (Date.now() < deadline) { if (await predicate()) return; assert(!done, `early exit ${name}: ${code} ${stderr}`); await new Promise(resolve => setTimeout(resolve, 10)); }
  throw new Error('timeout ' + name);
}
let serial = 0, bold = false, columns = 80;
async function key(value) { serial++; child.stdin.write(value); await until(async () => (await read(join(dir, `event-${serial}.ack`))) === 'ack', `event ${serial}`); }
async function action(name, value, mode = 'updates') {
  const offset = (await stat(raw)).size;
  await key(value); await key('p'); bold = !bold;
  const { stdout } = await exec(process.execPath, ['tests/terminals/wait-fence.mjs', raw, String(offset), String(bold), String(columns), mode]);
  await writeFile(join(dir, `fence-${name}.json`), stdout);
  console.log('PASS transport ' + name + ': ' + stdout.trim());
}
try {
  await until(async () => !!(await read(join(dir, 'tty'))).trim(), 'tty');
  await until(async () => { try { return (await stat(raw)).size > 0; } catch { return false; } }, 'raw');
  await action('startup', 'n');
  await action('red', 'c'); await action('gray', 'c'); await action('restored', 'c');
  await action('attributes', 't');
  const tty = (await read(join(dir, 'tty'))).trim();
  await exec('stty', ['-F', tty, 'rows', '9', 'cols', '100']); columns = 100;
  await action('resized', 'n');
  await action('noop', 'n', 'quiet');
  const { stdout } = await exec(process.execPath, ['tests/terminals/verify-sgr.mjs', join(dir, `capabilities-${serial}.txt`), raw, 'xterm-default']);
  console.log(stdout.trim());
  await key('q'); await until(() => done, 'normal q exit'); assert.equal(code, 0);
  const before = (await read(join(dir, 'before'))).trim(), after = (await read(join(dir, 'after'))).trim();
  assert(before && after); assert.equal(after, before); console.log('PASS q and exact termios');
} finally { if (!done) child.kill('SIGKILL'); child.stdin.destroy(); }

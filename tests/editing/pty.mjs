#!/usr/bin/env node
import assert from 'node:assert/strict';
import { spawn, spawnSync } from 'node:child_process';

// Transport self-test only. The product PTY scenarios in recipes.md wait for
// the real Application.run binary and fixed keyboard/session prerequisites.
if (!process.argv.includes('--selftest')) {
  throw new Error('TASK118 PTY product adapter pending upstream; use --selftest');
}
assert.equal(spawnSync('script', ['--version']).status, 0);
assert.equal(spawnSync('stty', ['--version']).status, 0);
const payload = Buffer.from('\x1b[200~A\n\x03\x1b[201~', 'binary');
assert.equal(payload.length, 15);
const child = spawn('script', ['--quiet', '--return', '--flush', '--command',
  `sh -c 'stty raw -echo; printf READY; od -An -tx1 -N ${payload.length}'`, '/dev/null'],
  { stdio: ['pipe', 'pipe', 'pipe'], env: { ...process.env, TERM: 'xterm-256color' } });
let output = '', stderr = '';
let sent = false;
child.stdout.on('data', data => {
  output += data.toString('utf8');
  if (!sent && output.includes('READY')) { sent = true; child.stdin.write(payload); }
});
child.stderr.on('data', data => { stderr += data.toString('utf8'); });
const timer = setTimeout(() => child.kill('SIGKILL'), 10000);
const exit = await new Promise((resolve, reject) => {
  child.on('error', reject);
  child.on('close', (code, signal) => resolve({ code, signal }));
});
clearTimeout(timer);
assert.deepEqual(exit, { code: 0, signal: null }, stderr);
assert(sent, 'PTY READY handshake');
const expected = [...payload].map(value => value.toString(16).padStart(2, '0'));
const received = output.slice(output.indexOf('READY') + 5).match(/[0-9a-f]{2}/g) ?? [];
assert.deepEqual(received, expected, 'real PTY preserves exact paste bytes');
console.log('PASS PTY transport exact bracketed-paste bytes (no product run)');

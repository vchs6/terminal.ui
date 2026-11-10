#!/usr/bin/env node
// Terminal hosts may exit successfully after an unsuccessful child application.
import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
const [innerFile, outerFile, hostFile, expected] = process.argv.slice(2);
assert(innerFile && outerFile && hostFile && ['0', 'nonzero'].includes(expected),
  'usage: verify-exit.mjs INNER_RECORDER OUTER_RECORDER HOST_WAIT_STATUS 0|nonzero');
function status(value, label) {
  assert(/^(0|[1-9][0-9]{0,2})$/.test(value), label + ': invalid exit status');
  const code = Number(value); assert(code <= 255, label + ': exit status out of range');
  return code;
}
function recorder(path, label) {
  const fields = [...readFileSync(path, 'utf8').matchAll(/^exit_status=(.*)$/gm)];
  assert.equal(fields.length, 1, label + ': exactly one exit_status is required');
  return status(fields[0][1], label);
}
const applicationExitStatus = recorder(innerFile, 'inner recorder');
const recorderExitStatus = recorder(outerFile, 'outer recorder');
const hostWaitStatus = status(readFileSync(hostFile, 'utf8').trim(), 'terminal host');
assert.equal(recorderExitStatus, applicationExitStatus, 'inner and outer recorder exits must agree');
if (expected === '0') assert.equal(applicationExitStatus, 0, 'application must exit successfully');
else assert.notEqual(applicationExitStatus, 0, 'application exception must exit nonzero');
console.log(JSON.stringify({ applicationExitStatus, recorderExitStatus, hostWaitStatus, expected,
  authority: 'inner/outer recorder statuses; terminal host wait is independent evidence' }));

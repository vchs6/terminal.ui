// Historical diagnostic adapter: execute the exact unchanged run.sh exit branch.
import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import { spawnSync } from 'node:child_process';
const [inner, outer, host, expected] = process.argv.slice(2);
// The old caller waited only for exit_status fields, then based its decision on host wait.
assert(readFileSync(inner, 'utf8').includes('exit_status='));
assert(readFileSync(outer, 'utf8').includes('exit_status='));
const source = readFileSync('evidence/fixround2/historical-run.sh', 'utf8');
const branch = source.match(/if test "\$expected" = 0; then test "\$status" -eq 0; else test "\$status" -ne 0; fi/)[0];
const status = readFileSync(host, 'utf8').trim();
const result = spawnSync('/bin/sh', ['-c', 'expected=$1; status=$2; ' + branch, 'historical-oracle', expected, status]);
if (result.status !== 0) process.exit(1);
console.log(JSON.stringify({ applicationExitStatus: Number(status), hostWaitStatus: Number(status), historical: true }));

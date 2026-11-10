#!/usr/bin/env node
/* Verify actual-host evidence from the normal public CJ consumer, never infer
 * permission from a complete write. This tool reads only a private test display's
 * exported observations, never queries a user's clipboard or SSH private key. */
import assert from 'node:assert/strict';
import { readFile } from 'node:fs/promises';
import { createHash } from 'node:crypto';
import { resolve,dirname,join } from 'node:path';
import { fileURLToPath } from 'node:url';
import { parseResults,assertResult,common,hex,wrap,golden,assertWire } from './oracle.mjs';
export const hostText='CJTUI_HOST_中😀\nLOCAL';
export function verifyObservation(o, expected) {
  assert.equal(o.clipboardBeforeHex,expected.seedHex,'fixture starts from self-owned known clipboard');
  assert.equal(o.clipboardAfterHex,expected.clipboardApplied?Buffer.from(hostText).toString('hex'):expected.seedHex,'actual X11 selection bytes, including permission denial');
  for(const phase of ['initial','A','B','restored']) assert.equal(o.title[phase],expected.title[phase],`real title ${phase}`);
  assert.equal(o.iconBeforeSha256,o.iconAfterSha256,'OSC2/window stack does not modify image icon');
  assert(o.iconBeforeSha256?.match(/^[a-f0-9]{64}$/),'real icon observation hash');
  assert.equal(o.termiosBefore,o.termiosAfter,'actual native resources restored');
  assert.equal(o.exitCode,0,'normal direct public consumer exit');
}
export async function verifyHost(path) {
  const m=JSON.parse(await readFile(path,'utf8')),base=dirname(resolve(path));
  assert.equal(m.kind,'cjtui-session-public-host-v1'); assert.match(m.sourceSha,/^[a-f0-9]{40}$/); assert.match(m.binarySha256,/^[a-f0-9]{64}$/);
  assert(m.host.name && m.host.version && m.host.configFile && m.host.grid?.length===2,'actual host version/config/grid');
  assert(['Direct','TmuxPassthrough','ScreenPassthrough'].includes(m.route));
  assert(m.utcStart && m.utcEnd && new Date(m.utcEnd)>=new Date(m.utcStart),'real timestamps');
  const rows=parseResults(await readFile(join(base,m.results),'utf8'));common(rows);
  const observations=JSON.parse(await readFile(join(base,m.observations),'utf8'));
  verifyObservation(observations,m.expected);
  const copy=wrap(Buffer.from(`\x1b]52;c;${Buffer.from(hostText).toString('base64')}\x07`),m.route);
  const title=s=>wrap(Buffer.from(`\x1b]2;${s}\x07`),m.route);
  const save=wrap(hex(golden.saveHex),m.route),pop=wrap(hex(golden.popHex),m.route);
  const expected=[copy,...(m.declareStack?[save]:[]),title('CJTUI_HOST_TITLE_A'),title('CJTUI_HOST_TITLE_B'),...(m.declareStack?[pop]:[])];
  assertWire(await readFile(join(base,m.operationWire)),Buffer.concat(expected),'public API transaction wire only');
  assertResult(rows,'host.copy',{status:'SentUnconfirmed',bytes:copy.length,issue:'NoIssue'});
  assertResult(rows,'host.title.A',{status:'SentUnconfirmed',bytes:title('CJTUI_HOST_TITLE_A').length+(m.declareStack?save.length:0)});
  assertResult(rows,'host.title.B',{status:'SentUnconfirmed',bytes:title('CJTUI_HOST_TITLE_B').length});
  assertResult(rows,'host.restore',m.declareStack?{status:'SentUnconfirmed',bytes:pop.length,restore:'RestoreSentUnconfirmed'}:{status:'Unknown',bytes:0,issue:'RestoreUnavailable',restore:'Unavailable'});
  assert.equal(rows.get('cleanup.count'),m.declareStack?'0':'1');
  assert(m.screenshots.length>=4,'real initial/A/B/restore screenshot phases');
  for(const item of m.screenshots) {
    assert(item.captureCommand && item.utc && item.windowId,'capture metadata');
    const bytes=await readFile(join(base,item.file)); assert(bytes.subarray(0,8).equals(hex('89504e470d0a1a0a')),'actual PNG artifact');
    assert.equal(createHash('sha256').update(bytes).digest('hex'),item.sha256,'original screenshot hash');
  }
  assert((await readFile(join(base,m.fullStream))).length>copy.length,'full raw stream retained independently');
  assert((await readFile(join(base,m.nativeGrid))).length>0,'host-native grid retained');
  assert.equal(createHash('sha256').update(await readFile(join(base,m.binary))).digest('hex'),m.binarySha256,'actual tested executable');
  assert((await readFile(join(base,m.host.configFile))).length>0,'host config original retained');
  if(m.ssh) {
    assert(m.ssh.topology && m.ssh.remoteTty && m.ssh.remoteGrid?.length===2,'actual SSH transport/PTY identity');
    const log=await readFile(join(base,m.ssh.clientLog),'utf8');
    assert.match(log,/Authenticated to .*publickey/);assert.match(log,/kex: algorithm:/);assert.match(log,/Exit status 0/);
    assert(m.ssh.remoteCommand.includes('script'),'frozen -T plus real remote script PTY topology');
  }
  return {profile:m.profile,passed:true,sourceSha:m.sourceSha,clipboardApplied:m.expected.clipboardApplied};
}
if(process.argv[1]&&resolve(process.argv[1])===fileURLToPath(import.meta.url)) {
  try {console.log(JSON.stringify(await verifyHost(resolve(process.argv[2]))));}
  catch(error){console.error(error.stack);process.exitCode=1;}
}

import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
export const golden = JSON.parse(readFileSync(new URL('./fixtures/wire.json', import.meta.url)));
export const hex = text => Buffer.from(text, 'hex');
export function wrap(inner, route = 'Direct') {
  if (route === 'TmuxPassthrough') return Buffer.concat([hex('1b50746d75783b'), Buffer.from([...inner].flatMap(b => b === 27 ? [27, 27] : [b])), hex('1b5c')]);
  if (route === 'ScreenPassthrough') return Buffer.concat([hex('1b50'), inner, hex('1b5c')]);
  assert.equal(route, 'Direct'); return inner;
}
export function parseResults(text) {
  const rows = new Map();
  for (const line of text.trim().split('\n')) {
    if (!line) continue;
    const tab = line.indexOf('\t'); assert(tab > 0, `invalid row ${line}`);
    const key=line.slice(0,tab),value=line.slice(tab+1),previous=rows.get(key);
    assert(previous===undefined || previous.split('|').length===value.split('|').length,
      `${key}: duplicate key changes record shape`);
    rows.set(key,value);
  }
  return rows;
}
export function assertResult(rows, key, want) {
  assert(rows.has(key), `missing result ${key}`);
  const names = ['operation', 'status', 'bytes', 'issue', 'offset', 'restore'];
  const values = rows.get(key).split('|'); assert.equal(values.length, 6, key);
  const actual = Object.fromEntries(names.map((name, i) => [name, ['bytes', 'offset'].includes(name) ? Number(values[i]) : values[i]]));
  for (const [field, expected] of Object.entries(want)) assert.deepEqual(actual[field], expected, `${key}.${field}`);
  return actual;
}
export function assertWire(actual, expected, label) { assert.deepEqual(actual, expected, `${label}: exact actual wire bytes`); }
export function common(rows) {
  assert.equal(rows.get('completed'), 'yes', rows.get('fatal'));
  for (const [key, value] of rows) {
    if (!rows.has(`${key}.steps`)) continue;
    const parts = value.split('|'); assert.notEqual(parts[1], 'Applied', `${key}: no confirmation channel`);
    assert.notEqual(parts[5], 'RestoreConfirmed', `${key}: no restore confirmation`);
    const count = Number(rows.get(`${key}.steps`)); assert(count <= 2 && count >= 0, `${key}: steps bounded`);
    let emitted = 0;
    for (let i = 0; i < count; i++) { const step = rows.get(`${key}.step${i}`)?.split('|'); assert(step?.length === 4, `${key}: step shape`); emitted += Number(step[2]); }
    assert.equal(emitted, Number(parts[2]), `${key}: exact step byte sum`);
  }
  assert(![...rows.values()].some(v => v.includes('must not emit')), 'payload does not enter diagnostic records');
}
const fail = (issue, offset = -1) => ({ status: 'Failed', bytes: 0, issue, offset });
function unavailable(rows, key, op, issue) { assertResult(rows, key, { operation: op, status: 'Unsupported', bytes: 0, issue }); }
export function verifyHeadless(rows, wire) {
  common(rows); assertWire(wire, Buffer.alloc(0), 'headless no device');
  assertResult(rows, 'inactive', { ...fail('SessionInactive'), operation: 'CopyLocalText' });
  assert.equal(rows.get('inactive.session'), '0');
  for (const key of ['mount','getter','cleanup.context','worker','cross.session']) assertResult(rows, key, fail('InvalidContext'));
  for (const key of ['headless.copy','batch','clean.copy','post.1','post.2','post.3']) unavailable(rows, key, 'CopyLocalText', 'NoDevice');
  unavailable(rows, 'headless.restore', 'RestoreHostTitle', 'NoDevice');
  for (const key of ['mount','getter','cleanup.context','cross.session']) for (const op of ['copy','title','restore','icon']) assertResult(rows,`${key}.${op}`,fail('InvalidContext'));
  for(let i=0;i<4;i++) assertResult(rows,`worker.${i}`,fail('InvalidContext'));
  for(const op of ['copy','title','restore','icon']) assertResult(rows,`inactive.${op}`,fail('SessionInactive'));
  unavailable(rows, 'headless.title', 'SetHostTitle', 'NoDevice');
  unavailable(rows, 'headless.icon', 'SetHostImageIcon', 'NoImageAdapter');
  for (const name of ['clipboard','title','titleStack']) assert(rows.get(`headless.capabilities.${name}`).startsWith('Unsupported|KnownUnavailable|NoDevice|'), `headless ${name}`);
  assert.equal(rows.get('cleanup.count'), '0');
}
// S007: complete save owns a scope even when set fails before its first byte.
function verifySafeSetCleanup(rows,wire,native,route,allWire) {
  const save=wrap(hex(golden.saveHex),route),pop=wrap(hex(golden.popHex),route);
  const expected=Buffer.concat([save,pop]);
  assertWire(wire,expected,'saved scope after zero-byte set failure: one safe cleanup pop');
  assertResult(rows,'fault',{operation:'SetHostTitle',status:'Failed',bytes:save.length,issue:'WriteFailed',offset:-1});
  assert.equal(rows.get('fault.steps'),'2','complete save and failed set are distinct actual steps');
  assert.equal(rows.get('fault.step0'),`SaveHostTitle|SentUnconfirmed|${save.length}|NoIssue`);
  assert.equal(rows.get('fault.step1'),'SetHostTitle|Failed|0|WriteFailed');
  assertResult(rows,'cancelled.after',{operation:'CopyLocalText',status:'Failed',bytes:0,issue:'Cancelled',offset:-1});
  assert.equal(rows.get('cleanup.count'),'1','exactly one owned scope cleanup result');
  for(const key of ['cleanup.0','cleanup.again']) {
    assertResult(rows,key,{operation:'RestoreHostTitle',status:'SentUnconfirmed',bytes:pop.length,issue:'NoIssue',offset:-1,restore:'RestoreSentUnconfirmed'});
    assert.equal(rows.get(key+'.steps'),'1','cleanup/requery retains one actual restore step');
    assert.equal(rows.get(key+'.step0'),`RestoreHostTitle|SentUnconfirmed|${pop.length}|NoIssue`);
  }
  const primary=rows.get('run.primary')??rows.get('run.error');
  assert(primary&&primary.length,'first device error remains observable');
  for(const later of ['SESSION_LATE_CALLBACK_SENTINEL','SESSION_UI_CLEANUP_SENTINEL','terminal restore failed','ASSERT:','POST_AFTER_DEVICE_FAULT'])
    assert(!primary.includes(later),'later callback/cleanup errors cannot replace first device error');
  const events=native.trim().split('\n').map(line=>line.split('\t'));
  const close=events.findIndex(event=>event[0]==='close');
  assert(close>=0,'real native close recorded after optional cleanup');
  assert.equal(events[close][1],'0','actual native cleanup succeeds even when its return is later injected');
  const before=events.slice(0,close);
  assert.deepEqual(before.filter(e=>e[0]==='sequence').map(e=>Number(e[1])),[1,2,3],'save, failed set, cleanup pop before first close');
  assert.deepEqual(before.filter(e=>e[0]==='fault'),[['fault','2','0']],'selected second sequence fails at byte0');
  assert.deepEqual(before.filter(e=>e[0]==='sequence-result').map(e=>e.slice(1).map(Number)),[[0,save.length],[-1,0],[0,pop.length]]);
  const writes=before.filter(e=>e[0]==='write');
  assert.equal(writes.reduce((n,e)=>n+Number(e[2]),0),expected.length,'no extra screen/control bytes before close');
  for(const [sequence,count] of [[1,save.length],[2,0],[3,pop.length]])
    assert.equal(writes.filter(e=>Number(e[1])===sequence).reduce((n,e)=>n+Number(e[2]),0),count);
  assertWire(allWire.subarray(0,expected.length),expected,'all pre-close output is exactly save plus pop');
}
export function verifyLive(rows, wire, native, scenario, route, offset = 0, allWire = wire) {
  for(const forbidden of ['\x1b]0;','\x1b]1;','\x1b]52;c;?']) assert(!allWire.includes(Buffer.from(forbidden)),'no icon-name/both-title/clipboard-query protocol');
  common(rows); assert.equal(rows.get('disposed'), 'yes', 'UI dispose happens');
  assertResult(rows, 'after.inactive', fail('SessionInactive'));
  assert.equal(rows.get('after.id'), rows.get('live.id'), 'last immutable snapshot retained');
  for (const name of ['clipboard','title','titleStack']) {
    const declared = (name === 'clipboard' && ['declared','policy-reverse'].includes(scenario)) || (name === 'title' && ['declared','policy-independent'].includes(scenario)) || (name === 'titleStack' && /^(ledger|fault-(save|set|restore))/.test(scenario));
    const disabled = scenario === 'disabled' || (name === 'clipboard' && scenario === 'policy-independent') || (name === 'title' && scenario === 'policy-reverse');
    const want = disabled ? 'Unsupported|KnownUnavailable|Disabled|' : declared ? 'Supported|ExplicitConfiguration|NoIssue|' : 'Unknown|NoEvidence|NoIssue|';
    // reason for absence of evidence may be NoIssue; the contract gives NoEvidence basis,
    // and does not prescribe a separate Unknown-reason enum.
    const got = rows.get(`live.${name}`).split('|');
    const expected = want.split('|'); assert.equal(got[0], expected[0], `${name} support`); assert.equal(got[1], expected[1], `${name} basis`);
    assert.equal(got[3], route, `${name} selected route`);
    if (!disabled) assert.equal(got[4], {clipboard:'osc52-c', title:'osc2', titleStack:'xterm-title-stack-window'}[name]);
  }
  assert(rows.get('live.imageIcon').startsWith('Unsupported|KnownUnavailable|NoImageAdapter|'));
  const W = b => wrap(b, route), copyF = W(hex(golden.copy[1].directHex)), save = W(hex(golden.saveHex)), pop = W(hex(golden.popHex));
  const title = s => W(Buffer.concat([hex('1b5d323b'), Buffer.from(s), hex('07')]));
  const sent = (key, op, count, state) => assertResult(rows, key, {operation:op,status:'SentUnconfirmed',bytes:count,issue:'NoIssue',offset:-1,...(state?{restore:state}:{})});
  if (scenario === 'wire' || scenario === 'declared') {
    const parts = golden.copy.map((v, i) => { const bytes = W(hex(v.directHex)); sent(`copy.${i}`, 'CopyLocalText', bytes.length); return bytes; });
    parts.push(W(hex(golden.titleEmptyHex)), W(hex(golden.titleUnicodeHex)));
    sent('title.empty', 'SetHostTitle', parts.at(-2).length, 'Unavailable'); sent('title.unicode', 'SetHostTitle', parts.at(-1).length, 'Unavailable');
    unavailable(rows,'icon.empty','SetHostImageIcon','NoImageAdapter'); assertWire(wire,Buffer.concat(parts),scenario);
    assertResult(rows,'cleanup.0',{operation:'RestoreHostTitle',status:'Unknown',issue:'RestoreUnavailable',bytes:0,restore:'Unavailable'});
  } else if (scenario === 'bounds') {
    const parts = [];
    for (const n of [65535,65536]) {
      // Hand-derived repeating ASCII vectors: 65535 / 3 = 21845 "aaa" groups.
      const b64 = 'YWFh'.repeat(21845) + (n === 65536 ? 'YQ==' : '');
      const bytes = W(Buffer.from(`\x1b]52;c;${b64}\x07`)); parts.push(bytes); sent(`copy.${n}`,'CopyLocalText',bytes.length);
    }
    assertResult(rows,'copy.65537',fail('PayloadTooLarge',65536));
    for (const n of [1023,1024]) { const bytes=title('a'.repeat(n)); parts.push(bytes); sent(`title.${n}`,'SetHostTitle',bytes.length); }
    assertResult(rows,'title.1025',fail('PayloadTooLarge',1024));
    const astral = Buffer.concat([hex('1b5d35323b633b'),Buffer.from(Buffer.from('😀'.repeat(16384)).toString('base64')),hex('07')]);
    parts.push(W(astral), title('é'.repeat(512))); sent('copy.astral','CopyLocalText',W(astral).length); sent('title.multibyte','SetHostTitle',title('é'.repeat(512)).length);
    for (const n of [1048575,1048576]) unavailable(rows,`icon.${n}`,'SetHostImageIcon','NoImageAdapter');
    assertResult(rows,'icon.1048577',fail('PayloadTooLarge',1048576)); assertWire(wire,Buffer.concat(parts),'limits');
  } else if (scenario === 'invalid' || scenario === 'disabled') {
    for (let i=0;i<9;i++) for (const op of ['copy','title']) assertResult(rows,`invalid.${op}.${i}`,fail('InvalidUtf8',2));
    for (const n of [...Array.from({length:32},(_,i)=>i),...Array.from({length:33},(_,i)=>127+i)]) assertResult(rows,`control.${n}`,fail('ForbiddenControl',2));
    assertResult(rows,'precedence.invalid.large',fail('InvalidUtf8',65536));
    assertResult(rows,'precedence.title.both',fail('PayloadTooLarge',1024));
    for (const [key,at] of [['precedence.large',65536],['precedence.title.large',1024],['precedence.icon.large',1048576]]) assertResult(rows,key,fail('PayloadTooLarge',at));
    if (scenario === 'disabled') {
      unavailable(rows,'disabled.copy','CopyLocalText','Disabled'); unavailable(rows,'disabled.title','SetHostTitle','Disabled'); unavailable(rows,'disabled.restore','RestoreHostTitle','Disabled'); unavailable(rows,'disabled.icon','SetHostImageIcon','NoImageAdapter');
      assertWire(wire,Buffer.alloc(0),'all disabled zero bytes'); assert.equal(rows.get('cleanup.count'),'0');
    } else { sent('disabled.copy','CopyLocalText',W(Buffer.from('\x1b]52;c;dmFsaWQ=\x07')).length); sent('disabled.title','SetHostTitle',title('valid').length); assertWire(wire,Buffer.concat([W(Buffer.from('\x1b]52;c;dmFsaWQ=\x07')),title('valid')]),'validation is zero-write and session stays healthy'); }
  } else if (scenario.startsWith('ledger')) {
    let expected = Buffer.concat([save,title('A'),title('B'),pop]);
    sent('set.A','SetHostTitle',save.length+title('A').length,'SaveSentUnconfirmed'); sent('set.B','SetHostTitle',title('B').length,'SaveSentUnconfirmed');
    assert.equal(rows.get('set.A.steps'),'2'); assert.equal(rows.get('set.B.steps'),'1');
    if (scenario === 'ledger') {
      assertResult(rows,'restore.empty',{operation:'RestoreHostTitle',status:'Unknown',issue:'NoSavedTitle',bytes:0,restore:'NotNeeded'});
      sent('restore.1','RestoreHostTitle',pop.length,'RestoreSentUnconfirmed');
      for (const key of ['restore.2','restore.4']) assertResult(rows,key,{operation:'RestoreHostTitle',status:'Unknown',issue:'NoSavedTitle',bytes:0,restore:'NotNeeded'});
      sent('set.C','SetHostTitle',save.length+title('C').length); sent('restore.3','RestoreHostTitle',pop.length);
      expected=Buffer.concat([expected,save,title('C'),pop]); assert.equal(rows.get('cleanup.count'),'0'); assert.equal(rows.get('after.explicit.cleanup'),'0');
    } else { assert.equal(rows.get('cleanup.count'),'1'); sent('cleanup.0','RestoreHostTitle',pop.length,'RestoreSentUnconfirmed'); }
    assertWire(wire,expected,'title scope');
  } else if (scenario === 'policy-independent' || scenario === 'policy-reverse') {
    if (scenario === 'policy-independent') { unavailable(rows,'policy.copy','CopyLocalText','Disabled'); sent('policy.title','SetHostTitle',title('A').length,'Unavailable'); assertWire(wire,title('A'),'clipboard/title policies independent'); }
    else { sent('policy.copy','CopyLocalText',copyF.length); unavailable(rows,'policy.title','SetHostTitle','Disabled'); assertWire(wire,copyF,'title policy does not disable clipboard'); assert.equal(rows.get('cleanup.count'),'0'); }
  } else if (scenario === 'unknown-title') {
    sent('set.A','SetHostTitle',title('A').length,'Unavailable'); assertResult(rows,'restore.1',{status:'Unknown',issue:'RestoreUnavailable',bytes:0,restore:'Unavailable'}); assertWire(wire,title('A'),'unknown stack never push/pop');
  } else if (scenario === 'no-request' || scenario === 'cancel-before') {
    assertWire(wire,Buffer.alloc(0),scenario); assert.equal(rows.get('cleanup.count'),'0');
    if (scenario==='cancel-before') assertResult(rows,'cancelled',fail('Cancelled'));
  } else if (scenario === 'fifo') {
    const expected=Buffer.concat(['MQ==','Mg==','Mw=='].map(b64=>W(Buffer.from(`\x1b]52;c;${b64}\x07`)))); assertWire(wire,expected,'post FIFO');
    for(let i=1;i<=3;i++) sent(`fifo.${i}`,'CopyLocalText',copyF.length);
    const keys=[...rows.keys()]; assert(keys.indexOf('fifo.1')<keys.indexOf('fifo.2')&&keys.indexOf('fifo.2')<keys.indexOf('fifo.3'),'FIFO callbacks');
  } else if (scenario === 'fault-screen') {
    assert.equal(rows.get('run.failed'),'true','screen partial write escapes run');
    assert.equal(allWire.length,offset,'screen partial failure stops all subsequent output');
    assert.equal(rows.get('reopen.refused'),'true','screen failure sets same process-wide native unsafe latch');
    assert.match(rows.get('reopen.error'),/ParserUnsynchronized/);
    assert(!native.includes('poll-after-fault'),'no poll after screen device fault');
  } else if (scenario.startsWith('fault')) {
    const isSave=scenario.startsWith('fault-save'), isSet=scenario.startsWith('fault-set'), isRestore=scenario.startsWith('fault-restore');
    const frame=scenario==='fault-title-unicode'?W(hex(golden.titleUnicodeHex)):isSave?save:isSet?title('A'):isRestore?pop:copyF;
    const prefix=isSet?save:Buffer.alloc(0);
    if (['fault-eintr','fault-short'].includes(scenario)) { sent('fault','CopyLocalText',copyF.length); sent('healthy.after','CopyLocalText',copyF.length); assertWire(wire,Buffer.concat([copyF,copyF]),'retry and complete short writes'); assert.equal(rows.get('run.failed'),'false'); }
    else if(scenario==='fault-allocation') { assertResult(rows,'fault',fail('AllocationFailed')); sent('healthy.after','CopyLocalText',copyF.length); assertWire(wire,copyF,'pre-write allocation failure does not stop session'); assert.equal(rows.get('run.failed'),'false'); }
    else {
      const partial=offset>0;
      assertResult(rows,'fault',{status:'Failed',bytes:prefix.length+offset,issue:partial?'ParserUnsynchronized':'WriteFailed'});
      assertResult(rows,'cancelled.after',fail('Cancelled')); assert.equal(rows.get('run.failed'),'true','ignored Failed must escape run');
      assert(rows.get('run.error') && !rows.get('run.error').startsWith('SESSION_LATE_CALLBACK_SENTINEL'),'device error priority');
      const steps=Number(rows.get('fault.steps')); assert(steps>0,'write failure has actual step'); assert(rows.get(`fault.step${steps-1}`).endsWith('|WriteFailed'),'step issue remains WriteFailed');
      if(partial) { assertWire(allWire,Buffer.concat([prefix,frame.subarray(0,offset)]),'partial failure stops all control/frame output'); assert.equal(rows.get('reopen.refused'),'true'); assert.match(rows.get('reopen.error'),/ParserUnsynchronized/); }
      else { assert.equal(rows.get('reopen.refused'),'false','zero byte failure permits a later run'); assert(wire.subarray(0,prefix.length).equals(prefix));
        if(isSet) verifySafeSetCleanup(rows,wire,native,route,allWire); }
      assert(!native.includes('poll-after-fault'),'no next poll after failed callback');
      const closes=native.trim().split('\n').filter(l=>l.startsWith('close\t')); assert(closes.length>=1,'native close always occurs');
      if (partial && scenario !== 'fault-title-unicode') assert.equal(rows.get('cleanup.count'),isSet||isRestore?'1':'0','bounded title diagnostic');
    }
  } else assert.fail(`unknown scenario ${scenario}`);
  if (rows.has('cleanup.again')) assert.equal(rows.get('cleanup.again'),rows.get('cleanup.0'),'outer and nested cleanup result copies');
}

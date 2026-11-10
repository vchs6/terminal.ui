import { wrap, golden, hex } from './oracle.mjs';
export const sessionCases=[{scenario:'headless',route:'Direct'}];
for(const route of ['Direct','TmuxPassthrough','ScreenPassthrough']) {
  for(const scenario of ['wire','bounds','invalid','disabled','ledger','ledger-close','ledger-error','ledger-cancel','unknown-title','no-request','cancel-before','fifo','declared','policy-independent','policy-reverse','fault-eintr','fault-short','fault-allocation']) sessionCases.push({scenario,route});
  for(const scenario of ['fault-copy','fault-save','fault-set','fault-restore','fault-title-unicode']) {
    const frame=scenario==='fault-title-unicode'?hex(golden.titleUnicodeHex):scenario==='fault-save'?hex(golden.saveHex):scenario==='fault-set'?Buffer.from('\x1b]2;A\x07'):scenario==='fault-restore'?hex(golden.popHex):hex(golden.copy[1].directHex);
    // Every byte boundary, including OSC/DCS prefix, UTF8-independent ASCII body,
    // padding, BEL and wrapper ST. Never test an already-complete frame as partial.
    for(let offset=0;offset<wrap(frame,route).length;offset++) sessionCases.push({scenario,route,offset});
  }
  for(const scenario of ['fault-eagain','fault-zero']) sessionCases.push({scenario,route,offset:0});
}
for(const offset of [1,2,5]) sessionCases.push({scenario:'fault-screen',route:'Direct',offset});
sessionCases.push({scenario:'fault-copy',route:'Direct',offset:1,uiFail:true,closeFail:true,callbackFail:true});
sessionCases.push({scenario:'ledger-error',route:'Direct',uiFail:true,closeFail:true});
// Safe owned title scope must still pop despite later callback/UI cleanup errors.
sessionCases.push({scenario:'fault-set',route:'Direct',offset:0,uiFail:true,callbackFail:true});

// Only make existing case functions callable; no assertion/fixture rewriting.
const suffixes=new Map([
 ['/tests/composition/application/pty.mjs','export {startup, interactions, minimal};'],
 ['/tests/theme_showcase/pty.mjs','export {startup,fullCycle,retainedState,fileReload,absentFile};'],
 ['/tests/theme_showcase/modal-keys.mjs','export {previewSwitch,popupSwitch};']]);
export async function load(url,context,nextLoad){
 const result=await nextLoad(url,context);
 for(const [suffix,extra] of suffixes)if(new URL(url).pathname.endsWith(suffix)){
  return {...result,source:String(result.source)+'\n'+extra+'\n'};
 }
 return result;
}

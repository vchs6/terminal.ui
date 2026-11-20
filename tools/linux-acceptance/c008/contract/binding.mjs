// Frozen independent expected-value adapter. Never imports a product renderer.
import assert from 'node:assert/strict';
import {readFileSync,writeFileSync} from 'node:fs';
import {join,resolve} from 'node:path';
import {createHash} from 'node:crypto';
const load=name=>JSON.parse(readFileSync(new URL(name,import.meta.url),'utf8'));
const tables=load('color-projections.json').modes, vtFrames=load('literal-80x25.json').frames;
let profile,theme='Classic',app='composition';
const outcomes=new Map();
export function configure(value){
 assert(value&&['vt','xterm','vte','tmux','screen','ssh'].includes(value.hostKind),'INSUFFICIENT_EVIDENCE hostKind');
 assert(tables[value.colorMode],'ORACLE_GAP color mode');
 assert.equal(typeof value.ncv,'number');assert(Number.isInteger(value.ncv)&&value.ncv>=-1,'ncv');
 assert(Array.isArray(value.supportedAttributes)&&value.supportedAttributes.every(n=>[1,2,3,4,7,9].includes(n)),'attribute facts');
 for(const k of ['sourceCommit','factsPath','factsSha256','source','reason'])assert.equal(typeof value[k],'string','INSUFFICIENT_EVIDENCE '+k);
 assert.equal(value.sourceCommit,'d7e9d1445f98021a798d223de97b97b45239de93');
 assert(/^[a-f0-9]{64}$/.test(value.factsSha256),'facts hash');
 assert.equal(typeof value.nativeVt,'boolean','actual stdout glyph identity fact');
 if(value.hostKind!=='vt')assert.equal(value.nativeVt,false,'FAILED_TRANSPORT intended PTY has concrete VT stdout');
 if(value.hostKind==='vt'){
  assert.equal(value.nativeVt,true,'actual stdout native VT');assert.equal(typeof value.mapKnown,'boolean');
  if(value.mapKnown){assert(Array.isArray(value.mappedCodePoints)&&value.mappedCodePoints.every(n=>Number.isInteger(n)&&n>=0&&n<=65535),'complete map list required');value={...value,map:new Set(value.mappedCodePoints)};
   assert(Array.from({length:95},(_,i)=>i+32).filter(n=>n!==63).every(n=>value.map.has(n)),'ORACLE_GAP mapped VT missing printable ASCII required by existing semantic predicates');
  }
 }
 profile=Object.freeze(value);return profile;
}
export function resolveFacts(facts){
 const valid=typeof facts.term==='string'&&facts.term.length>0&&facts.term.length<=128&&/^[A-Za-z0-9_+.\-]+$/.test(facts.term)&&facts.term!=='dumb';
 let mode='Monochrome',source='unknown',reason=!facts.term?'term-unset':facts.term==='dumb'?'term-dumb':!valid?'term-invalid':facts.failureReason??'';
 const supported=[];const ct=valid&&/^(truecolor|24bit)$/i.test(facts.colorterm??'');
 if(valid&&facts.terminfoKnown===true){
  assert(Number.isInteger(facts.colors),'INSUFFICIENT_EVIDENCE terminfo colors');
  mode=facts.colors<8?'Monochrome':facts.colors<16?'Basic8':facts.colors<256?'Basic16':'Indexed256';
  if(facts.colors>=16777216||facts.RGB===true||facts.Tc===true)mode='TrueColor';source='terminfo';reason='';
  for(const [key,n]of [['bold',1],['dim',2],['sitm',3],['smul',4],['rev',7],['smxx',9]]){
   const v=facts.attributeStrings?.[key];assert(v===null||typeof v==='string','INSUFFICIENT_EVIDENCE attribute string '+key);
   if(typeof v==='string'&&v.replace(/\$<\d+(?:\.\d+)?[*/]*>/g,'')===`\x1b[${n}m`)supported.push(n);
  }
 }else if(valid)assert(typeof facts.failureReason==='string'&&facts.failureReason,'INSUFFICIENT_EVIDENCE terminfo failure');
 if(ct){mode='TrueColor';source=source==='terminfo'?'terminfo+COLORTERM':'COLORTERM'}
 assert(Number.isInteger(facts.ncv)&&facts.ncv>=-1,'INSUFFICIENT_EVIDENCE ncv');
 return {colorMode:mode,source,reason,supportedAttributes:supported,ncv:valid&&facts.terminfoKnown===true?facts.ncv:-1,nativeVt:facts.nativeVt,mapKnown:facts.mapKnown,mappedCodePoints:facts.mappedCodePoints};
}
export function config(){if(!profile){
 assert(process.env.C008_EXPECTED_PROFILE,'INSUFFICIENT_EVIDENCE C008_EXPECTED_PROFILE');
 const envelope=JSON.parse(readFileSync(process.env.C008_EXPECTED_PROFILE,'utf8'));assert(envelope.factsPath&&envelope.factsSha256,'INSUFFICIENT_EVIDENCE facts reference');
 const bytes=readFileSync(resolve(envelope.factsPath));assert.equal(createHash('sha256').update(bytes).digest('hex'),envelope.factsSha256,'profile facts hash');
 const facts=JSON.parse(bytes);configure({...envelope,...resolveFacts(facts)});
 }return profile} 
export function admitCase(application,name){
 const p=config();
 if(application==='composition'&&name==='interactions'&&p.hostKind==='vt'&&p.mapKnown&&!p.map.has(63)){
  const detail='ORACLE_GAP F001 composition/interactions: mapped VT lacks U+003F; Confirm? projects to popup Confirm plus padding, so nested open/negative-close barriers are ambiguous. Rejected before session construction/input.';
  status('ORACLE_GAP','composition/interactions/F001',detail);
  throw Object.assign(new Error(detail),{code:'ORACLE_GAP',finding:'F001',case:'composition/interactions'});
 }
 return true;
}
export function isVT(){return config().hostKind==='vt'}
export function status(code,key,detail){outcomes.set(code+':'+key,{status:code,assertion:key,detail})}
export function records(){return [...outcomes.values()]}
export function dimensions(w,h){if(!isVT())return [w,h];assert(w===80&&(h===24||h===25),'ORACLE_GAP fixed VT dimensions');return [80,25]}
export function y(index){return isVT()&&(index===22||index===23)?index+1:index}
export function color(raw,channel='fg'){
 if(raw==='default')return raw;
 const token=tables[config().colorMode][raw]?.[channel];assert(token,'ORACLE_GAP color '+raw+'/'+channel);return token;
}
export function glyph(token){
 if(!isVT())return token;
 const p=config(),fallback=!p.mapKnown||p.map.has(63)?'?':' ';
 if(token==='e\u0301')return fallback;
 if(token==='中'||token==='文'||token==='👩‍💻')return fallback.repeat(2);
 assert([...token].length===1,'ORACLE_GAP VT glyph '+token);
 const cp=token.codePointAt(0);
 if(cp>=32&&cp<=126){if(!p.mapKnown||p.map.has(cp))return token;return fallback}
 const known='•░╭╮╰╯┌┐└┘─│';assert(known.includes(token),'ORACLE_GAP VT token '+token);
 if(p.mapKnown&&p.map.has(cp))return token;
 const decoration='╭╮╰╯┌┐└┘'.includes(token)?'+':token==='─'?'-':token==='│'?'|':null;
 return decoration&&(!p.mapKnown||p.map.has(decoration.codePointAt(0)))?decoration:fallback;
}
export function text(value){
 if(!isVT())return value;
 let out='';for(let i=0;i<value.length;){let token;
  if(value.startsWith('e\u0301',i))token='e\u0301';else if(value.startsWith('👩‍💻',i))token='👩‍💻';else token=String.fromCodePoint(value.codePointAt(i));
  out+=token==='\n'||token==='\r'?token:glyph(token);i+=token.length;
 }return out;
}
export function frames(values,application,kind){
 const source=isVT()?[
  ...values.filter(v=>v.width!==80),
  ...vtFrames.filter(v=>v.application===application&&(kind==='startup'?application==='composition'?['tasks','logs'].includes(v.scene):['startup','pending'].includes(v.state):kind==='modal'?v.scene==='modal'||v.state==='modal':v.state?.startsWith('retained-')))
 ]:values;
 return source.map(v=>({...v,rows:v.rows.map(text)}));
}
export function palette(values){return Object.fromEntries(Object.entries(values).map(([n,v])=>[n,{fg:color(v.fg),bg:color(v.bg,'bg'),accent:color(v.accent)}]))}
const canonical={Classic:{fg:'default',bg:'default',accent:'named:36'},Dark:{fg:'rgb:232,237,242',bg:'rgb:16,24,32',accent:'rgb:102,204,255'},Light:{fg:'rgb:24,32,40',bg:'rgb:255,255,255',accent:'rgb:0,90,156'},'High contrast':{fg:'named:97',bg:'named:40',accent:'named:93'}};
export function setTheme(name){assert(canonical[name]);theme=name}
export function setApplication(name){app=name;theme='Classic';outcomes.clear()}
function expectedStyle(role,name=theme){const p=canonical[name];assert(p,'ORACLE_GAP theme');
 const fg=role==='disabled'?'named:90':role==='focused'||role.startsWith('accent')?p.accent:p.fg;
 return {fg:color(fg),bg:color(p.bg,'bg')};
}
export function attributeExpected(n,role,name=theme){
 const p=config(),s=expectedStyle(role,name);if(!p.supportedAttributes.includes(n))return false;
 if(s.fg==='default'&&s.bg==='default')return true;
 if(p.ncv<=0)return true;
 if(BigInt(p.ncv)&~BigInt(2|4|16|32))return false;
 return !(BigInt(p.ncv)&BigInt({4:2,7:4,2:16,1:32}[n]??0));
}
// Returns a predicate, never substitutes synthetic observed attributes.
export function attribute(cell,n,role,name=theme,present=true){
 const s=expectedStyle(role,name),want=present&&attributeExpected(n,role,name);
 if(present&&!want)status('UNOBSERVABLE_ATTRIBUTE',`${app}/${name}/${role}/SGR${n}`,'Expected absence under actual profile; this does not prove visual focus/disabled indication.');
 const declared={title:[1],disabled:[2],focused:[4],selected:[7],accent:[1],'accent-span':[1,4]}[role];
 assert(declared,'ORACLE_GAP style role '+role);
 const expected=declared.filter(a=>attributeExpected(a,role,name)).sort((a,b)=>a-b);
 const observed=cell?.attributes.slice().sort((a,b)=>a-b);
 return !!cell&&cell.fg===s.fg&&cell.bg===s.bg&&cell.attributes.includes(n)===want&&JSON.stringify(observed)===JSON.stringify(expected);
}
export function compositionTheme(rows,name){
 const p=canonical[name];assert(p);setTheme(name);
 const footer=rows.at(-1),root=rows.at(-2).cells.at(-1),end=footer.cells.at(-1);
 return footer.text.includes('| '+name)&&root?.bg===color(p.bg,'bg')&&end?.bg===color(p.bg,'bg')&&footer.cells[0]?.fg===color(p.fg);
}
export function fullCycleResizeSkipped(){status('NOT_APPLICABLE_FIXED_HOST','VT smaller physical resize','Fixed actual80x25 checked; no smaller physical viewport claim.')}
export async function liveResize(s){if(isVT()){fullCycleResizeSkipped();return s.view.rows()}await s.resize(40,12);await s.resize(16,6);return s.resize(80,24)}
export function scrolledFirst(){return isVT()?'011 INFO record 11':'012 INFO record 12'}
export function attach(Session){
 const save=Session.prototype.save,stop=Session.prototype.stop,has=Session.prototype.has;
 Session.prototype.has=function(value,label){return has.call(this,text(value),label)};
 Session.prototype.save=async function(){try{return await save.call(this)}finally{
  writeFileSync(join(this.dir,'oracle-status.json'),JSON.stringify({preparation:'ACTUAL_ATTEMPT',finalAcceptance:false,profile:config(),subassertions:records(),remainingEvidence:['original screenshots','complete profile facts','accepted reused failure-offset evidence']},(k,v)=>v instanceof Set?undefined:v,2)+'\n');
 }};
 Session.prototype.stop=async function(...args){
  await stop.apply(this,args);
  const path=join(this.dir,'lifecycle-evidence.json');let v;
  try{v=JSON.parse(readFileSync(path,'utf8'))}catch{assert.fail('INSUFFICIENT_EVIDENCE '+path)}
  assert(v.beforeTermios&&typeof v.beforeTermios==='string','before termios');assert.equal(v.afterTermios,v.beforeTermios,'exact actual app termios restoration');
  assert.equal(v.directExit,0);assert.equal(v.directSignal,null,'actual app no signal');
  assert(['KnownVisible','KnownHidden','Unknown'].includes(v.initialCursor),'genuine cursor fact or timeout');
  if(v.initialCursor==='Unknown')assert.equal(v.cursorRestore,'PreservedUnknown');else assert.equal(v.cursorRestore,v.initialCursor);
  assert.equal(v.syntheticReplyInjected,false,'no synthetic DECRQM reply');
  assert(Array.isArray(v.evidence)&&['termios','exit','cursor','input-wire'].every(kind=>v.evidence.some(x=>x.kind===kind)),'INSUFFICIENT_EVIDENCE lifecycle original links');
  for(const item of v.evidence){assert(item.path&&/^[a-f0-9]{64}$/.test(item.sha256),'lifecycle evidence reference');assert.equal(createHash('sha256').update(readFileSync(resolve(this.dir,item.path))).digest('hex'),item.sha256,'lifecycle original hash '+item.kind)}

 };
}

export async function navigationKey(s,bytes,predicate,label){
 const p=canonical[theme],visible=attributeExpected(4,'focused')||color(p.accent)!==color(p.fg);
 if(visible)return s.key(bytes,predicate,label);
 status('UNOBSERVABLE_ATTRIBUTE',label,'No surviving focus decoration; ordered Down/Enter input and full post-action grid retained, focused Confirm cannot be independently seen.');
 s.send(bytes,label);return s.wait(predicate,label+' (focus indication unavailable)');
}
export function acknowledgeColor(cell){
 if(color('named:33')===color('named:32'))status('UNOBSERVABLE_COLOR','Done acknowledgement color','Yellow and green project identically; exact projected foreground/text equality checked, distinct visible change unobservable.');
 return cell.fg===color('named:32');
}

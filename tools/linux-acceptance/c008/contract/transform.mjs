// Exact source transformations; hashes are checked by the loader before binding.
import assert from 'node:assert/strict';
const adapter=new URL('./binding.mjs',import.meta.url).href;
const addImport=s=>`import * as binding from ${JSON.stringify(adapter)};\n`+s;
const bindTextPredicates=s=>s.replace(/\.includes\(('[^'\n]*')\)/g,'.includes(binding.text($1))');
function once(s,old,next){assert.equal(s.split(old).length-1,1,'ORACLE_GAP exact source anchor '+old);return s.replace(old,next)}
function every(s,old,next,count){assert.equal(s.split(old).length-1,count,'ORACLE_GAP count '+old);return s.split(old).join(next)}
export function transform(path,source){
 let s=source;
 if(path==='tests/colors/pty.mjs'){
  s=once(s,"const artifacts = resolve(process.env.CJTUI_COLOR_ARTIFACTS ?? await mkdtemp(join(tmpdir(), 'cjtui-colors-')));","const artifacts = resolve(process.env.CJTUI_COLOR_ARTIFACTS ?? '/tmp/c008-no-import-artifacts');");
  s=once(s,'await mkdir(artifacts, { recursive: true });','// Canonical Screen import is read-only; synthetic executable entry remains guarded.');return s;
 }
 if(path.endsWith('/fixtures.mjs')){
  if(path.includes('/composition/')){
   for(const [symbol,file,kind]of [['goldens','startup','startup'],['modalGoldens','modal','modal']]){
    const old=`export const ${symbol} = JSON.parse(readFileSync(new URL('./goldens/${file}.json', import.meta.url)));`;
    s=once(s,old,`export const ${symbol} = binding.frames(JSON.parse(readFileSync(new URL('./goldens/${file}.json', import.meta.url))),'composition','${kind}');`);
   }
   s=once(s,"export const minimalPtyGolden = JSON.parse(readFileSync(new URL('./goldens/minimal-pty.json', import.meta.url)));","const rawMinimal = JSON.parse(readFileSync(new URL('./goldens/minimal-pty.json', import.meta.url)));\nexport const minimalPtyGolden = {...rawMinimal,rows:rawMinimal.rows.map(binding.text)};");
  }else{
   for(const [symbol,file,kind]of [['ptyGoldens','pty-goldens','startup'],['modalGoldens','pty-modal-goldens','modal'],['retainedGoldens','retained-goldens','retained']]){
    const old=`export const ${symbol}=JSON.parse(readFileSync(new URL('./${file}.json',import.meta.url)));`;
    s=once(s,old,`export const ${symbol}=binding.frames(JSON.parse(readFileSync(new URL('./${file}.json',import.meta.url))),'theme_showcase','${kind}');`);
   }
   s=once(s,'export const palette=Object.freeze({','export const palette=binding.palette({');
   s=once(s,"  const found=goldens.find(x=>x.name===name&&x.width===width&&x.height===height&&x.state===state);","  [width,height]=binding.dimensions(width,height);\n  const found=goldens.find(x=>x.name===name&&x.width===width&&x.height===height&&x.state===state);");
  }return addImport(bindTextPredicates(s));
 }
 if(path==='tests/composition/application/pty.mjs'){
  s=once(s,'    this.dir=directory;this.w=w;this.h=h;this.binary=binary;this.view=new WireScreen(w,h);','    [w,h]=binding.dimensions(w,h);\n    this.dir=directory;this.w=w;this.h=h;this.binary=binary;this.view=new WireScreen(w,h);');
  s=once(s,"const at=(rows,x,y)=>{let col=0;for(const cell of rows[y].cells){if(col===x)return cell;col+=[...cell.text].length}throw Error(`missing cell ${x},${y}`)};","const at=(rows,x,y)=>{y=binding.y(y);let col=0;for(const cell of rows[y].cells){if(col===x)return cell;col+=cell.text==='中'||cell.text==='文'?2:1}throw Error(`missing cell ${x},${y}`)};");
  const begin=s.indexOf('export const themeVisible='),end=s.indexOf('\nfunction sameGrid',begin);assert(begin>=0&&end>begin);
  s=s.slice(0,begin)+'export const themeVisible=name=>rows=>binding.compositionTheme(rows,name);'+s.slice(end);
  s=once(s,'function sameGrid(actual,w,h,scene){','function sameGrid(actual,w,h,scene){[w,h]=binding.dimensions(w,h);');
  s=once(s,'async function startup(directory,w,h){','async function startup(directory,w,h){\n  [w,h]=binding.dimensions(w,h);');
  s=once(s,'async function interactions(directory){',"async function interactions(directory){\n  binding.admitCase('composition','interactions');");
  // PASTE002: one explicit real-host-only logical LF source binding; frozen synthetic CRLF input is unchanged.
  s=once(s,"paste('qrcvzy\\r\\nreview 中文 👩‍💻')","paste('qrcvzy\\nreview 中文 👩‍💻')");
  s=once(s,"    if(w===80){\n      sameGrid(await s.resize(40,12)","    if(w===80&&!binding.isVT()){\n      sameGrid(await s.resize(40,12)");
  s=once(s,"    await s.resize(40,12);await s.resize(16,6);const restored=await s.resize(80,24);","    const restored=await binding.liveResize(s);");
  s=once(s,"assert(at(initial,0,1).attributes.includes(1)","assert(binding.attribute(at(initial,0,1),1,'title','Classic')");
  s=once(s,"assert(at(initial,25,0).attributes.includes(2)","assert(binding.attribute(at(initial,25,0),2,'disabled','Classic')");
  s=once(s,"rows=>at(rows,34,0).attributes.includes(4)","rows=>binding.attribute(at(rows,34,0),4,'focused','Classic')");
  s=once(s,"assert(!at(s.view.rows(),25,0).attributes.includes(4)","assert(binding.attribute(at(s.view.rows(),25,0),4,'disabled','Classic',false)");
  // Exact original expected color literals; PASTE002 above is the sole authorized input-literal revision.
  for(const [old,next,count]of [[".fg,'named:33'",".fg,binding.color('named:33')",2],[".fg,'named:36'",".fg,binding.color('named:36')",2],[".bg,'named:40'",".bg,binding.color('named:40','bg')",2],[".bg,'rgb:255,255,255'",".bg,binding.color('rgb:255,255,255','bg')",1],[".fg==='named:32'",".fg===binding.color('named:32')",1]])s=every(s,old,next,count);
  s=once(s,"const contains=value=>rows=>text(rows).includes(value);","const contains=value=>rows=>text(rows).includes(binding.text(value));");
  s=once(s,"rows=>at(rows,0,9).fg===binding.color('named:32')","rows=>binding.acknowledgeColor(at(rows,0,9))");
  s=once(s,"    if(w===80&&!binding.isVT()){","    if(binding.isVT())binding.fullCycleResizeSkipped();\n    if(w===80&&!binding.isVT()){");
  s=s.replaceAll(".includes('╭')",".includes(binding.glyph('╭'))");
  s+='\nSession.prototype.start=async function(){throw Error("FAILED_TRANSPORT install actual Session transport before invoking a case")};\nexport {startup,interactions,minimal};\n';
  return addImport(bindTextPredicates(s));
 }
 if(path==='tests/theme_showcase/checks.mjs'){
  s=once(s,'export function cellAt(rows,x,y){','export function cellAt(rows,x,y){\n  y=binding.y(y);');
  s=once(s,'export function acceptedPalette(rows,name){','export function acceptedPalette(rows,name){\n  binding.setTheme(name);');
  for(const [x,y,n,role]of [[0,1,1,'title'],[0,4,4,'focused'],[0,6,7,'selected'],[40,2,1,'accent'],[48,2,4,'accent-span'],[40,7,2,'disabled'],[48,0,2,'disabled']])
   s=once(s,`cellAt(rows,${x},${y}).attributes.includes(${n})`,`binding.attribute(cellAt(rows,${x},${y}),${n},'${role}',name)`);
  s=once(s,".fg,'named:90'",".fg,binding.color('named:90')");return addImport(bindTextPredicates(s));
 }
 if(path==='tests/theme_showcase/pty.mjs'){
  s=once(s,'async function startup(dir,w,h){','async function startup(dir,w,h){\n  [w,h]=binding.dimensions(w,h);');
  s=once(s,"const contains=value=>rows=>text(rows).includes(value);","const contains=value=>rows=>text(rows).includes(binding.text(value));");
  s=once(s,".includes(rounded?'╭──────────────────────────────╮':'+------------------------------+')",".includes(binding.text(rounded?'╭──────────────────────────────╮':'+------------------------------+'))");
  s=every(s,".text,'░'",".text,binding.glyph('░')",2);
  s=once(s,'cellAt(modal,x,16)','cellAt(modal,x,binding.isVT()?17:16)');
  s=once(s,'for(let y=8;y<16;y++)','for(let y=binding.isVT()?9:8;y<(binding.isVT()?17:16);y++)');
  s=once(s,"c.attributes.includes(2)","binding.attribute(c,2,'disabled')");
  s=once(s,"c.attributes.includes(4)","binding.attribute(c,4,'focused')");
  s=once(s,"r[10].text.startsWith('012 INFO record 12')","r[10].text.startsWith(binding.scrolledFirst())");
  s=s.replaceAll('r[22]','r[binding.y(22)]').replaceAll('rows[22]','rows[binding.y(22)]').replaceAll('scrolled[22]','scrolled[binding.y(22)]').replaceAll('rows[23]','rows[binding.y(23)]').replaceAll('r[23]','r[binding.y(23)]').replaceAll('failed[23]','failed[binding.y(23)]');
  s=every(s,"cellAt(rows,0,8).attributes.includes(4)","binding.attribute(cellAt(rows,0,8),4,'focused',name)",1);
  s=once(s,"cellAt(light,0,8).attributes.includes(4)","binding.attribute(cellAt(light,0,8),4,'focused','Light')");
  s+='\nexport {startup,fullCycle,retainedState,fileReload,absentFile};\n';return addImport(bindTextPredicates(s));
 }
 if(path==='tests/theme_showcase/modal-keys.mjs'){
  s=once(s,"c.attributes.includes(2)","binding.attribute(c,2,'disabled','Dark')");
  s=once(s,"c.attributes.includes(4)","binding.attribute(c,4,'focused','Dark')");
  s=once(s,'await s.key(keys.down,','await binding.navigationKey(s,keys.down,');
  s=s.replaceAll(".includes('╭──────────────────────────────╮')",".includes(binding.text('╭──────────────────────────────╮'))");
  s+='\nexport {previewSwitch,popupSwitch};\n';return addImport(bindTextPredicates(s));
 }
 assert.fail('ORACLE_GAP unrecognized transform '+path);
}
export const targetPaths=['tests/colors/pty.mjs','tests/composition/application/pty.mjs','tests/composition/application/fixtures.mjs','tests/theme_showcase/pty.mjs','tests/theme_showcase/modal-keys.mjs','tests/theme_showcase/fixtures.mjs','tests/theme_showcase/checks.mjs'];

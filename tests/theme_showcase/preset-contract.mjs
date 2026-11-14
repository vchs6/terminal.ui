// Independent source/arithmetic checks for the fixed preset projection.
// These validate hand-authored literals; they never read application output.
import assert from 'node:assert/strict';
import {readFileSync} from 'node:fs';
import {frame,smokeGoldens,ptyGoldens} from './fixtures.mjs';
import {width} from './checks.mjs';
const modal=JSON.parse(readFileSync(new URL('./modal-goldens.json',import.meta.url)));
const ptyModal=JSON.parse(readFileSync(new URL('./pty-modal-goldens.json',import.meta.url)));
const specs=[
  {name:'Classic',file:'classic',border:'ascii',shadow:false},
  {name:'Dark',file:'dark',border:'rounded',shadow:true},
  {name:'Light',file:'light',border:'rounded',shadow:true},
  {name:'High contrast',file:'high-contrast',border:'ascii',shadow:false}
];
const contents=['Preview','Theme sample','é 中 👩‍💻','Select action','','','Actions'];
const ptyContents=contents.map(s=>s.replace('👩‍💻','??'));
let failures=0;
function check(label,body){
  try{body();console.log(`PASS ${label}`)}
  catch(error){failures++;console.error(`FAIL ${label}: ${error.message}`)}
}
const line=(text,edge)=>{
  const value=edge+' '+text+' '.repeat(28-width(text))+' '+edge;
  assert.equal(width(value),32,'one border + one pad + 28 content + one pad + one border');
  return value;
};
const glyphAt=(text,column)=>{
  let x=0;
  for(const {segment} of new Intl.Segmenter('und',{granularity:'grapheme'}).segment(text)){
    if(x===column)return segment;
    x+=width(segment);
  }
  throw Error(`missing display column ${column}`);
};
check('canonical source modal style table',()=>{
  for(const spec of specs){
    const source=readFileSync(`themes/${spec.file}.toml`,'utf8');
    assert.match(source,new RegExp(`\\[components\\.modal\\.decoration\\]\\nborder = "${spec.border}"\\nshadow_enabled = ${spec.shadow}`));
    assert.match(source,/\[components\.modal\.spacing\]\npadding_left = 1\npadding_right = 1/);
  }
});
check('High contrast actual 16-cell footer',()=>{
  const expected='Gallery | High c';
  assert.equal(expected.length,16);
  assert.equal('Gallery | High contrast | 0/2'.slice(0,16),expected);
  assert.equal(frame(smokeGoldens,'High contrast',16,6)[5],expected);
  assert.equal(frame(ptyGoldens,'High contrast',16,6)[5],expected);
});
check('all four border and one-cell modal padding projections',()=>{
  for(const spec of specs){
    const edge=spec.border==='ascii'?'|':'│';
    const top=spec.border==='ascii'?'+'.concat('-'.repeat(30),'+'):'╭'.concat('─'.repeat(30),'╮');
    for(const [fixture,values] of [[modal,contents],[ptyModal,ptyContents]]){
      const rows=frame(fixture,spec.name,80,24,'modal');
      assert.equal(rows[7].slice(24,56),top,`${spec.name} top border`);
      for(let i=0;i<values.length;i++){
        const projected=line(values[i],edge);
        assert(rows[i+8].startsWith(projected,24),`${spec.name} modal content y${i+8} with 1+28+1 interior`);
      }
    }
  }
});
check('preset shadow projection and unmodified no-shadow rows',()=>{
  for(const spec of specs){
    for(const [fixture,startup] of [[modal,smokeGoldens],[ptyModal,ptyGoldens]]){
      const rows=frame(fixture,spec.name,80,24,'modal');
      const base=frame(startup,spec.name,80,24);
      if(spec.shadow){
        for(let y=8;y<16;y++)assert.equal(glyphAt(rows[y],56),'░',`${spec.name} right shadow y${y}`);
        assert.equal(rows[16].slice(25,57),'░'.repeat(32),`${spec.name} lower shadow`);
      }else{
        for(let y=8;y<16;y++)assert.equal(glyphAt(rows[y],56),glyphAt(base[y],56),`${spec.name} no right shadow y${y}`);
        assert.equal(rows[16],base[16],`${spec.name} no lower shadow`);
      }
    }
  }
});
check('negative projection controls',()=>{
  assert.notEqual(line('Preview','│'),'│Preview'.padEnd(31)+'│','missing left pad rejected');
  assert.notEqual('Gallery | HighCo','Gallery | High c','fabricated abbreviated footer rejected');
  assert.notEqual('░'.repeat(32),' '.repeat(32),'phantom high contrast shadow rejected');
});
if(failures)process.exitCode=1;

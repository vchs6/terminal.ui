import assert from 'node:assert/strict';
import {frame,palette} from './fixtures.mjs';
const segmenter=new Intl.Segmenter('und',{granularity:'grapheme'});
const wide=new Map([['中',2],['文',2],['👩‍💻',2]]);
export function width(value){let n=0;for(const {segment}of segmenter.segment(value))n+=wide.get(segment)??1;return n}
export function cellAt(rows,x,y){
  let column=0;
  for(const cell of rows[y].cells){if(column===x)return cell;column+=width(cell.text)}
  throw Error(`no cell starts at ${x},${y}`);
}
export function sameGrid(rows,goldens,name,w,h,state='startup'){
  assert.deepEqual(rows.map(row=>row.text),frame(goldens,name,w,h,state),`${name} ${state} complete ${w}x${h} grid`);
}
export function matchesGrid(rows,goldens,name,w,h,state='startup'){
  const expected=frame(goldens,name,w,h,state);
  return rows.length===expected.length&&rows.every((row,i)=>row.text===expected[i]);
}
export function acceptedPalette(rows,name){
  const want=palette[name];if(!want)return false;
  if(!rows.at(-1)?.text.includes(`Gallery | ${name} |`))return false;
  try{
    return cellAt(rows,79,22).bg===want.bg&&cellAt(rows,79,23).bg===want.bg&&
      cellAt(rows,0,1).fg===want.fg&&cellAt(rows,40,1).fg===want.fg;
  }catch{return false}
}
export function checkStyles(rows,name){
  const want=palette[name];
  assert(acceptedPalette(rows,name),`${name} accepted visible palette and footer`);
  assert(cellAt(rows,0,1).attributes.includes(1),'Gallery title bold');
  assert.equal(cellAt(rows,0,4).fg,want.accent,'focused TextInput accent');
  assert(cellAt(rows,0,4).attributes.includes(4),'focused TextInput underline');
  assert(cellAt(rows,0,6).attributes.includes(7),'selected ID radio inverse');
  assert.equal(cellAt(rows,40,2).fg,want.accent,'rich named accent');
  assert(cellAt(rows,40,2).attributes.includes(1),'named accent bold');
  assert(cellAt(rows,48,2).attributes.includes(4),'rich accent span underline');
  assert.equal(cellAt(rows,40,7).fg,'named:90','disabled Button bright-black');
  assert(cellAt(rows,40,7).attributes.includes(2),'disabled Button dim');
  assert(cellAt(rows,48,0).attributes.includes(2),'disabled menu entry dim');
}

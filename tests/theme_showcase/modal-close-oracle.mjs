// A menu label named Preview remains after the modal closes. Literal full-grid
// predicates avoid a false timeout or accepting a partially cleared layer.
import assert from 'node:assert/strict';
import {ptyGoldens,modalGoldens,presets,frame} from './fixtures.mjs';
import {matchesGrid} from './checks.mjs';
for(const name of presets){
  const closed=frame(ptyGoldens,name,80,24).map(text=>({text}));
  const open=frame(modalGoldens,name,80,24,'modal').map(text=>({text}));
  assert(closed[0].text.includes('Preview'),`${name} persistent menu label is present`);
  assert(matchesGrid(closed,ptyGoldens,name,80,24),`${name} closed grid accepted`);
  assert(!matchesGrid(open,ptyGoldens,name,80,24),`${name} open modal rejected as closed`);
  assert(matchesGrid(open,modalGoldens,name,80,24,'modal'),`${name} open modal accepted`);
  assert(!matchesGrid(closed,modalGoldens,name,80,24,'modal'),`${name} closed grid rejected as open`);
  const partial=closed.map(row=>({...row}));partial[8].text=open[8].text;
  assert(!matchesGrid(partial,ptyGoldens,name,80,24),`${name} one uncleared modal row rejected`);
}
console.log('PASS modal-close oracle: all four literal open/closed grids, persistent menu label and partial-row negatives');

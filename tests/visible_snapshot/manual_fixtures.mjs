// Manually authored C003 grids. No product executable, exporter, or captured
// output is consulted here. Coordinates and widths are documented in README.
export const fixtures = new Map();
const add = (name, rows, styles = [], width = undefined) => fixtures.set(name,
  {rows, styles, width: width ?? undefined});
const glyphRows = ['éBC…', '中e\u0301 '];
for (const name of ['glyph-default', 'glyph-auto', 'glyph-unicode', 'glyph-old']) add(name, glyphRows, [], 4);
add('glyph-ascii', ['é...', '中e\u0301 '], [], 4);
add('glyph-changed', ['Q   ', '中e\u0301 '], [], 4);

const top = 'e\u0301中👩‍💻ABC';
const rich = [[0, 0, {fg: 'rgb:17,34,51', underline: true}]];
const styledSpace = [3, 1, {bg: 'index:4', bold: true}];
const modal = [2, 3, 4].map(x => [x, 1, {inverse: true, underline: true}]);
add('layers-base', [top, 'ijklmnop', 'qrstuvwx'], rich, 8);
add('layers-holes', [top, 'ijX mnop', 'qrstuvwx'], [...rich, styledSpace], 8);
add('layers-nested', [top, 'ijM  nop', 'qrstuvwx'], [...rich, ...modal], 8);
add('layers-covered-update', [top, 'IJM  NOP', 'qrstuvwx'], [...rich, ...modal], 8);
add('layers-closed', [top, 'IJKLMNOP', 'qrstuvwx'], rich, 8);
add('layers-old', [top, 'ijX mnop', 'qrstuvwx'], [...rich, styledSpace], 8);

for (const [name, row] of [['right-clip', '#A !'], ['whole', '#界!'], ['left-clip', '# B!'],
  ['shrunk', '#B !'], ['old', '#A !']]) add(`viewport-${name}`, [row], [], 4);
add('viewport-overlay-initial', ['#X !'], [], 4);
add('viewport-overlay-scroll', ['#XB!'], [], 4);

const shadows = (x, bottomStart, count) => [
  [x, 2, {dim: true}], [x, 3, {dim: true}],
  ...Array.from({length: count}, (_, index) => [bottomStart + index, 4, {dim: true}])];
const initial = ['abcdefgh', 'ab╭──╮gh', 'ab│界│░h', 'ab╰──╯░h', 'abc░░░░h'];
add('decorated-initial', initial, shadows(6, 3, 4), 8);
add('decorated-old', initial, shadows(6, 3, 4), 8);
add('decorated-moved', ['abcdefgh  ', 'abc╭──╮h  ', 'abc│界│░  ', 'abc╰──╯░  ', 'abcd░░░░  '], shadows(7, 4, 4), 10);
add('decorated-shrunk', ['abcdefgh', 'ab╭─╮fgh', 'ab│ │░gh', 'ab╰─╯░gh', 'abc░░░gh'], shadows(5, 3, 3), 8);
add('decorated-closed', ['abcdefgh', 'abcdefgh', 'abcdefgh', 'abcdefgh', 'abcdefgh'], [], 8);

add('theme-seed', ['x  '], [[0, 0, {bg: 'rgb:17,34,51', inverse: true, underline: true}],
  [1, 0, {bg: 'rgb:17,34,51'}], [2, 0, {bg: 'rgb:17,34,51'}]], 3);
add('theme-local', ['x  '], [0, 1, 2].map(x => [x, 0, {bg: 'rgb:17,34,51', inverse: true, underline: true}]), 3);
add('zero-width', ['', ''], [], 0);
add('zero-height', [], [], 3);
add('zero-both', [], [], 0);

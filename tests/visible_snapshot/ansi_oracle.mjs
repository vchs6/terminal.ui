import assert from 'node:assert/strict';

export const defaultStyle = () => ({ fg: 'default', bg: 'default', bold: false, dim: false,
  italic: false, underline: false, inverse: false, strikethrough: false });

// Deliberately finite fixture vocabulary, not a general Unicode-width engine.
const knownWidths = new Map([['中', 2], ['界', 2], ['👩‍💻', 2], ['e\u0301', 1], ['é', 1], ['…', 1],
  ...Array.from('╭╮╰╯─│░', value => [value, 1])]);
const segmenter = new Intl.Segmenter('und', { granularity: 'grapheme' });
function widthOf(glyph) {
  if (/^[\x20-\x7e]$/.test(glyph)) return 1;
  assert.ok(knownWidths.has(glyph), `unreviewed fixture glyph ${JSON.stringify(glyph)}`);
  return knownWidths.get(glyph);
}

function sgr(parameters, style) {
  const codes = parameters === '' ? [0] : parameters.split(';').map(Number);
  for (let index = 0; index < codes.length; index++) {
    const code = codes[index];
    if (code === 0) Object.assign(style, defaultStyle());
    else if ([1, 2, 3, 4, 7, 9].includes(code)) {
      style[({1: 'bold', 2: 'dim', 3: 'italic', 4: 'underline', 7: 'inverse', 9: 'strikethrough'})[code]] = true;
    } else if (code === 22) { style.bold = false; style.dim = false; }
    else if ([23, 24, 27, 29].includes(code)) style[({23: 'italic', 24: 'underline', 27: 'inverse', 29: 'strikethrough'})[code]] = false;
    else if (code === 39 || code === 49) style[code === 39 ? 'fg' : 'bg'] = 'default';
    else if ((code >= 30 && code <= 37) || (code >= 40 && code <= 47) ||
             (code >= 90 && code <= 97) || (code >= 100 && code <= 107)) {
      const background = (code >= 40 && code <= 47) || code >= 100;
      const value = code >= 90 ? code % 10 + 8 : code % 10;
      style[background ? 'bg' : 'fg'] = `index:${value}`;
    } else if (code === 38 || code === 48) {
      const key = code === 38 ? 'fg' : 'bg'; const mode = codes[++index];
      if (mode === 5) {
        const value = codes[++index]; assert.ok(Number.isInteger(value) && value >= 0 && value <= 255);
        style[key] = `index:${value}`;
      } else {
        assert.equal(mode, 2, 'supported extended SGR');
        const rgb = codes.slice(index + 1, index + 4); index += 3;
        assert.equal(rgb.length, 3); assert.ok(rgb.every(v => Number.isInteger(v) && v >= 0 && v <= 255));
        style[key] = `rgb:${rgb.join(',')}`;
      }
    } else assert.fail(`unsupported snapshot SGR ${code}`);
  }
}

export function manualGrid(rows, overrides = []) {
  const result = rows.map(row => {
    const cells = [];
    for (const {segment} of segmenter.segment(row)) {
      const width = widthOf(segment);
      cells.push({ glyph: segment, width, continuation: false, style: defaultStyle() });
      if (width === 2) cells.push({ glyph: '', width: 0, continuation: true, style: defaultStyle() });
    }
    return cells;
  });
  for (const [x, y, patch] of overrides) Object.assign(result[y][x].style, patch);
  return result;
}

// Fresh blank screen on EVERY call. CUP/SGR only; no historical frame or product
// parser/Frame output is used as an expectation. Every destination cell must be
// explicitly covered, including trailing blanks and wide continuation cells.
export function consumeAnsi(text, width, height) {
  if (width === 0 || height === 0) {
    assert.equal(text, '', 'zero-axis ANSI contains no controls');
    return Array.from({length: height}, () => []);
  }
  assert.ok(text.startsWith('\x1b[0m'), 'independent initial style reset');
  assert.ok(text.endsWith('\x1b[0m'), 'independent final style reset');
  const style = defaultStyle();
  const cells = Array.from({length: height}, () => Array.from({length: width}, () =>
    ({glyph: ' ', width: 1, continuation: false, style: defaultStyle()})));
  const touched = Array.from({length: height}, () => Array(width).fill(false));
  let x = 0, y = 0, positionKnown = false, offset = 0;
  while (offset < text.length) {
    if (text[offset] === '\x1b') {
      const match = /^\x1b\[([0-9;]*)([Hm])/.exec(text.slice(offset));
      assert.ok(match, `unsupported control at byte/string offset ${offset}`);
      offset += match[0].length;
      if (match[2] === 'm') sgr(match[1], style);
      else {
        const values = match[1].split(';').map(Number);
        assert.equal(values.length, 2, 'explicit CUP row and column');
        [y, x] = values.map(value => value - 1);
        assert.ok(Number.isInteger(x) && Number.isInteger(y) && x >= 0 && x < width && y >= 0 && y < height);
        positionKnown = true;
      }
    } else {
      const end = text.indexOf('\x1b', offset);
      const chunk = text.slice(offset, end < 0 ? text.length : end); offset += chunk.length;
      assert.ok(positionKnown, 'text requires explicit position');
      for (const {segment} of segmenter.segment(chunk)) {
        const span = widthOf(segment); assert.ok(x + span <= width, 'no autowrap or clipped cluster');
        for (let index = 0; index < span; index++) {
          cells[y][x + index] = {glyph: index === 0 ? segment : '', width: index === 0 ? span : 0,
            continuation: index !== 0, style: {...style}};
          touched[y][x + index] = true;
        }
        x += span;
      }
    }
  }
  assert.ok(touched.every(row => row.every(Boolean)), 'full target explicitly covers every cell');
  assert.deepEqual(style, defaultStyle(), 'final attributes restored');
  return cells;
}

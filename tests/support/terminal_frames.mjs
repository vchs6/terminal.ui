import assert from 'node:assert/strict';
import { spawnSync } from 'node:child_process';
import { mkdirSync } from 'node:fs';
import { fileURLToPath } from 'node:url';

const directory = fileURLToPath(new URL('./', import.meta.url));
const tool = `${directory}target/terminal-size`;
export function prepareTerminalSizeTool() {
  mkdirSync(`${directory}target`, { recursive: true });
  const built = spawnSync('cc', ['-std=c11', '-Wall', '-Wextra', '-Werror',
    `${directory}terminal_size.c`, '-o', tool], { encoding: 'utf8' });
  assert.equal(built.status, 0, built.stderr);
}
export function atomicResize(tty, cols, rows) {
  const changed = spawnSync(tool, [tty, String(cols), String(rows)], { encoding: 'utf8' });
  assert.equal(changed.status, 0, changed.stderr);
  assert.equal(changed.stdout, `${cols} ${rows}\n`, 'single atomic SET is independently read back');
  return changed.stdout.trim();
}

// Narrow full-repaint reader for the ASCII fixtures and the integration fixture's
// three known wide graphemes. It is not a general terminal emulator/Unicode table.
const segments = new Intl.Segmenter('und', { granularity: 'grapheme' });
function columns(text) {
  let width = 0;
  for (const { segment } of segments.segment(text)) {
    if (segment === '中' || segment === '文' || segment === '👩‍💻') width += 2;
    else if (/^[\x20-\x7e]$/.test(segment)) width++;
    else return -1;
  }
  return width;
}
export function completeFrames(buffer) {
  const text = buffer.toString('utf8');
  const starts = [...text.matchAll(/\x1b\[0m(?=\x1b\[1;1H)/g)].map(match => match.index);
  const frames = [];
  for (let index = 0; index < starts.length; index++) {
    const body = text.slice(starts[index], starts[index + 1] ?? text.length);
    const rows = []; let row = -1, reset = false, valid = true;
    for (const token of body.matchAll(/\x1b\[([0-9;?]*)([A-Za-z])|([^\x1b]+)/g)) {
      if (token[3] !== undefined) {
        if (row < 0 || /[\r\n]/.test(token[3])) break;
        rows[row] += token[3]; reset = false;
      } else if (token[2] === 'H') {
        const [y, x] = token[1].split(';').map(Number);
        if (x !== 1 || y !== rows.length + 1) { valid = false; break; }
        row = y - 1; rows.push(''); reset = false;
      } else if (token[2] === 'm') {
        if (token[1] === '0' || token[1] === '') reset = true;
      } else break; // terminal close/mode sequences follow the completed frame
    }
    const width = rows.length ? columns(rows[0]) : -1;
    if (valid && reset && width > 0 && rows.every(value => columns(value) === width)) {
      frames.push({ width, height: rows.length, rows, offset: starts[index] });
    }
  }
  return frames;
}
export function finalGrid(buffer, expected) {
  const frame = completeFrames(buffer).at(-1);
  return frame && frame.rows.length === expected.length && frame.rows.every((row, index) => row === expected[index]);
}

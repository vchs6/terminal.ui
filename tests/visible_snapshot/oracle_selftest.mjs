import assert from 'node:assert/strict';
import {consumeAnsi, defaultStyle, manualGrid} from './ansi_oracle.mjs';
import {fixtures} from './manual_fixtures.mjs';

// Fixed standard bytes exercise the test tool only; never pretend to be product
// frames or TASK010 RED/GREEN. No product binary is invoked by this command.
const reset = '\x1b[0m';
assert.deepEqual(consumeAnsi(`${reset}\x1b[1;1H界A${reset}`, 3, 1), manualGrid(['界A']));
assert.deepEqual(consumeAnsi(`${reset}\x1b[1;1H\x1b[38;2;17;34;51;1mX${reset} ${reset}`, 2, 1),
  manualGrid(['X '], [[0, 0, {fg: 'rgb:17,34,51', bold: true}]]));
assert.deepEqual(consumeAnsi(`${reset}\x1b[1;1H\x1b[44;4;7m ${reset}`, 1, 1),
  manualGrid([' '], [[0, 0, {bg: 'index:4', underline: true, inverse: true}]]));
assert.deepEqual(consumeAnsi(`${reset}\x1b[1;1He\u0301👩‍💻${reset}`, 3, 1), manualGrid(['e\u0301👩‍💻']));
assert.deepEqual(consumeAnsi('', 0, 2), [[], []]);
assert.deepEqual(consumeAnsi('', 3, 0), []);
for (const text of [
  `${reset}\x1b[1;1HX${reset}`, // Missing final blank cell.
  `${reset}\x1b[1;1H界X${reset}`, // Overruns width two.
  `${reset}\x1b[1;1HX\x1b[?25h${reset}`, // Device mode forbidden.
  `${reset}\x1b[1;1HX\n ${reset}`, // Logical LF forbidden in positioned ANSI.
  `${reset}\x1b[1;1H\x1b[38;2;17mX ${reset}`, // Truncated RGB.
  `${reset}\x1b[0;1HX ${reset}`, // Invalid coordinate.
  `${reset}\x1b[1;1HX \x1b[31m`, // No final reset.
]) assert.throws(() => consumeAnsi(text, 2, 1));
assert.throws(() => consumeAnsi(reset, 0, 2));
assert.throws(() => assert.deepEqual(consumeAnsi(`${reset}\x1b[1;1H\x1b[31mX${reset}`, 1, 1), manualGrid(['X'])));
assert.deepEqual(defaultStyle(), {fg: 'default', bg: 'default', bold: false, dim: false,
  italic: false, underline: false, inverse: false, strikethrough: false});
for (const [name, fixture] of fixtures) {
  const cells = manualGrid(fixture.rows, fixture.styles);
  assert.ok(cells.every(row => row.length === fixture.width), `${name} hand-grid width`);
}
console.log(`PASS test-tool selfchecks only: ${fixtures.size} manual fixture grids; no product execution`);

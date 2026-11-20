// Hand-authored fixture content. Padding is serialization, never a product oracle.
import { readFileSync } from 'node:fs';
export const goldens = JSON.parse(readFileSync(new URL('./goldens/startup.json', import.meta.url)));
export const keys = Object.freeze({f1:'\x1bOP', f2:'\x1bOQ', f3:'\x1bOR', f4:'\x1bOS',
  f5:'\x1b[15~', f6:'\x1b[17~', f9:'\x1b[20~', f10:'\x1b[21~', tab:'\t', backtab:'\x1b[Z',
  enter:'\r', esc:'\x1b', down:'\x1b[B', up:'\x1b[A', home:'\x1b[H', end:'\x1b[F',
  pageDown:'\x1b[6~', ctrlA:'\x01', undo:'\x1a', redo:'\x19'});
export const paste = text => `\x1b[200~${text}\x1b[201~`;
export const modalGoldens = JSON.parse(readFileSync(new URL('./goldens/modal.json', import.meta.url)));
export const minimalPtyGolden = JSON.parse(readFileSync(new URL('./goldens/minimal-pty.json', import.meta.url)));

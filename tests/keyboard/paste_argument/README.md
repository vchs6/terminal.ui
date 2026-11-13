# Three narrow keyboard regressions

This standalone public consumer only adds three asserting selectors. All prior
TASK113 assertions and H01/formal vectors remain unchanged. Build normally once:

```sh
cd tests/keyboard/paste_argument
cjpm build
CJTUI_KEYBOARD_ARGUMENT_CASE=c1-byte-budget ./target/release/bin/main
CJTUI_KEYBOARD_ARGUMENT_CASE=ctrl-text ./target/release/bin/main
python3 native_pty.py --binary target/release/bin/main --output /new/absolute/native-capture
```

Each selector expects0 on a conforming product. Run them independently; an
assertion failure is nonzero. `bash tests/keyboard/paste_argument/run.sh` runs
only these three selectors and preserves an overall nonzero verdict. The
optional CJTUI_KEYBOARD_ARGUMENT_ARTIFACTS destination must be a new directory.

| Selector | Hand-derived oracle |
|---|---|
| paste-native | Real Application.run, base focused, valid7-bit frame with ASCII_OK; target throws one unique IllegalArgumentException object. Original object/message must escape run, no InvalidPasteEncoding or other issue, cleanup exactly once/resources0, native mode/termios restored. Trailing q is a safety exit for a broken swallowing path and must not be delivered on success. |
| c1-byte-budget | Surrounding A/B are ordinary text. Raw9B+ASCII`?25;1$y` is8bytes: limit8 gives UnsupportedSequence@1. UTF8 C2/9B+sameASCII is9bytes: limit8 gives SequenceTooLong@1, limit9 gives UnsupportedSequence@1. A/B and the finish tail are checked independently. |
| ctrl-text | Ctrl-a with empty text reaches handler once; custom code with legitimate payload remains accepted. Ctrl-a with nonempty x must throw IllegalArgumentException before any handler, preserving the healthy session. |

Authority: canonical K001/K002/F002/F003 plus Runtime R010/R012/R017. Native
input uses the real TTY and keyboard UTF8/paste completion path; public dispatch
cannot substitute for it. The native driver records actual child exit and
binary hashes before/after, raw input/output, stderr, callback files and exact
termios. A watchdog/forced exit or fixture failure is classified separately and
never becomes behavioral RED. All three Cangjie bodies must compile against
the actual public K API; no declarations or private hooks are supplied.

# TASK-061 automatic capability test freeze

This worktree is the independent test contract at `9466f89` plus the remaining
TASK-061 fixtures. It changes tests and test documentation only. Generated CJPM
locks, build targets, and the `generated-terminfo/` database are deliberately not
tracked. The capability database is synthetic branch coverage, not a terminal-host
matrix; TASK-066 owns the latter.

## Frozen coverage

- Public Cangjie consumer: default `Application(root)`, named override constructor,
  `Basic8`, `colorModeAuto()`, diagnostic fields, and a pure default TrueColor
  `Frame.toAnsi()` snapshot.
- PTY profile consumer: known monochrome/8/16/256/direct terminfo profiles;
  terminfo plus COLORTERM and COLORTERM-only sources; missing, dumb, invalid, and
  unknown TERM; six exact-standard-SGR capabilities; NCV 18 and an unknown NCV
  bit; non-SGR rejection; Basic8 override and Auto restoration.
- A test-local `--wrap=dlmopen` archive forces the optional loader failure without
  a product hook. Its separately loaded base `libtinfo` entry stays at synthetic
  `cap-16`; the session profile probe must leave it untouched, proving the product
  query used a private namespace.
- Existing colors tests now bind the D031 pure-snapshot default and the ordinary
  example's automatic three-RGB `c` cycle. The manual mode fixture and all of its
  fourteen handshake/transport-barrier assertions are retained as the explicit
  override path.

## SDK and RED evidence

SDK: Cangjie 1.2.0 after
`source /workspace/work/validation/sdk/cangjie/envsetup.sh`, with the existing
private cache at `/workspace/work/auto-tests/cache`, relay
`http://127.0.0.1:18972`, and `CJTUI_UCD_ARCHIVE` fixed to
`/workspace/work/validation/UCD-17.0.0.zip` for subsequent product builds.

`tic -x -o /tmp/cjtui-capabilities-terminfo-check
tests/capabilities/fixture/terminfo.src` exits 0. The native test archive also
compiles with `gcc -std=c11 -Wall -Wextra -Werror -fPIC -O2` on this host without
`term.h`; it dynamically resolves only the base-test symbols.

On the frozen old product, `bash tests/capabilities/run.sh` now reaches the public
consumer and exits 1 with the required missing-API diagnostics: undeclared
`TerminalCapabilities`, missing `Application.terminalCapabilities`, missing
`Application.colorModeAuto`, and missing `ColorMode.Basic8`. This is the intended
API RED, rather than an unavailable native header or a skipped test.

After normal builds using the same cache, `node tests/colors/pty.mjs example`
under the SDK runtime exits 1 on the old example at the new assertion that the
normal application starts with foreground `rgb:1,128,254`. The old application
still implements manual mode cycling, so it supplies no such automatic sample.
This is a second intentional RED for the ordinary-example contract. Directly
executing the rebuilt `tests/colors` consumer also exits 1 at
`default snapshot is the pure TrueColor projection`: the old default projects
`Rgb(1,128,254)` through Basic16 instead of writing `38;2;1;128;254m`.

No GREEN is claimed here. The implementation owner must make the new API compile,
then rerun `tests/run-slice.sh capabilities` and the retained color modes. This
report does not claim real-host terminal or screenshot evidence.

## Basic16 golden correction

After the old capability RED had been preserved, the D029 nominal 16-color table
was independently enumerated for the `Rgb(1,128,254)` Basic16 snapshot fixture.
The former `SGR34` (Blue) golden was incorrect: Cyan is the unique nearest candidate
at squared distance 15,877, versus 16,131 for BrightCyan and 16,386 for BrightBlue.
The corrected fixture requires `SGR36`. The full arithmetic trace is retained at
`raw/basic16-rgb-1-128-254.txt`. A same-batch scan found no other Basic16 RGB
expectation for this tuple. Independent enumeration also confirms every retained
`tests/colors` Basic16 projection: Rgb250→9, Rgb64→0/1 tie (index 0),
Indexed17→4, Indexed232→0, and Indexed255→15. The retained expectations therefore
remain consistent with D029.

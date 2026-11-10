# Uncertain terminal glyph advance — formal tests (TASK163)

Contract: `openspec/changes/fix-uncertain-glyph-advance/design.md` A001–A008 at
`1113ba186bc0ff72fd4c6c91a0e17fc3f19c69c5`. Product RED baseline:
`91c22f82adcd2412d9509b9872ff63450ba81af9`. This directory adds tests only.
No public test hook, dependency change, alternate width table, Unicode segmenter,
terminal renderer/model, or production DSR protocol is required.

## Normal build and package tests

Use SDK 1.2.0 and the existing dependency relay. From an independent checkout,
prepare ignored normal CJPM configuration for every project being built. Seed
an independent cache by copying, never modifying, the seed directory:

```sh
source /workspace/work/validation/sdk/cangjie/envsetup.sh
export CJTUI_UCD_ARCHIVE=/workspace/work/validation/replay-dependencies/UCD-17.0.0.zip
# TASK163 used /workspace/work/glyph-advance-tests/cache, copied from:
# /workspace/work/validation/replay-dependencies/cache
# root and tests/glyph_advance/public/cangjie-repo.toml each contained:
# [repository.cache]
# path = "/workspace/work/glyph-advance-tests/cache"
# [repository.home]
# registry = "http://127.0.0.1:18973"
# version = 0
cjpm build
bash tests/glyph_advance/run.sh all
```

`public` builds an ordinary path-dependency consumer and directly executes its
binary (34 literal checks). It preserves public `displayWidth`, grapheme counts,
canonical `Frame` cells, rich reactive snapshots, `toAnsi`, `writeAnsi` and
`writePlainText` bytes. It does not call private APIs.

`internal` copies the actual production source/native/build manifest into a
fresh temporary directory, copies the package-local test files into its `src`,
and runs normal `cjpm test --no-color --timeout-each=10s`. It removes the temporary
copy afterward and never changes visibility or real product files. This is the
existing G010 legal package-local test pattern. `CJTUI_ADVANCE_ALL_ERRORS=1`
adds only CJC's diagnostic count option in that temporary manifest.

Nine `@Test` functions cover 20 literal projection input rows, Unicode versus
conservative policy, zero/negative widths, bounded sums and widths above two,
full encoding, canonical head/continuation preservation, both directions of
wide-fallback versus two independent question cells, style groups and color
projection equality, visible style changes, both old/new profile policies,
profile switches with equal columns, dimensions, clipping, stored ambiguous
width, real Frame budget rejection, and zero-area `Int64.Max` empty axes.
All expected text and terminal bytes are hand literals from A003/A004; no
product projection generates an expected value. Direct helper widths above two
exercise its contract; they do not claim a multi-grapheme string is a reachable
single Frame head. Excess-sum checks use bounded inputs. Unreachable enormous
strings/allocations do not establish exhaustive Int64 arithmetic coverage;
checked/saturating arithmetic remains a source-review obligation.

`existing-device` runs one of those tests using only old private interfaces. It
checks default offline Unicode bytes before requiring device `????` for ZWJ and
VS16, including all five color modes. On old91, this compiles and executes, then
fails its first Monochrome device assertion. The current helper reports that
assertion as an exception (CJPM `ERROR`), distinct from compilation failure.

On old91 `internal` fails compilation because the new private policy/projection
APIs are absent. That compile RED does **not** replace the physical RED below.
The future public GlyphMode/VT/marker implementation remains TASK094.

## Frozen physical RED and oracle controls

```sh
bash tests/glyph_advance/run.sh fixture-controls  # exit 0
bash tests/glyph_advance/run.sh physical-old      # intentional exit 1
python3 tests/glyph_advance/physical/verify_replay.py \
  --replay tests/glyph_advance/physical/fixtures/fresh-zwj-replay --kind zwj
python3 tests/glyph_advance/physical/verify_replay.py \
  --replay tests/glyph_advance/physical/fixtures/public-vs16-replay --kind vs16
```

`physical-old` always checks immutable old-product evidence and intentionally
remains RED after a product fix; it is not part of `all`. `all` runs the public
and package tests plus the fixture-control integrity check.

`physical/fixtures/origins.json` records original paths and SHA256 for every
copied original. PNG files are complete, original real-host X11 captures, never
repainted or rescaled. The oracle compares actual row-four pixels, not OCR or a
logical ANSI grid. At the frozen 100×28 configuration the complete row-four
rectangles are XTerm `(2,59,1002,78)` and VTE `(1,85,1001,104)` (exclusive right
and bottom). These come from the actual 10×19 cell geometry and host chrome;
resizing preserves those origins; the oracle extends the right edge by the actual
window-width increase, covering the complete resized row as well. Original/full and subsequent delta images
are compared within the same host and geometry.

The native evidence has 116 complete raw DSR replies with input/output offsets,
34 original PNGs, exact termios restoration and host/native exits. The genuine
single-variable CJK replacement and padding-minus-two controls each preserve
row four and end at `3;100`; removing only ZWJ still fails at `4;3`. There are
12 control observations (8 accepted, 4 rejected), not fabricated terminal-model
results. The unchanged original083 example adds its actual initial/t/t/resize/t/q
record, original binary/source hashes, PNGs, raw output and restoration.

The base oracle observes 16 actual failures: eight original native green/red
replays, two VS16 suffix positions, and six original083 changed-row captures.
It validates full `CSI row;col R` replies against their raw bytes, offsets and
preceding queries. It does not accept the old same-width logical grid model as
a host oracle and does not reinterpret its historical PASS metadata as physical
success.

Fresh TASK163 adapters also reproduced the original ZWJ failure on both hosts
(10 additional complete DSR, six PNGs) and the opposite VS16 public-consumer
failure (10 DSR, six replay PNGs plus its complete real GUI session). The ZWJ
prefix is physically `3;14` versus required `3;12`, then wraps to `4;3` and changes
row four. VS16 leaves the suffix start at `3;2` versus required `3;3`, although its
row four and final `3;100` are unchanged. The suffix-position check therefore
catches under-advance that a final cursor/row-four-only test would miss.

## Fresh product GUI execution (TASK166)

`physical/capture.sh` adapts the original083 GUI harness. It runs the actual
ordinary example unchanged, sends `t`, `t`, performs an actual X11/PTTY resize,
sends `t`, then `q`; it retains original PNG/raw output, capture UTC, actual
TTY dimensions, inner/outer termios and real exits. It consumes the checkout's
existing `tests/terminals` recorders and a locally compiled external X11 helper.
It does not change terminal wrap or other advanced modes.

From the independently built candidate checkout (normal config also prepared in
`examples/rich-text`), set a fresh output directory each time:

```sh
cc -O2 -Wall -Wextra -Werror tests/glyph_advance/physical/gui_key.c -ldl \
  -o /tmp/glyph-advance-gui-key
(cd examples/rich-text && cjpm build)
CJTUI_ADVANCE_GUI_KEY=/tmp/glyph-advance-gui-key \
CJTUI_TERMINAL_CAPTURE_DIR=/absolute/fresh/example \
bash tests/glyph_advance/physical/capture.sh xterm-default xfce-vte

# Opposite VS16 error: actual ordinary public consumer; defaults to heart VS16.
CJTUI_ADVANCE_HOST=1 \
CJTUI_ADVANCE_FIXTURE_DIR="$PWD/tests/glyph_advance/public" \
CJTUI_TERMINAL_EXAMPLE_BIN="$PWD/tests/glyph_advance/public/target/release/bin/main" \
CJTUI_ADVANCE_GUI_KEY=/tmp/glyph-advance-gui-key \
CJTUI_TERMINAL_CAPTURE_DIR=/absolute/fresh/vs16 \
bash tests/glyph_advance/physical/capture.sh xterm-default xfce-vte
```

The public fixture's second row contains ASCII/CJK/e+0301/single woman/single
laptop/flag unchanged. Its changed third row has VS16 followed by `Z` and no ZWJ,
so opposite errors cannot cancel. Optional fixture inputs
`CJTUI_ADVANCE_SAMPLE=sun|keycap` select the other A003 examples;
`CJTUI_ADVANCE_COLOR=basic8|truecolor` exercises explicit public color override
without exposing a glyph switch. Validate default and explicit color behavior
on the changed runtime paths, as required by TASK166.

```sh
python3 tests/glyph_advance/physical/verify_capture.py \
  --captures /absolute/fresh/example --kind zwj
python3 tests/glyph_advance/physical/verify_capture.py \
  --captures /absolute/fresh/vs16 --kind vs16
python3 tests/glyph_advance/physical/replay.py \
  --captures /absolute/fresh/example --kind zwj --out /absolute/fresh/example-dsr
python3 tests/glyph_advance/physical/replay.py \
  --captures /absolute/fresh/vs16 --kind vs16 --out /absolute/fresh/vs16-dsr
python3 tests/glyph_advance/physical/verify_replay.py \
  --replay /absolute/fresh/example-dsr --kind zwj
python3 tests/glyph_advance/physical/verify_replay.py \
  --replay /absolute/fresh/vs16-dsr --kind vs16
```

The external replay driver sends actual captured bytes to real XTerm398 and
XFCE4 Terminal1.1.4/VTE0.80.1 using the original argv/font/locale/empty-XDG config.
Its only adaptation is stripping the util-linux script header from initial
capture and inserting a complete DSR query at a known payload boundary; the
payload is unchanged. It records derivation hashes and every native input and
output byte. For ZWJ the boundary precedes the long padding run (literal expected
cursor `3;12`); for VS16 it precedes `Z` (literal `3;3`). Both final rows must end
at `3;100` with row-four pixels unchanged. A complete first-three-stage replay
supplies this independent physical oracle; the actual application GUI session
separately proves the full t/t/resize/t/q behavior and restoration.

Hosts, Xorg, ImageMagick/Pillow and helper scripts are development tools, never
runtime or bundled product dependencies. Hash final artifacts only after hosts
exit. Retain old FAIL evidence alongside new results. This finite matrix is no
claim about arbitrary fonts, Unicode versions or unknown hosts. A new-product
physical PASS is pending independent TASK166; frozen old evidence never proves
that a candidate product fix works.

# TASK-061 independent color/style test handoff

Binding product/design baseline: `f3329d2f9308c7242aea22266d5ab45d781e03b1`.
Fresh clone: `/workspace/work/color-tests/repo` from `/workspace/work/terminal.ui`.
Only test sources, test runner additions, and test documentation were edited. No
product implementation author's directory, implementation changes, or reasoning
was read. No subagents were used. Existing R8/R9/060 assertion files are unchanged.

## Frozen artifacts

1. `4583b3d4cd7eb40bda828bc7ba92a5db338fe1bc`: public consumer, ordinary public
   session fixture, runner `colors` / `colors-integration` / retained old `all` plus new modes.
2. `2bc683ee41c55195714d88f88cec3e8403e53428`: actual colors example PTY,
   handshake-acknowledged silent-update fixture checks, test README, and SDK-only
   fixture syntax correction (let Array capture and Unit-compatible if statements).
3. `fdbd9acd17f02ffbbf2d8cb54ae288e34605a0fd`: final isolated component-setter assertions. These add checks; no expectation
   or old assertion is relaxed.

All three commits are a linear chain. Product manifests remain version 0.0.0.
New consumers were created with SDK `cjpm init`, then configured as ordinary
relative-path cjtui consumers. No generated locks, artifacts, or cache are committed.

## Commands and observed results

Environment: Cangjie Compiler and CJPM 1.2.0, x86_64 Linux. Each real build uses
normal product hooks, no private FFI flags and no `--skip-script`.

```sh
source /workspace/work/validation/sdk/cangjie/envsetup.sh
export CJTUI_UCD_ARCHIVE=/workspace/work/validation/replay-dependencies/UCD-17.0.0.zip
cd /workspace/work/color-tests/repo
./tests/run-slice.sh colors
```

Initial RED: exit **1**, 70 missing-new-API errors (8 printed by compiler default),
original raw `/workspace/work/color-tests/consumer-red.log`. Compiler reaches the
ordinary consumer and reports absent ColorMode and bright Color constructors.
The optional expanded diagnosis, with `--error-count-limit all` temporarily set
only in the test manifest and restored afterward, reports all 70 missing API/
field/parameter diagnostics: `/workspace/work/color-tests/consumer-red-all.log`.
No unrelated syntax diagnostic appeared in that full initial diagnostic set.
Final consumer source RED (exit **1**) is `/workspace/work/color-tests/consumer-red-final.log`:
81 errors, first 8 printed, still missing ColorMode/bright constructors at the same
binding baseline. The direct runner propagated the compiler failure.

```sh
(cd tests/colors/session && cjpm build)
```

Final fixture RED: exit **1**, missing Color.Rgb and the public Application
colorMode constructor argument; `/workspace/work/color-tests/fixture-red-final.log`.
The compiler also reports std.fs as unused because the invalid Application
construction prevents checking its callback. The fixture syntax was separately
checked with a standalone SDK-only language probe (no product mock or generated
product API), cjc exit **0**, in `/workspace/work/color-tests/sdk-fixture-syntax.log`.
That probe checks Array capture, conditionals, UInt8 bytes and File.writeTo; its
unused-value warnings concern only the standalone probe.

```sh
node --check tests/colors/pty.mjs
bash -n tests/run-slice.sh
git diff --check
```

All exit **0**. A test-facility-only parser check fed an independently literal
RGB+bold row split into 1..7-byte chunks and checked identical screen/style
results, exit **0**. This is parser verification, not product behavior evidence.
The actual new product APIs and `examples/colors` do not exist at the binding
baseline; no implementation GREEN, full-suite GREEN, or PTY product pass is claimed.

## Independent expected values and synchronization

`golden-calculation.txt` contains a separate Node integer enumeration of the
nominal palette and squared distances. It imports no product, ansies, tests or
captured output. In particular: red250/249 tie indices9 and196 in Indexed256,
therefore normalize to BrightRed9; RGB64 ties Basic16 0/1, selecting0; RGB128gray
ties8/244, selecting8; cube17 decodes (0,0,95) and selects Blue4; (1,128,254)
selects33 at distance51; gray238 selects255. Exact ANSI expectations in the
consumers are standard literal SGR codes in contract order, not generated output.

The public fixture has three business rows and a fourth EVENT-FENCE row. Each
operation sends its key followed by h. The second onKey writes an ack file only
after the prior render loop has run, and toggles only fence bold. Receipt of the
complete fence row is an additional PTY byte-stream barrier. Exact comparison of
all bytes from the action through that fence permits business-row silence to be
asserted without a sleep or product hook. Fourteen operations check downgrade
aliases, Monochrome color-only changes, TrueColor changes, six attributes and
reset, named/indexed equivalence, and unchanged plain/named rows during mode switches.

The actual examples/colors PTY checks c cycle, six independent t attribute
changes and round-trip, resize 100x40→31x12→8x4→100x40, q status and exact termios.
It does not bind a title, business text or require custom product hooks.

## Evidence limits / next role

The implementation author receives fixed tests/API/commands, not a presumed pass.
The independent executor must run normal builds followed by direct binaries,
new PTYs, retained regressions, normal bundle and clean consumer checks against
reviewed product commits. The tests deliberately expose no writer injection;
Frame/mode baseline commit-after-complete-write remains a code-review obligation.
No source scan, parser check or this RED handoff substitutes for that execution.

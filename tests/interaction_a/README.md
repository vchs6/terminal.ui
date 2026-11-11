# Public interaction A — TASK098 fixed test assets

These are independent tests for formal A/I001–I015 and A-01–A-06, based on
`41f29f16cf372e1ed1904e1fbf0cdd7d657e2aef`. Accepted080/084/088/152/097 are
present. A does not wait for092. The baseline builds normally; the real
080/084/088/152 public prerequisite consumer builds and executes. The new public
A consumer is actual missing-API RED (Canvas/PaintContext/focus), not missing
Theme/Session and not a declaration library result. No A behavior is GREEN.

Use SDK1.2.0, official stdx1.2.0-beta.02.1 and the normal ignored registry/cache
configuration. The accepted product documents its stdx compatibility layout.

```sh
export CJTUI_UCD_ARCHIVE=/workspace/work/validation/replay-dependencies/UCD-17.0.0.zip
bash tests/interaction_a/run.sh --prerequisites  # real current API build/direct0
bash tests/interaction_a/run.sh                # prerequisites, real A build/direct
bash tests/interaction_a/run.sh --device       # basic real PTY protocol cases
CJTUI_INTERACTION_A_OUTPUT=/tmp/fresh-A bash tests/interaction_a/run.sh --matrix
CJTUI_INTERACTION_A_OUTPUT=/tmp/fresh-fixture bash tests/interaction_a/run.sh --changed-fixtures-only
```

Use fresh output directories. The normal entry uses CJPM and the direct binary,
never cjpm run, skip-build, a fake library or declaration execution. The matrix
builds an isolated normal consumer from identical formal Cj sources, changing
only the relative manifest path and adding the test-only clock object with
`--wrap=cjt_monotonic_ms`. Trace evidence must show real clock samples; an
unwrapped product cannot silently pass. The original `--fixtures-only` selftest
remains available; its unchanged clock/PTY evidence may be reused by hash.

The existing twenty Cj files retain full literal cells/styles/Unicode clip,
selected-source precedence, independent measure/paint dependencies, three tiny
public compositions, capture/bubble/default traces, physical dynamic focus,
readonly/error precedence, expired paint, caret snapshots, cleanup and limits.
Coverage links each AC to those sources. One new current-only error observer is
also compiled against the actual prerequisite library, without A standins.

All94 frozen protocol/timing/fault vectors retain their literal inputs and
oracles.87 have executable A public-product drivers: the former70 plus all17 A
recipes. The remaining7 are explicit future Keyboard113–117 (full CSI100ms
incomplete semantics, OSC/DCS/paste payload isolation, maxSequenceBytes8/9/64),
not requirements to implement Keyboard in A. B viewport/scroll/ensure and C
modal/owner/surface/occlusion integration remain their respective boundaries.

`fixtures/native_cases.py` supplies the final clock-before/after/pending/overflow,
mount-stop, stop/SIGTERM/controlled poll-HUP A read-error/callback/draw/cleanup,
interrupt-before-report, headless/known/close/headless and rerun-status drivers.
The device consumer writes public error/primary/additional/resource/reopen
observations to files; it emits no protocol directly. HUP injection is on libc
poll for real TTY fd0 after an explicit arm file; it exercises existing A -3,
not future Keyboard -4 EOF. No production read or clock hook is added.

Writer zero/partial failures cover query/frame/caret-only/cleanup. A test-only
LD_PRELOAD shim matches the actual armed literal transaction buffer (exact
7-byte query, frame marker, caret-only CUP, original-hidden cleanup) and records
physical call/data/result evidence. No product call count is guessed. Partial
injection delivers exactly one byte, then fatal; later stdout is forbidden,
runtime resources must release, termios restores and same-process reopen must
refuse ParserUnsynchronized. Zero-byte caret failure permits only the original
hidden restore; failed cleanup never retries output. Caret fault plus explicit
cleanup failure verifies the original write error stays primary. These extend
new A boundaries while unchanged S008 evidence remains reusable.

The changed-fixture selftest executes only literal syscall peers on real PTYs,
checks ten selected/default injection paths plus controlled poll HUP, and rejects
wrong transaction/duplicate fault/unsafe later output/wrong zero restore and
Unknown-query/mode negative controls. It is infrastructure, not a cjtui or mode25
policy implementation. It never runs a declaration or pretends to implement A.

The fixtures do not decode input or render expected frames. They send frozen
bytes and inspect public snapshots, status files and wire/termios observations.
The actual 87-vector/A-headless product execution awaits099/101. Real
XTerm/VTE/VT two-original-state multi-frame PNG/version/config/raw evidence,
normal bundle/clean consumer and100–102 acceptance remain later evidence; no
same-PTY TERM change substitutes for a physical host implementation. No
TASK017/020/028/029/030/M2 or full-Linux completion is claimed.

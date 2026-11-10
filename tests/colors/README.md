# Color PTY resize oracle (R019)

`node tests/colors/pty.mjs` executes the ordinary public color fixture and actual
`examples/colors` executable. `bash tests/run-slice.sh colors-integration` performs
the normal CJPM builds first. SDK1.2.0 and the existing normal per-checkout CJPM
configuration/dependency relay are unchanged.

The accepted runtime R019 contract is frozen in
`openspec/changes/implement-reactive-runtime/design.md` at
`fc7667339d39208bbd0c25650696a7f495ca971d` and described in
`tests/resize-coherence/README.md`. A frame prepared using a real complete old
size may finish after resize. Tests requiring one size jump must set both fields
in one TIOCSWINSZ. GNU `stty rows12 cols31` performs two SETs and really creates
100x12 between100x40 and31x12; that intermediate pair is not an impossible
product observation.

The old color harness prematurely reset Screen to31x12 before running that stty
command. Actual original failure bytes contain a complete100x12 frame at
[5189,6705), so its first100-column row was wrongly rejected as expected31.
The original failure and ioctl trace remain unchanged in `fixtures/` with
source paths/SHA256 in `fixtures/origins.json`. A direct old-harness run can also
pass when the application does not sample the brief intermediate state; the
regression is therefore established by deterministic original-byte controls,
not a demand that every unsynchronized live run fail.

Resize now reuses `tests/support/terminal_frames.mjs`'s existing native atomic
SET/readback helper. Startup stty sets the initial geometry before launching the
application; all tested application resize jumps use the single-SET helper.
The existing Screen/CUP/SGR reader remains the only active parser. During a resize
it accepts only complete old or target pairs, tracks all sequential full-frame
rows, rejects any third width/pair, and requires the final complete target grid.
The color scenarios use distinct widths100→31→8→100, so the first complete row
identifies which of the two allowed pairs is being delivered. This is a bounded
fixture reader, not a general terminal emulator or new Unicode implementation.

The target31x12 and8x4 text and every foreground/background/attribute cell are
hand-authored structured literals. Returning100x40 must equal the original full
styled grid. Existing14 handshake-acknowledged exact-byte actions, RGB cycles,
six attribute toggles, direct application exit0 and exact termios restoration
remain enforced. Session completion waits for stdio close and propagates any
parser error received before close, including after target completion. The existing100ms no-output interval only checks that an
already complete target remains settled; row completion still uses actual CUP
boundaries/reset, and no added sleep hides old output or relaxes correctness.
An old frame, partial target, or last frame at the old size cannot satisfy the
target predicate.

Run deterministic controls separately:

```sh
node tests/colors/resize_oracle_test.mjs
```

They load the **exact historical Screen implementation** from fixed91 Git history
(`91c22f82adcd2412d9509b9872ff63450ba81af9`) to prove its false rejection of the
actual100x12 failure bytes and a coherent old frame. A fresh unchanged R019
native write-gated old24x5→target8x3 stream supplies a real in-flight positive
control: the old oracle rejects it; the corrected reader accepts its exact
complete final grid. Additional controls accept split transport chunks, but
reject malformed row width, third width, the now-impossible100x12 pair under an
atomic two-state transition, oversized height, old-only/partial/old-final
unsettled streams, and wrong target style. No product hook, runtime edit, new
terminal model or modified business example is involved.

Artifacts are selected by `CJTUI_COLOR_ARTIFACTS`; each actual resize records the
old/target pair, verified native readback and all accepted complete frame pairs.
The broader R019 coherence and in-flight tests remain independent:

```sh
bash tests/resize-coherence/run.sh
```

This fixture correction does not certify any unexecuted new-product source or
real GUI terminal behavior.

# Public interaction A — TASK098 PREPARATION ONLY

This tree prepares a public CJPM consumer for formal I001–I015 and A-01–A-06.
It is not TASK098 acceptance, a strong product RED, or TASK099 admission.
The fixed normal-build base is `d8c5be0bd6b4494384fc9682a648fecb7e74f6dc`.
Accepted TASK084, TASK088, TASK152 sources and the final interface/admission map
must be supplied by root before the complete A consumer can run. TASK080 alone
is insufficient. Existing tests are retained.

From the product checkout, with SDK1.2.0 activated and the existing local registry
configuration available:

```bash
export CJTUI_UCD_ARCHIVE=/workspace/work/validation/replay-dependencies/UCD-17.0.0.zip
bash tests/interaction_a/run.sh
bash tests/interaction_a/run.sh --device
```

The default entry performs normal `cjpm build` in this consumer and directly runs
`tests/interaction_a/target/release/bin/main` (expected exit0); it never uses
`cjpm run`, skips a build script, accesses RuntimeFrame/private hooks, installs a
replacement package, or converts a missing entire Theme/Session into Canvas RED.
`--device` additionally drives the actual binary through real PTYs for unknown,
original-visible and original-hidden probe replies, HT, split CSI Z, rejected
SS3/parameterized Z, caret-only CUP, original mode restoration and termios.
These are protocol/PTY observations, not physical XTerm/VTE/VT pixel evidence.

Infrastructure can be verified before upstream delivery:

```bash
CJTUI_INTERACTION_A_OUTPUT=/tmp/interaction-a bash tests/interaction_a/run.sh --fixtures-only
```

This compiles only test infrastructure and executes `fixtures/selftest.py`.
The C `harness_peer` is explicitly an infrastructure peer. It is never imported
by, linked into, or counted as a cjtui implementation. Selftests record real
PTY input/output, winsize, termios and exit, and reject missing/duplicate query,
forbidden Unknown show, and termios leak. They also check clock 0/599/600,
negative/missing/overflow/malformed values and scripted progression, plus TTY
zero-byte/one-byte-partial write failures. No product binary is executed by this
mode. All output/cache/build artifacts are external or ignored.

`fixtures/vectors.json` freezes 94 literal, hand-written protocol/timing/fault
vectors. Fifty cover each 0..4 status at every two-chunk split including empty
prefix/suffix; malformed variants cover wrong mode, extra parameters, leading
zero, missing/bad status, SS3/C1 and excessive parameters. Deadline599/600,
continuous input, cross-deadline CSI, real100ms idle, duplicates/late reports,
cancel, status lifecycle, payload isolation and writer boundaries are separate.
`fixtures/matrix.py` has executable public-product drivers for 70 of the A
vectors. The other 24 are explicit integration recipes/future-scope vectors,
not silently passing or simulated tests. Their remaining execution work and
blockers are listed in `coverage.json` and the external report.

Deterministic timing uses only the native link wrap in `native/clock_wrap.c`.
Compile it with `gcc -std=c11 -Wall -Wextra -Werror -O2 -c ... -o clock-wrap.o`,
then build an isolated consumer copy with test manifest `link-option` containing
`/absolute/clock-wrap.o -Wl,--wrap=cjt_monotonic_ms`. Do not modify product source
or add a public clock setter. Its normal API remains the actual product.
Set `CJTUI_A_CLOCK_FILE` to an atomic integer control file; optionally use
`CJTUI_A_CLOCK_SCRIPT` (one result per call, repeat last) and `CJTUI_A_CLOCK_TRACE`.
Run `python3 fixtures/matrix.py --binary /absolute/wrapped-binary --output /tmp/matrix`.
The matrix requires trace evidence of the pre-query and t0 clock samples; a
normal unwrapped binary is rejected. Matrix driver product execution is blocked
until the actual monotonic bridge and all other upstream inputs exist.

`native/write_fault.c` is a test-only `LD_PRELOAD` shim restricted to real-TTY
stdout writes. `CJTUI_A_WRITE_FAIL_AT` is a 1-based physical write call;
`CJTUI_A_WRITE_FAULT=zero` returns EIO before bytes; `partial` delivers exactly
one byte then EIO on the next retry. `CJTUI_A_WRITE_TRACE` logs attempted writes
on a separate file descriptor. Pin the query/frame/caret-only/cleanup transaction
to actual S008 writer call evidence before executing the frozen fault vectors;
never assume an upstream implementation's call count. Reuse unchanged S008
checks rather than rerunning the entire Session matrix. Product outputUnsafe,
first-error aggregation/reopen and native cleanup assertions remain blocked on
accepted152. The shim selftest proves injection, not that product recovery works.

The device consumer supports `CJTUI_INTERACTION_A_EXIT=mount-stop`, `draw-error`,
`cleanup-error`, input `e` for callback failure, `q` for stop and Ctrl-C for input
interrupt; SIGTERM/signal and A's current -3 EOF require the accepted native
fixture path. Cleanup is once per mount: the first run writes closed-cleanup=1;
the diagnostic lifecycle headless mount increments final cleanup to2 while
retaining the device capabilities snapshot. `CJTUI_INTERACTION_A_RERUN=1` adds a
second actual run, whose probe/status reset must be driven as a separate turn.
First-ever headless capabilities=None is covered in the headless consumer.

A's existing CSI has no full Keyboard100ms incomplete-CSI timeout. Do not fail A
for the later K002 behavior, or claim A passes full Keyboard. Exact reports
inside paste, partial OSC/DCS strings, maxSequenceBytes8/9/64 and issue-ordering
integration are explicitly blocked until113–117. The single decoder remains
product-owned; fixtures send raw literals and observe outputs, with no decoder
oracle, input replay, protocol queue, resolver, Unicode implementation or
expectation generated from product output.

Native mode authorization, logical caret, successful writer baseline, original
mode restoration bytes, and physical host effect are separate observations.
The actual three-host/two-original-state PNG multi-frame/version/config/raw
matrix remains unexecuted, as do clean-bundle consumption and full admission.
Only root may integrate, review, execute and accept those later stages.

# Native session bridge regressions

These are **white-box C module tests**, separate from the ordinary public Cangjie
consumers and real-PTY integration suite. They compile the actual product
`native/cjtui_terminal.c` as a separate translation unit, then use GNU linker
`--wrap` to control the external isatty/tcgetattr/tcsetattr/poll environment.
No product logic, source changes, or substitute product implementation is supplied.
The syscall seam is intentionally specific to the Linux C bridge; refactoring that
seam requires independent test-author review, not weakening the owner/cancellation
expectations.

Run from the repository root on Linux with GCC, pthreads and GNU coreutils timeout:

```sh
./tests/native-session/run.sh
./tests/native-session/run.sh owner
./tests/native-session/run.sh setup-signal
```

Each case runs in its own process. Compilation failure, assertion failure, signal
termination, or timeout is failure. The runner compiles in a temporary directory
and removes only that test directory afterward. There is no SDK, Node, Python,
registry, or real-terminal requirement for these module tests.

The design input is `implement-linux-first-slice/design.md` D-021 plus the unified
terminal ownership/cancellation/restoration contract. The independent review's
fixed-baseline reproduction appendices B/C supplied syscall interleaving clues;
expected results follow that contract, not the original implementation's results.

- `owner`: pauses the first opener at TTY setup, then starts a second opener while
  the first is outstanding. A second device snapshot, if attempted, is delayed
  until the first opener finishes. Exactly one cjt_open may succeed, and the
  subsequent cjt_close must restore the original complete termios snapshot.
  The gate releases the first opener when the second reaches the environment,
  returns early, **or after a short scheduling window**. It never requires both
  threads to reach an internal barrier; atomic early rejection and serialization
  outside the syscall seam can progress. A true hang fails via process deadlines.
- `setup-signal`: raises a real SIGTERM during the first tcsetattr call after
  successful simulated TTY checks/snapshot. The actual product sigaction handler
  receives it. Setup must retain cancellation so the following cjt_read(0) returns
  -2; close must succeed and restore the original termios. A wrapped poll returns
  no input, so idle timeout (-1) cannot be mistaken for successful cancellation.

The simulated terminal starts with nonzero input/output/control/local flags and
control characters. These tests expose ownership and startup-signal ordering in a
controlled external environment; they do **not** claim real-PTY end-to-end or full
Application fault acceptance. The separate PTY tests supply real terminal evidence.

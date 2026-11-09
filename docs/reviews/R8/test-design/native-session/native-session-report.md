# Independent native-session regressions

Product source baseline: 2794136e45aee98300f4b16456dfa6b605cfdf74.
Test commit: e2cdf963e36bd53ce1aa21e967894184c17089bd (on public-regression commit 9119615).
Actual checkout: /workspace/work/first-slice-tests/repo.

Expected results come from design.md D-021 and unified owner/cancellation/terminal
restoration requirements. Independent fixed review appendices B/C at
/workspace/work/first-slice-review/review.md supplied reproducible external syscall
interleavings; they were not treated as expected implementation behavior. Only
bridge ABI declarations and that fixed independent report were consulted for this
module test; no repair-author source/reasoning or directories were read.

These are white-box Linux C bridge tests, distinct from public Cangjie consumer
or real-PTY evidence. The actual product native/cjtui_terminal.c is compiled as a
separate translation unit with tests/native-session/session.c; GNU linker wrappers
control only isatty/tcgetattr/tcsetattr/poll. The product's sigaction is real.
No product C, Cangjie, native build support, public API or design was modified.

Reproduction (no SDK/cache setup required):

```sh
cd /workspace/work/first-slice-tests/repo
./tests/native-session/run.sh
# or independently:
./tests/native-session/run.sh owner
./tests/native-session/run.sh setup-signal
```

Actual gcc -std=c11 -Wall -Wextra -Werror -pthread compilation: exit 0, no diagnostics.
Actual complete runner: exit 1. Both cases exited 1 with failed assertions, not a
timeout or forced signal. Raw combined output: native-session-red.log.

```text
owner: open1=0 open2=0 successes=2 close=0 restored=0 original_lflag=32779 restored_lflag=0
FAIL owner: exactly one open may own the terminal, and close must restore its original termios
setup-signal: open=0 read_after_SIGTERM=-1 close=0 restored=1
FAIL setup-signal: setup must preserve the real SIGTERM for the next read cancellation (-2), then restore termios
```

Owner scenario: first opener pauses before completing TTY setup. Second opener
attempts entry while first is outstanding; any second device snapshot waits until
the first finishes. The expected successful open count is one. The gate also
accepts second-open early rejection or serialization outside the syscall seam:
first is released when second reaches the environment, returns, or after a bounded
scheduling interval. It never waits for both threads to enter an internal barrier.
Process deadlines make a true deadlock fail; they cannot turn it into success.

Setup-signal scenario: first tcsetattr changes the external simulated device then
raises real SIGTERM into the product's handler. The next cjt_read(0) must report
cancellation -2 and close must restore the saved termios. The actual result -1 is
idle/no-input, proving cancellation was lost despite a successful close.

Verification: bash -n tests/native-session/run.sh, git diff --check and staged diff
check exited 0. The two failing cases are formal regression RED, not product pass.
README explicitly limits these controlled-environment module tests; they do not
replace real-PTY Application execution or final product acceptance. Product
repair and independent re-execution remain separate roles. No subagent or remote
push was used by this test author.

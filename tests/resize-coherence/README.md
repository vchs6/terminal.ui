# Coherent terminal dimensions (R019)

Frozen contract: design at `fc7667339d39208bbd0c25650696a7f495ca971d`.
The independent public application is a normal CJPM consumer. Its test-local
link wrappers always call the actual ioctl/write/close. The query gate waits
after a successful read; the write gate waits before actual delivery. Neither
invents dimensions/frames nor restores termios for the product.

```sh
./tests/run-slice.sh resize-coherence
# Ordinary build alone, then independent selected scenarios:
./tests/resize-coherence/run.sh build
node tests/resize-coherence/pty.mjs tests/resize-coherence/target/release/bin/main coherence
node tests/resize-coherence/pty.mjs tests/resize-coherence/target/release/bin/main inflight
```

`coherence` first observes a complete 24×5 frame. A file handshake arms the
first odd successful TIOCGWINSZ result thereafter: the old two-query implementation
has completed its width read but not its height read. The wrapper preserves the
real returned winsize and blocks before returning it. The parent performs one
TIOCSWINSZ setting both fields to 8×3, verifies by readback, and releases the
query. Every kernel result can only be 24×5 or 8×3; every complete application
frame must therefore have one of those pairs. The same gate works with the new
single-snapshot path, which returns a complete old pair then later the new pair.
No assertion depends on a new symbol merely existing.

`inflight` instead holds the first already-prepared frame immediately before
its actual write. The parent resizes once and releases it. The full old 24×5
frame then arrives after resize; this is explicitly required to be accepted.
Both scenarios must reach the hand-authored complete settled 8×3 target:

```text
CJTUI_CO
01234567
```

The third row contains exactly eight spaces.

Only after normal q exit, one real successful close, and exact termios restoration
does the coherence assertion reject any pair absent from both real states. A
mixed 24×3 frame remains a failure even if the final target settles. Each mode
runs separately and retains fresh raw bytes, parsed grids, real ioctl results,
gate markers, atomic resize readback, native records and result JSON. Set
`CJTUI_RESIZE_ARTIFACTS` to choose an existing/new artifact parent. Timeouts and
forced cleanup are failures. Gate waits depend on predicates; timers only bound
deadlocks or observe the final settled interval.

The shared `tests/support/terminal_frames.mjs` reader handles the supported full
CUP-row/SGR repaint format and ASCII plus the integration fixture's three known
wide graphemes. It does not claim to emulate a complete terminal or Unicode
engine. It requires all rows, exact display widths/content, and a closing reset;
a shared prefix or partial frame cannot satisfy final-grid checks.

The lifecycle and integration resize scenarios now use the same atomic helper
and full final-grid check, preserving normal exit, clipping, close and termios
checks. They accept lawful old in-flight frames in historical output. The new
coherence scenario independently retains the stronger impossible-pair check,
so correcting their old history-wide ban cannot turn the product defect green.
GCC/cc/ar, Node, util-linux script/stty are test facilities only. No product source,
SDK, shared cache, public API or application hook is modified.

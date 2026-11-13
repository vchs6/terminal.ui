# I015 Keyboard-stage real idle coverage

Only `csi-real-idle-Keyboard` is activated here, using one K-only public
Application.run consumer and one PTY. Old `tests/interaction_a/fixtures/vectors.json`
rows, old A runner/oracle and old A consumer remain byte-for-byte unchanged.
`csi-real-idle-A` belongs to the earlier A decoder with no CSI timeout; its
original-visible oracle is not applicable to a full Keyboard provider. Select
this runner's explicit `--stage Keyboard` instead. No old A consumer imports
KeyboardIssue or onKeyboardIssue, and no full matrix is invoked.

With the normal SDK/stdx/UCD/cache setup:

```sh
CJTUI_KEYBOARD_I015_ARTIFACTS=/new/absolute/artifacts bash tests/keyboard/i015_stage/run.sh
```

The shell builds an ordinary isolated `.wrapped` CJPM consumer from identical
Cj source, adjusting only library path and linking the existing A clock-wrap
object with `--wrap=cjt_monotonic_ms`, as A's own runner does. Existing
`input_hup.c` is used solely to observe real poll entry/completion; its HUP
injection environment is never set. Input is a real controlling PTY. No product
clock API, alternate decoder, synthetic poll result or timeout implementation
is added.

Manual vector, from existing future-Keyboard and cross-deadline rows and
canonical I015§478 / K002/F006/F007:

1. t0=1000, probe deadline=1600. Clock1100: send exact prefix ESC[?25;.
   Observe six real byte-ready polls and the subsequent100ms poll entry;
   switch clock1201 during that poll. Require its actual zero-result real
   completion after at least100ms and a public IncompleteInput@0 while the
   probe is still pending. Tail1$y must deliver normal text1/$/y; query s must
   report pending. This excludes probe expiry as the cause of nonauthorization.
2. Same ledger, reuse existing cross-deadline control: prefix at1580, observe
   subsequent20ms real probe poll, switch1600 for that completion, then tail
   at1610 within real100ms of prefix. Require no second diagnostic, protocol
   tail swallowed, and query s reports unknown-timeout. The600ms wakeup itself
   must not call decoder.timeout; the expired probe cannot authorize.
3. q exits0. Exact business trace is `text:1|text:$|text:y|text:s|text:s|text:q|`;
   exactly one IncompleteInput@0, cleanup once/resources0, termios restored.
   Pending/Unknown wire contains no25h/l/s/r, and query is sent exactly once.

Real poll records, controlled clock trace, immutable capability/query files,
raw input/output, actual binary exit and before/after hashes are retained.
Timing/handshake failure is fixture failure, never fabricated product RED or
GREEN. This is finite coverage, not actual-host input/PNG or full K/A acceptance.

## Single pure malformed-drain supplement

`CJTUI_KEYBOARD_I015_PURE_CASE=malformed-drain bash tests/keyboard/i015_stage/run.sh --pure` builds/runs only the independent
`pure/` consumer against the same fixed provider; it does not rebuild/run the
native vector. With maxSequenceBytes8, the literal bytes
`A + ESC + [1 SP 2 + 22222 + A(final) + B` become malformed at sequence length5,
before the budget. At every two-chunk split, expect outer text A/B and only
MalformedSequence@1. Crossing8 while already draining must add neither a second
SequenceTooLong nor leaked payload. One fixed timeout control invokes timeout
after stream byte6 (Malformed emitted at sequence length5, still below8),
then supplies remaining digits/final/B: still only Malformed@1 and text A/B,
without IncompleteInput or released payload. This is one vector, not a matrix.

The independent `alt-invalid-offset` pure selector first repeats the existing
Alt timeout positive (A ESC E4 B8, timeout, B: text A/B and IncompleteInput at
ESC byte1), then feeds ESC E4 ESC [ A. Root explicitly ruled that K001 retains
InvalidUtf8@1 for
the bad UTF8 prefix, then new up; F007 adds no cancellation IncompleteInput or
MalformedSequence and does not erase that UTF8 boundary obligation. All
observations are collected before assertions, preserving exact actual values.

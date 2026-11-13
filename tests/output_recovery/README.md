# C002 / S008 output recovery consumer

This is TASK008.a independent formal test design against product BASE
`51529b7f5bce9c639d54876c378b54aa1cd3aaf2`. It adds no product API or writer.
`run.sh build` is an ordinary CJPM path consumer using the product build hook;
`run.sh run` launches that binary directly in real util-linux PTYs. Set
`CJTUI_RECOVERY_ARTIFACTS` to a new evidence directory for each execution.

Use SDK1.2, configured public registry/warm cache, stdx and the pinned UCD archive
as described by the integration brief. No SDK/cache/target is part of this test.
The only test FFI is syscall/link fault injection, adapted from
`tests/session_extensions/native/session_fault.c`. The existing native owner,
buffer, output byte counter, parser-unsafe latch, open/close and Application remain
real. Candidate transaction files are diagnostic inputs for cut enumeration only.
They are never the normal expected output: the literal normal grid, SGR and wire
checks must pass first. Existing `tests/colors/pty.mjs` provides its independent
row/style reader; no second renderer/parser/Unicode width implementation is added.

## Hand-derived expected matrix

| Target | Complete expected cells / controls | Fatal at byte k |
| --- | --- | --- |
| First 4x1 target | `A`, `é`, blank, blank; all default Style | Exactly first k transaction bytes |
| Shortened target | `é`, blank, blank, blank; all default Style | Tail may be incomplete; stop, never claim target displayed |
| Style-only target | `A`, `é` RGB(1,128,254)+bold; two default blanks | Every CUP/SGR/UTF8/reset byte boundary |
| Unchanged target | Same dimensions, glyph policy, effective color profile and caret | Zero screen update transaction |
| Caret-only movement | Same four cells; CUP `ESC[1;3H` | Every CUP byte boundary |
| Startup | 2004 enable, exact 7-byte DECRQM, full target | Every byte boundary of each distinct transaction |
| Optional title | save `ESC[22;2t`, OSC2 `é` BEL, restore `ESC[23;2t` | Shared writer and latch |
| Clipboard | OSC52 `c;w6k=` BEL (`é` UTF8→Base64) | Shared writer and latch |
| Successful short / EINTR | Complete literal normal transaction; run succeeds | Retry is success, not a failure case |
| EIO or zero return at k=0 | Current run throws exact first device error; unsafe=0 | Native cleanup, next run may open |
| EIO or zero return at 0<k<len | Current run throws ParserUnsynchronized; unsafe=1 | No later frame, mode, title, clipboard, CAN/ST/reset; next run refused |
| Device + UI/native cleanup errors | Device error remains primary; both cleanup errors retained | Exactly-once UI cleanup; native close attempted |

Each case records raw PTY bytes, first error, actual process exit, original/restored
termios, signal handlers/masks, native byte count, unsafe state and candidate wire.
Readiness/fence conditions use actual output/native events and a subsequent public
key event, without settling sleeps. Timeouts only bound a failed test.

`--normal` runs the five ordinary controls; `--supplement` runs the changed normal
resize/profile controls and restore cuts; `--only=<case-prefix>` selects a named
reproduction. A selection matching no actual case fails. Every successful retry
also compares actual emitted bytes with the complete independently validated
transactions, so silent truncation cannot pass as success.

Root adjudicated the observed unchanged-visible-caret redundant CUP as a genuine
C002/AC008 RED. `normal-caret` retains the strict zero-additional-transaction
assertion after collecting normal exit and resource restoration evidence. This
test must retain both genuine caret movement and necessary post-frame positioning.

## Source ordering proof obligation

Public `Application.stats().frames` counts generated targets. It is deliberately
not an oracle for successful device commits. With a fatal device error there is no
legal continuing same-session present to distinguish a poisoned baseline publicly.
Independent review must inspect the fixed product at `src/application.cj:660–683`:
write failure records/throws before assigning baseline/profile/dimensions/caret;
allocation failure clears baseline and retries a full frame. Native phase/raw
stop evidence supplies the observable half. Review also verifies
`native/cjtui_terminal.c:60–69` frees buffer/restores signals/termios without output,
and `:108–122` exact emitted bytes plus process-lifetime partial-unsafe latch.
There is no source-string mirror test, getter, product hook or fake safe backend.

## Reused evidence and boundaries

The input manifest `docs/reviews/R22/008/input-manifest.json` fixes accepted R10,
070, S152, I117/I112, E122 and final M162 plus their original evidence. Existing
R10 primary-error/lifecycle/budget/color cases and S152 rich OSC/DCS routes and
payload budgets remain unchanged; their original hashes/verdicts govern reuse.
Old atomic resize assumptions are not copied: current coherent size-pair/full
repaint obligations govern any resize checks. GUI physical appearance, actual
host restoration, release/package checks and full Linux/TASK008 acceptance belong
to later independent execution/review/acceptance roles, not this test-design report.

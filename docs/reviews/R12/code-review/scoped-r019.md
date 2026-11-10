# TASK-073 continuation: R019 scoped independent review

Candidate `0912436` (full SHA in scoped-r019-sourcehash.txt), independent detached checkout `/workspace/work/runtime-review/r019-source`; comparison baseline `c3d743d2dd5cb125e4ca435b2842d1b10c501281`. The three product files are identical to product commit `61ce9e5edc4cb047155165c87596b5afd58fa6b5`; tests are identical to frozen `dddbdd9`. Contract is design section 6 R019, introduced at `fc7667339d39208bbd0c25650696a7f495ca971d`.

**Spec verdict: PASS for R019. Quality verdict: PASS for this bounded change. No Critical or Important findings.** Prior A+B/F001–F007 review conclusions remain applicable by source-impact analysis. This is not a replacement for independent TASK-074 execution/TASK-075 acceptance or a claim that all Linux/parent tasks are complete.

Requested reviewer configuration remains Astra/high; actual serving variant/effort is not independently verifiable. Existing review and verification-before-completion workflow applied. No subordinate agents; no product/test/spec edits. Only fixed sources, contracts, frozen tests and raw commands/bytes/statuses were read. Author reports/self-evaluation were not read. `/workspace/work/runtime-tests/r019` contained only a report, so raw test evidence was located independently under `runtime-tests/raw/r019-*` and referenced artifact directories instead.

## Product review

Only `native/cjtui_terminal.c`, `src/terminal_bridge.cj` and `src/application.cj` change in the product scope.

- `native/cjtui_terminal.c:56`: cjt_size_snapshot executes one TIOCGWINSZ into one winsize. It packs columns in bits 32–63 and rows in bits 0–31, using uint64_t before shifting and returning int64_t. With each input limited to 0..65535, the maximum packed value is below 2^48, so conversion is positive and cannot collide with -1. Zero dimensions are preserved. Failure returns -1 before reading struct fields. EINTR retry is optional in R019; returning -1 preserves the existing error policy.
- `native/cjtui_terminal.c:61`: old cjt_size(int) remains an exported C symbol and is a thin call/decode shim. axis 0 returns columns; any nonzero value, including negative, returns rows as before. It adds no second ioctl rule and propagates -1. Two separate legacy calls are not promised to form a coherent pair; production no longer uses them that way.
- `src/terminal_bridge.cj:8,21`: foreign return type Int64 matches the fixed C int64_t ABI. Private readTerminalSize calls it once, maps negative error to (-1,-1), and uses integer division/remainder by 2^32. For every legal packed nonnegative input these exactly recover the original fields; no signed overflow or sign extension is possible.
- `src/application.cj:200`: one tuple assignment supplies the entire iteration's width/height. Size comparison, snapshot generation and baseline updates consume those local values. The existing `terminal size unavailable` exception and run cleanup/native restoration path are unchanged. The O(1) idle path remains intact and does one size query rather than two. A terminal may resize after this sample; R019 correctly permits completion of the older coherent frame and requires eventual settled refresh.

A focused independent C probe compiled the exact candidate native C with GCC 14.2.0 and a test-local ioctl wrapper. It verified all nine combinations of 0/1/65535, exactly one ioctl per snapshot, exact packed and div/mod decoding, legacy axis 0/1/-1, and error sentinel propagation for both entry points. Compile and direct binary exits are both 0. This is an ABI/unit probe with injected ioctl results, not real-PTY evidence; probe source, commands' outputs and statuses are retained in r019-raw.

## Test/oracle review

The new test facilities do not fabricate product dimensions or frames. Their query/write wrappers call the actual functions and only control scheduling; close wrapper always calls actual product close before recording/injection. The ordinary public fixture uses Application/Column/Text and normal package build hooks.

**Coherence gate:** after a complete initial 24x5 frame, an odd successful query is held after the real kernel response but before returning to the old two-call product. Its first width result remains 24x5 while the parent performs exactly one TIOCSWINSZ to 8x3 and verifies readback. In the old implementation the following height query returns the new pair, deterministically creating 24x3. In the single-query implementation, the held result retains both old fields and later iterations observe both new fields. Logged real query pairs and emitted complete-frame pairs make this a behavioral test, not a symbol-existence check.

**Legitimate in-flight gate:** the first already prepared frame is held before actual write. The parent resizes and releases it; the old complete 24x5 frame must still be accepted, then the target must settle to 8x3. The test explicitly requires the old coherent frame to be present. The wrapper's old-size marker is diagnostic only: assertions inspect actual emitted frame bytes and real query logs.

**Atomic input:** tests/support/terminal_size.c constructs one winsize containing both fields and issues exactly one SET, then independently reads back. Initial stty configuration occurs before the application starts; runtime transitions use this single-SET helper. The test no longer treats stty's potentially separate rows/cols writes as an atomic transition.

**Settled oracle:** integration and lifecycle now require a full literal final 8x3 grid, including blank cells and supported wide graphemes, and check it remains settled across the measured idle interval. They retain normal process status, clipping, exact before/after termios and actual close checks; integration now records actual close for resize. The frame reader has an explicit narrow CUP/SGR/known-grapheme scope appropriate to these fixtures. It requires sequential rows, equal display widths and a closing reset; it is not claimed as a general terminal emulator.

Removing the history-wide ban on old-width text is valid: legitimate in-flight complete old frames can arrive after SET. It does not hide the implementation defect because the separate coherence gate still rejects any complete pair that never existed in the kernel, even when the final grid settles correctly. Existing ordinary source/native recovery obligations are unchanged. No CPU observation is presented as a threshold-based performance pass.

## Raw evidence reinspection and reuse

Relevant frozen test-source hashes (11 files) were compared against `runtime-tests/raw/r019-test-source.sha256` and matched. Product projection and recorded raw candidate heads were checked. No effective unrelated suite was rerun under AGENTS 11.1. Existing exact-candidate build/integration/lifecycle command status files report 0 and record head 61ce9e5; they are raw records, not author self-evaluation, and are not elevated to independent TASK-074 acceptance here.

The reviewer re-parsed original session.raw files with the inspected frozen fixture reader and separately asserted literal final grids, permitted real query pairs, exact termios equivalence and a single successful actual close record:

| Raw scenario | Emitted complete frame pairs | Real kernel pairs | Review observation |
|---|---|---|---|
| Old product coherence | 24x5, **24x3**, 8x3 | Only 24x5 / 8x3 | True semantic RED: impossible mixed frame despite settled final grid and successful restore |
| Old product in-flight | 24x5, 8x3 | Only 24x5 / 8x3 | Legitimate old coherent frame accepted; original command exit 0 |
| New product coherence | 24x5, 8x3 | Only 24x5 / 8x3 | No mixed pair; exact final grid and restoration |
| New product in-flight | 24x5, 8x3 | Only 24x5 / 8x3 | Legitimate old frame retained; exact final grid and restoration |

The old coherence normal build exit is 0 and harness exit is 1 specifically on the mixed-pair assertion. Old in-flight, amended old-product integration settled and lifecycle settled runs exit 0. These demonstrate the fixture correction and product defect independently. New raw coherence/in-flight records are under `runtime-implementation/runs/61ce9e5-coherence/cjtui-resize-mZ0l43`; recorded command exit is 0. No new real-PTY run was necessary merely to repeat these effective bytes.

Reinspection script/output/exit and exact consumed raw-file hashes are retained in `r019-raw/check_raw.mjs`, `raw-comparison.log/.exit`, `raw-inputs.txt`, `reused-inputs.sha256`. This script reproduces the already executed assertions; re-parsing is evidence inspection, not a fresh application execution.

## Explicit exclusions and conclusion

Unrelated theme-design/progress changes in the overall commit range were excluded; no author progress/self-review was consumed. Full runtime/macros/bundle suites, other Linux functionality, C dynamic APIs, M2 and other operating systems remain outside this review. Native open/close/input logic and prior A+B state/lifecycle algorithms are unchanged, so their earlier scoped review remains valid.

R019 fixes the actual two-query race at its owner boundary without duplicating ioctl policy or weakening the runtime contract. The revised oracle now distinguishes the forbidden mixed pair from lawful coherent in-flight output and still validates final rendering and restoration. No additional repair is required by this scoped review.

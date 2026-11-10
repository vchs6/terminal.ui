# Independent colors resize fixture correction

The observed08/08b failure is a **test facility mismatch with accepted R019**.
Those raw records do not demonstrate a product dimension-coherence violation.
The fixture is corrected in test-only commit
**`3138d1a549c5941793b24183bd71cad74d2c688c`**, based on old product
`91c22f82adcd2412d9509b9872ff63450ba81af9`. All seven changed files are under
`tests/colors/`; product, business example, specifications, main, run-slice and
TASK163 tests are unchanged. No subagents or product-author communication were
used, and no product-author report/reasoning was read.

[Classification](classification.json), [source hashes](source-hashes.json),
[machine summary](summary.json) and [incremental ledger](progress.md) are the
factual handoff. This work tests **old91**, not product199f or new-source GUI
acceptance. No new-product GUI PASS is claimed.

## Evidence and root cause

Accepted R019 is frozen in `implement-reactive-runtime/design.md` at
`fc7667339d39208bbd0c25650696a7f495ca971d`; its existing
`tests/resize-coherence/README.md` permits a complete real old-size in-flight
frame to arrive after resize, forbids only pairs absent from real kernel states,
and requires one native SET when a test intends one size jump. Final settled
new dimensions, complete content/clipping and restoration remain mandatory.

The two supplied failures used the exact same fixed91 color harness. Their
`actual-example/session.raw` files are byte-identical SHA256
`7ebf2ffaa047d0a7b7572f717fb9461bd7171d0f78c400940ed90be37ed6e4ac`.
At offsets **[5189,6705)** they contain a complete100x12 frame: ASCII first-row
width100, consecutive CUP rows1–12 and closing reset. The supplied syscall trace
shows successful real states **100x40→100x12→31x12**. Thus100x12 was a real kernel
intermediate state, not a mixed pair invented by product sampling.

`Session.resize` originally executed `Screen.resize(31,12)` **before** spawning
GNU `stty rows12 cols31`. Screen then unconditionally required width31 and
rejected the first legitimate100-column row. This is the same invalid
history-wide new-dimensions assumption that R019 already rejected. The supplied
trace and original08/08b stdout/stderr/PTY records are preserved byte-for-byte
under `raw/original-failure`; the formal regression fixtures preserve the exact
raw stream and trace with original paths/hashes in `tests/colors/fixtures/origins.json`.

Independent syscall reproduction on an own PTY confirms old stty makes two SETs
`100x12`, then`31x12`, while the already-existing native terminal-size helper
makes exactly one successful SET`31x12` followed by verified readback. See
[raw/independent-ioctl-proof.json](raw/independent-ioctl-proof.json) and the two
adjacent complete ioctl traces. No product query/write instrumentation was added.

## Minimal facility change

The color harness reuses the existing `atomicResize` / `prepareTerminalSizeTool`
from `tests/support/terminal_frames.mjs`; it does not introduce another native
helper or terminal model. Initial startup stty remains before the app launches,
as in the accepted R019 fixture; every tested application resize uses one native
SET and readback.

The same existing Screen/CUP/SGR parser now tracks only the two allowed complete
pairs during a resize. It accepts a coherent old/in-flight full frame, validates
sequential rows and exact row width/height, rejects a third width/pair or partial
frame, and waits for a complete final target. The existing100ms quiet interval
only observes stability after structural completion; no sleep was added to hide
output or excuse errors. All three color transitions have distinct widths
100→31→8→100, so the first complete row identifies its allowed pair.

The31x12 and8x4 expected rows and foreground/background/six-attribute cells are
hand-authored literals. The return100x40 grid must still equal the initial exact
styled grid. The14 existing handshake-acknowledged exact-byte actions, automatic
RGB cycle and six-attribute toggles remain unchanged. Session completion now
waits for stdio close and propagates any parser error through normal quit,
including late bytes after target completion. It retains direct exit0 and exact
termios restoration.

## Deterministic controls and real execution

`node tests/colors/resize_oracle_test.mjs` loads the **exact historical Screen**
from fixed91 Git history, rather than recreating its predicate. It proves the
old parser wrongly rejects the actual100x12 stream, a coherent old100x40 stream,
and a real old24x5 in-flight stream. The last stream comes from a fresh unchanged
R019 native write-gate run: the actual old frame is held until after one real
8x3 SET, then delivered before the exact final8x3 grid. That same actual stream
is accepted by the corrected parser.

There are14 named control groups: three historical false-rejection observations,
three fixed-reader accepted streams (including the same gated group), and nine
fixed-reader rejection cases; the gated group observes both old/new behavior.
Rejection cases are malformed row width, third width,100x12 as an impossible
third pair under the corrected *atomic two-state* input, excess target height,
old-only, partial target, target followed by old, late old-size bytes after target
completion, and wrong target style. Split transport chunks are also accepted.
This preserves strictness while correcting the false assumption.

| Actual command/scope on independent old91 | Exit | Result |
|---|---:|---|
| Normal `cjpm build`, root | 0 | Old product builds normally |
| Normal builds, color fixture and actual example | 0 | Own normal consumers |
| `bash tests/run-slice.sh colors-integration` | 0 | Both normal builds, fixture14 exact-byte actions, actual example and restoration |
| Final `node tests/colors/pty.mjs fixture example` | 0 |31x12/8x4 exact text/styles, return100x40, q0, exact termios |
| `node tests/colors/resize_oracle_test.mjs` | 0 | Historical false rejections and all finite/negative controls |
| Unchanged `bash tests/resize-coherence/run.sh` | 0 | Coherence and genuine in-flight modes each24x5→8x3; exact final grid, actual successful close, termios |
| Own unchanged old-harness live example | 0 | Race not sampled on this attempt; accurately preserved |

The last row matters: the old live failure is timing-dependent, so a single old
run can pass. The supplied two real failures and deterministic original-byte /
real-gated counterexamples establish the oracle defect without repeatedly
running until a preferred result appears. Its successful run is retained at
[raw/old-oracle-live](raw/old-oracle-live/execution.json), not hidden or relabeled RED.

Fresh final commands, cwd, UTC, environment, direct exits, stdout/stderr and PTY
artifacts are at [final normal CLI](raw/final-colors-integration/execution.json),
[final sessions](raw/final-colors-after-close-check/execution.json),
[final controls](raw/final-controls-after-close-check/execution.json) and
[R019 execution](raw/resize-coherence/execution.json). Exact termios and the final
allowed pairs were independently checked in
[restoration-and-final-pairs.json](raw/restoration-and-final-pairs.json).

CJC/CJPM are actual1.2.0; normal SDK env and UCD17 archive hashes, unchanged fixed91
tracked product/example/consumer sources, unchanged reused helpers and executed
binary hashes are in `source-hashes.json`. Every built consumer had ignored own
normal CJPM config using `/workspace/work/colors-resize-fixture/cache`, seeded
from read-only `/workspace/work/validation/replay-dependencies/cache` and the
existing relay127.0.0.1:18973. No relay, dependency, SDK, product hook or public
API was added. Generated locks, caches, ELF and checkout are not committed.

The committed test diff passes `git diff --check`. Root can integrate the isolated
test-only SHA and independently run it against product199f in the planned
review/execution stages. The classification resolves this specific fixture
concern; it does not certify the glyph fix or replace165/166/167 evidence.

## CRF001 — fix round1/5, submitted for independent scoped review

The3138 facility review found Important CRF001: an exact target checked before
quit did not constrain the eventual EOF state. I verified the finding before
editing. The unchanged3138 stop accepted late partial rows, incomplete ESC and
complete wrong-style rows despite exit0. The original review inputs are retained
at `raw/crf001/review-input/`; the independently reproduced actual-pipe regression
is [old-stop-red](raw/crf001/old-stop-red/execution.json), exit1, with adjacent raw
stdout/stderr, all eight case observations, frozen pre-fix harness module and
covering test. Five invalid tails were falsely accepted; three legal tails were
accepted. This is oracle-only evidence, not a product/PTY/GUI PASS.

**Fix SHA: `0d46c35456db148f08bd407825a4fd559467249a`**, parent
`3138d1a549c5941793b24183bd71cad74d2c688c`. The scoped fix changes only three
`tests/colors` files: `pty.mjs`, `README.md`, and new `stop_oracle_test.mjs`.
Product, business examples, dependencies, SDK, native helpers, original fixtures,
resize/coherence logic and hand-authored target goldens remain unchanged.

`Session.stop(expectedGrid)` now receives the caller's last explicitly validated
checkpoint. The byte-exact fixture saves it immediately after each accepted
action/fence assertion; the example supplies its original complete100x40 grid
already checked against the final resize. Stop first confirms that checkpoint
still holds before q, waits for actual stdio close, retains exit/signal/termios
assertions, then calls `Screen.finalize()` and compares the final complete styled
grid with the checkpoint. Finalization drains/checks the UTF-8 decoder, requires
complete escape/row/resize state and final rendering reset. A fresh unvalidated
snapshot after late output cannot become the expected value.

Shutdown output is not categorically forbidden. Quiet q/exit0, shutdown SGR0,
and a complete identical styled row are accepted; incomplete or changed final
output is rejected. The original three reviewed cases are directly covered,
plus truncated UTF-8 and a dirty final SGR state.

The covering test **`tests/colors/stop_oracle_test.mjs`** uses real Node child
stdout pipes and close events, and the actual Session.stop/Screen bodies. To
expose the test-local Session it copies the harness with only its helper import
resolved and a test-local export appended; no product hook or alternate parser
is introduced. Each child must actually receive q to exit0. Its equal
before/after marker files are deliberately synthetic, so these cases prove EOF
oracle behavior only; actual product restoration is separately checked below.

| Covering command | Actual exit/output | Raw |
|---|---|---|
| `node tests/colors/stop_oracle_test.mjs` against3138 |1, five illegal tails false-accepted | `raw/crf001/old-stop-red/{stdout,stderr,artifacts/observations.json}` |
| Same command, fixed |0, `PASS colors stop oracle: five invalid tails rejected, three legal closes accepted` | `raw/crf001/final-stop-controls/{stdout,stderr,execution.json,artifacts/observations.json}` |
| `node tests/colors/resize_oracle_test.mjs` |0, all14 existing named groups plus summary | `raw/crf001/resize-controls/{stdout,stderr,execution.json}` |
| `node tests/colors/pty.mjs fixture example`, SDK env loaded, unchanged normal old91 binaries |0, fixture14 exact-byte actions and actual example RGB/six attributes/31x12→8x4→100x40/q | `raw/crf001/actual-old91-colors/{stdout,stderr,execution.json,pty-artifacts}` |

All eight EOF cases have actual child exit0/null signal: the five invalid tails
are rejected by parser/grid assertions, while all three legal close variants
are accepted. The two real Cangjie PTY sessions each finish q/exit0 with exact
termios equality, independently checked in
[actual-restoration.json](raw/crf001/actual-restoration.json). Normal old91 builds
and unchanged R019 coherence/inflight evidence above remain valid and are reused
under AGENTS11.1; they were not cold-rerun merely for this report or review role.
Syntax checks and `git diff --check` pass. No199 product or new GUI claim is made.

Receiving-code-review was read before verification/implementation. The SDD
fix-loop reference and Battle §7 were read for the bounded handoff; root owns
round1/5 and the scoped re-review. CRF001 has a tested fix candidate, **not an
independent VERIFIED verdict**. The exact re-review range is3138..0d46c35; original
failure history and the initial report above are retained.

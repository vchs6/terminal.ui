# Rendering benchmark (implementation in progress)

The benchmark is not yet ready for measurement: implementation and normal
old/new package, full matrix, bundle and independent review checks remain in
progress. Preliminary compatibility and diagnostic paths run public scenes;
no performance or acceptance conclusion is claimed.

The three independent CJPM projects are `workloads` (public API source shared
by both libraries), `compat` (old and new libraries), and the root diagnostic
project (final library only). For a comparison, use byte-identical `workloads`
and `compat` sources in clean consumers and adjust only the library dependency
path. Three final-only diagnostic counters are always `not_available` in compat;
the common source never references those fields. Each executable accepts
`--help`; correctness additionally writes full Cell and independent caret CSVs.

## Normal terminal driver protocol

The external driver sets and verifies the actual terminal dimensions, launches
compat with `--mode tty`, and reads `<csv path>.ack` as a replace-in-place UTF-8
business side channel. Use the same keys and workload sources for both packages.
Handle partial/truncated reads by retrying until the entire expected value is
present. Allow capability/caret probing to settle before beginning. Keys are
processed in normal input/render order:

1. Send `r`; wait for `setup`. Send `r` again. For `overlay_nested_close`, wait
   for `setup-child` and send one further `r`; otherwise the second key suffices.
   Wait for `ready`, which acknowledges the preceding normal render.
2. Send exactly `--warmup` `w` keys. Each yields `warmup:N`; after **each** `w`,
   send `r` and wait for `ready` before the next key. These callbacks use the
   normal application session and let the preceding update render.
3. Send `b`; wait for `begin`. The callback samples Stats and SDK values before
   the acknowledgement and starts the interval after it.
4. For a non-idle workload, send `a` for each business action. Send `f` after
   that action's normal render; it checks the business barrier, changes a
   dedicated last-row fence, and writes `fence:N`. Observe the fence bytes,
   then send `k` and wait for `presented:N`. The `k` callback follows the fence
   render. Reopening a nested child occurs at `f` after the parent has mounted;
   its work and output belong to the fence phase and `k` acknowledges it.
   For `typed_equal`, `f` changes the old dependency only after the equal-value
   replacement has stabilized; its no-change check is a business barrier.
5. For idle, send no keys, mutations, exports, Stats queries, or fence changes
   between `begin` and `e`. Send `e` to close the interval; wait for `end` and
   normal process exit. The end callback takes ending observations before stop.

A side-file write acknowledges business ordering only; it does not claim its own
callback's frame has appeared. Steady workloads retain their complete business roots and screen rows. A
transparent screen-sized overlay draws the fence at the rightmost Cell of the
bottom row. For the required 80×24 and 160×48 local text workloads this leaves
the changed text at the left visible. Dense full-width content can overlap that
Cell; writing over a wide-character continuation can also clear its paired
leader, so up to two columns may be affected. Small dimensions can overlap the
business change. Overlay composition and the framework's wide-character repair
are part of the measured fenced run. The layer, writes and resize-induced
movement are included in process counters and must be identified separately in
output tracing; this is not an unfenced terminal measurement.

### Resize actions

For `resize_pair`, before odd `a` actions the operator resizes the **actual**
terminal to `(W/2,H/2)`; before even actions restore `(W,H)`. For
`viewport_caret`, before action 2 of each three-action period resize to
`(W/2,H)`; before action 3 restore `(W,H)`. The operator verifies each size with
TIOCGWINSZ on the actual terminal descriptor, records the result and waits for
the normal run loop to observe the resize before sending `a`. At `f`, the
benchmark checks the public committed root viewport against the expected size;
a mismatch exits nonzero and produces no sample. This viewport check cannot
prove an oversized terminal's exact dimensions, so the external descriptor
check remains required. Resize and stabilization costs belong to the interval.
For warmup actions, apply the same resize sequence before each `w`; the next
`r` checks the committed viewport before acknowledging readiness.

### Initial terminal lifecycles

`initial` uses fresh normal `Application.run` sessions, not the steady protocol.
For each `warmup-N` then `measured-N` lifecycle, wait for the immutable marker
`<csv>.<label>.starting`, observe the first terminal target, and send `r`. Wait
for `<csv>.<label>.captured` and `<csv>.<label>.closed` before accepting that
lifecycle; the next session starts independently. The runtime CSV is written
after all sessions close. Its initial wall bracket includes the external capture
key wait and must not be described as isolated render CPU. Whole-process CPU,
RSS, actual native output bytes/calls, provenance and trace phase attribution
are separately observed by the independent operator. A synthetic PTY check is
not real-terminal host evidence.

## Headless invocation and observations

Use SDK 1.2, the normal `cjtui` dependency versions, and the documented stdx
and Unicode-data build prerequisites. No measurement utility is linked into
the benchmark. From each ordinary project use `cjpm build`; execute the produced
binary directly so its exit status is observable. No published package is
required. The eventual ordinary CJP must itself be unpacked and built as a
consumer; the include list alone does not establish delivery.

```text
compat --mode correctness|snapshot-headless|tty --scenario ID
       --width W --height H --seed N --warmup N --updates N
       --repetition N --run-id OPAQUE --csv samples.csv
       [--cells-csv cells.csv --caret-csv caret.csv]
diagnostic --mode correctness|m1-headless|m2-headless [same options]
```

Correctness requires both observation paths. Use fresh output paths, especially
for terminal marker files. Unknown flags, invalid integers, invalid dimensions,
unknown scenarios and unsupported mode/scenario combinations fail without a
successful sample. All 36 scenarios have correctness and TTY entries; idle is
normal-run only for timing. Snapshot-headless and standalone M2 support all 35
non-idle scenarios. M1 timing is restricted to `unicode_cells`,
`ellipsis_policy`, `leaf_color`, `same_width_text`, `shared_observable`,
`typed_equal`, `explicit_notify`, `theme_color`, `vertical_panels`, and
`same_row_columns`. These ten are the only paired M1/M2 diagnostic comparisons.
The primary old/new comparison is the identical compat snapshot program, not a
stateful full-render substitute.

Correctness observes epoch zero and one complete declared action period. It
exports every logical Cell, including blanks and wide continuations, and the
caret separately. The diagnostic captures a normal snapshot, then full mounted
render at the same business epoch and glyph policy, checks every Cell field and
caret preservation, and reports the first mismatch. Hand-specified Unicode,
ellipsis, root/viewport and caret cases are checked independently. Producer
and prepared-theme barriers are included where applicable. Correctness/export
and the frame comparison do not run inside headless timing loops.

A steady timing process mounts once, initializes one public snapshot, performs
its warmup, then samples Stats and SDK heap/GC values before and after one batch.
It keeps only the latest returned Frame, including the prior return until the
next assignment, and releases that reference before disposal. The inner
monotonic wall excludes both observation blocks and disposal; sampling wall is
reported separately. Geometry commits, accepted posts, theme barriers and
required actions stay in the measured path. The `initial` case uses one fresh
root and application per update, no preparation snapshot, and sums actual
per-lifecycle work and creation/start/first-target timing brackets. Warmup uses
other disposed instances. No forced collection is requested.

`arranges`, `cell_writes`, and `frame_allocated_cell_slots` are actual final
library counter deltas where available; allocated Cell **slots** are not bytes,
heap allocation totals or object counts. The original eight Stats retain their
library meanings. Scene node, visibility, dirty-leaf, text-byte and layer facts
come from the business fixture and committed viewport where needed; clipped
fixture visibility is distinct from the semantic `NodeRef.isVisible` property.
SDK `getAllocatedHeapSize` is heap occupancy; freed bytes, collection count and
collection time are cumulative GC values, not total allocated bytes. Samples
are non-atomic and can straddle a collection. The CSV exposes those limitations
and the actual counter scope. No sampling overhead is subtracted.

The executable echoes the externally supplied opaque `run_id` and does not
invent provenance. An independent manifest must bind it to the actual source,
ordinary package, executable, SDK, dependencies, native code, host and run
parameters. Whole-process wall, user/system CPU and peak RSS include startup,
warmup, observations, reporting and exit; they are not inner-loop CPU. Native
write/writev return values on the actual terminal descriptor, with phase
boundaries, establish successful output calls/bytes; requested bytes or PTY
read chunks do not. Keep all repetitions and distributions, including broad or
regressing cases. External tool failures and unavailable heap, GC, profiler or
host coverage must be recorded rather than replaced by zero.

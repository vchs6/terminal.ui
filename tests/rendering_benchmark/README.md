# Independent public rendering benchmark contract — TASK143

**TASK143 formal missing-project baseline.** After accepted D142 and root GO, the
dependency-free validator normally built with SDK1.2, its own parser/Cell/caret
selftests passed, and the separate native observer compiled and passed its small
exit-status fixtures. Two native-parser selftest failures and their harness-only
corrections are retained. Actual `build-public` is RED with `MISSING_PUBLIC_PROJECT`;
all three required benchmark manifests are absent. No cjtui/old/new product build,
benchmark workload, TTY, profiler probe or performance measurement was run.
Raw commands, final normal ELF/fixture hashes and scope are frozen in the external
test evidence index `/workspace/work/rendering-benchmark-tests/index.json`.
No passing benchmark, artifact consumption, performance or TASK022/031 claim is made.

Binding requirements: approved `implement-incremental-rendering/design.md` §11,
M003/M005/M006/M011/M012/M013 and its rendering-benchmark spec, fixed at canonical
`6bbf179e` (M013 includes its standalone-M2 clarification). This suite adds only
independent test/report code. It neither edits the product nor imports internals.
The public CLI/method is adopted by canonical M013. Exact CSV report spellings
below derive from its required units and scopes. The full per-scenario mode table,
fresh-generation/idle/retention/windows and independent stateful expectations are
fixed in [measurement_protocol.md](measurement_protocol.md) and
[mode_matrix.csv](mode_matrix.csv); those details govern the summary below.
No FPS or elapsed-time cutoff is added.

## Three ordinary projects and version boundary

| Project in ordinary package | Build dependency | Allowed diagnostics |
| --- | --- | --- |
| `benchmarks/rendering/workloads` | frozen old M1 and final new M2 | common public API and original eight Stats fields |
| `benchmarks/rendering/compat` | same workload source against each ordinary package | new three CSV counters always `not_available` |
| `benchmarks/rendering` | final new M2 only; same workloads library | actual `arranges`, `cellWrites`, `frameAllocatedCells` |

All are normal independent CJPM manifests. Only the dependency manifest path may
change between old/new builds; workload/compat source hashes must remain equal.
The old M1 cannot compile references to the new fields, including in unreachable
runtime branches. Actual old and new builds prove this boundary; source greps do
not. The diagnostic project is never imported by compat/workloads. No library
mode switch, reset, private diff, onFrame callback, SDK/cache patch or test probe
dependency is permitted. `benchmarks` being whitelisted is insufficient: later
clean normal CJP extraction/build/run must establish actual delivery and no hidden
development dependency. The frozen M1 may predate benchmark files; transfer the
same public benchmark sources into clean old/new consumer workspaces for builds.

## Derived public invocation contract

```text
<diagnostic> --mode correctness|m1-headless|m2-headless --scenario ID
             --width W --height H --seed 143 --warmup N --updates N
             --repetition N --run-id OPAQUE_ID --csv samples.csv
<compat> --mode correctness|snapshot-headless|tty [same options]
```

Correctness additionally takes `--cells-csv cells.csv --caret-csv caret.csv`.
`--help` exits zero and identifies the public modes and unavailable compat
diagnostics. Unknown mode/scenario, unknown flag, nonpositive dimensions/updates,
negative warmup/repetition and malformed integers exit nonzero before running.
Errors never produce a successful sample. The harness directly executes binaries;
`cjpm run` wrapper status is not assertion evidence on SDK1.2.

`--run-id` is a nonempty opaque value supplied externally and echoed exactly in
CSV. The harness derives it from actual ELF hash, mode/scenario/size/seed/warmup/
updates/repetition. A CLI label does not verify its own hash: external manifests
and process observer records bind run_id to actual PID, executable, CJP/source,
SDK/native/dependencies and host. Old/new arguments differ only in this metadata
and the ordinary dependency manifest path; common workload sources remain equal.

`correctness` executes epoch 0 followed by one full declared action period from
`scenarios.csv`, regardless of timing update count. Each epoch is an atomic public
batch, with explicit producer gating and a monotonically increasing business
epoch. It exports every Cell and an independent caret record, including hidden
carets. Diagnostic paths are named `m2` then `m1`; compat path is `snapshot`.
First capture `snapshot` and caret/readonly state, then full mounted render in the
same glyph mode at the same size and unchanged business epoch; assert render has
not changed the published caret. Compare all Cell fields, never only plain text,
ANSI, hashes or a subset. Failure reports first coordinate and both complete
structured values, retains raw records and exits nonzero. Manual cases below are
also checked against independent literal expectations by this test consumer.

The correctness-only Cell CSV header is:

```text
scenario,width,height,seed,epoch,path,x,y,grapheme_utf8_hex,cell_width,continuation,transparent,foreground,background,bold,dim,italic,underline,inverse,strikethrough
```

Coordinates are zero based; dimensions describe that actual epoch, including
resize. Emit one record per Cell, even blanks/continuations, in any order.
Grapheme is lossless lowercase UTF8 hex, empty for continuation. Cell widths are
0 for continuation, 1/2 for leaders; booleans are `true`/`false`. Colors preserve
public enum variants: `Default`, `Red`, other exact named colors, `Indexed(1)`
and `Rgb(1,2,3)` (quote comma-containing CSV fields). Never normalize named/indexed
aliases or terminal-projected colors in raw Cell observations.

The independent caret CSV header is:

```text
scenario,seed,epoch,stage,owner,owner_valid,x,y,visible
```

Stages are diagnostic `before_render`/`after_render`, or compat `snapshot`.
`owner` is a stable business key resolved by public `NodeRef.sameNode`, never an
object address. `owner_valid` checks the live public reference. Hidden canonical
caret is `none,false,0,0,false`. Correctness asserts actual full-grid pairing and
caret independently; no Frame-equality result is substituted for the caret.

Timing executes only its requested path, never an oracle, equality or frame hash.
No per-update correctness export occurs in timing. Hold only the latest returned
Frame consistently in both paths; independent public snapshot-return cost belongs
in M2. Sample Stats/SDK counters only at batch boundaries. Do not force GC between
updates, reset Stats, or subtract an oracle cost. Run M1/M2 in separate processes,
retain source/seed/actions, and alternate or randomize order. Premeasure warmup
stability before fixing warmup/updates/repeats; retain every repetition and median
and distribution/interval. The smoke runner's small counts are not performance
acceptance, adequate duration, or a preselected winning run.

## Workload and literal expectations

Run **all** `scenarios.csv` IDs at both 80×24 and 160×48. Period is the number of
actions after initial epoch 0, including restoration. Use mixed
`A中é👩‍💻🇨🇳` plus ASCII on ordinary panels, with foreground/background and the six
attributes exercised. Do not replace emoji/combining text by ASCII in logical
offline results. Use glyph policy explicitly and identically for each pair.

Ordinary vertical workloads use one full-width one-row panel per screen row;
mutate the last panel. Same-row workload uses eight equal-width independent
columns on row 0 and unchanged lower rows. `large_mounted_viewport` mounts eight
times screen height one-row entries inside a four-row explicit vertical viewport;
publish actual total/visible node counts and never claim virtualization. Large
fills/shadows overlap at least half the visible height. The required broad and
global cases remain separate rows/phases; do not average them into local results.
For each workload report actual total/visible nodes, dirty leaves, UTF8 text bytes,
layers and every action. These are scene facts, not inferred performance counters.

Action details binding on the named families: text uses `A中é👩‍💻🇨🇳` →
`A文é👩‍💻🇨🇳` → `A` → empty and restores; flex changes first of eight columns
from one eighth to one quarter width then restores; wrap doubles content length
then restores; resize is base → (W/2,H/2) → base; batch changes text, foreground,
and visibility together; shared Observable has two vertically separated views;
typed-equal replaces a dependency with equal typed result before changing the old
source to demonstrate rebinding; notify mutates nonobservable text then uses the
existing public Content notification. Keyed entries rotate ABC→CAB→BCA→ABC with
manual `|` separators. Theme cases each change only their named category and
restore (four sides are top1/right2/bottom3/left4). Scroll clamps actual committed
offsets; one-step includes 0→1→2→0, multistep uses one visible page. Root fallback
starts finite, grows beyond H, scrolls and restores. Overlay cases distinguish
transparent hole and opaque default StyledSpace, move/shrink old bounds, update
covered lower layers, and close nested ownership. Focus/viewport/caret cases assert
owner identity, transformed coordinates, clipping, hiding/unmount and stale request
suppression independently of grid equality. Output projection uses logical
中→文→?? with Ascii projection, retaining actual zero-update evidence where valid.
`posted_epoch` includes primary normal snapshot timing: producer waits until prior epoch is consumed,
one accepted public post sets text+epoch, snapshot pumps it, producer gates close
before pairing, and both observations assert the same epoch. Theme completion is
similarly accepted/gated before a correctness pair; required preparation,
enqueue/pump and synchronization remain included in primary timing costs.

The literal cases are deliberately simple and fill all unspecified Cells with
opaque default `Style()` spaces. No text layout/width oracle computes expectations:
use a prepared empty-rule Theme (`schema_version=1`, a name, no style rules) so a
preset cannot alter these literal colors/attributes.

* `unicode_cells`: epoch0 and4 row0 has A at0; 中 at1/continuation2; é at3;
  👩‍💻 at4/continuation5; 🇨🇳 at6/continuation7. Epoch1 substitutes 文 at1.
  Epoch2 has only A at0. Epoch3 has only red A at0. All other rows/cells blank.
* `ellipsis_policy`: a width5 Text("abcdef").overflow(Ellipsis) at (0,0),
  ambiguousWide=false: epoch0 `abcd…`, epoch1 `ab...`, epoch2 `abcd…`.
  All are five one-column cells; remaining cells blank.
* `caret_only`: a focused blank Canvas, owner business key `caret`; epoch0 and4
  visible(1,0); epoch1 visible(2,0); epoch2 right-edge request normalizes hidden;
  epoch3 explicit invisible request remains hidden. Complete grid stays blank.
  Hidden caret coordinates normalize to (0,0), owner `none` in the actual API.

## Samples and units

CSV is UTF8 RFC4180 (quoted commas/newlines and doubled quotes allowed), exactly
one header; duplicate headings, missing fields, ragged rows and empty samples fail.
Extra future columns are allowed. `not_available` is the only missing-value token;
every unavailable tool/counter is explained in nonempty `limitations`. Zero is a
real observed zero, never a placeholder. No NaN, infinity or negative counts.

The joined evidence columns are enumerated by `sample_columns.csv`. The ordinary
runtime CSV supplies the workload/counter values. An externally verified metadata
CSV supplies the columns listed in `externalColumns()` plus `run_id`; the validator
joins exactly one actual metadata row per runtime run_id. If the binary also emits
these fields, their values must agree. Hashes are never fabricated to make smoke
pass; preparing the actual manifest belongs to fixed-artifact admission/execution.
Stats are **actual cumulative differences** at the measured boundary;
scope includes target/returned Frame work as M003, including initialization,
repeated writes, COW detach and necessary Cell temporaries. Slots are not bytes,
object counts, heap totals or `sizeof(Cell)` estimates. Original eight fields keep
their documented meaning; state gauges are before/after where applicable.
Heap used is SDK `getAllocatedHeapSize()` occupancy, not `getUsedHeapSize()` or
total allocation; GC freed is cumulative SDK `getGCFreedSize()`; GC count/time are
their actual SDK cumulative values. Record before and after values (occupancy may
decrease); never derive allocated bytes by adding occupancy and freed bytes.
No forced collection is used to make a misleading clean timing window.
`counter_scope` describes the actual boundary. `preparation_snapshots` and
`reference_renders` disclose real calls: diagnostic correctness includes both in
truthful cumulative Stats; performance has zero reference calls and at most one
disclosed initialization snapshot, with no per-update untimed preparation.

Process CPU user/system and monotonic wall are externally sampled by wait4 or an
equally valid real process method; RSS peak is KiB, separately from heap bytes.
External `process.csv` has one row per run; whole-process cost includes construction,
warmup and report overhead and must not be labeled isolated loop CPU. Longer fixed
work batches allow a useful comparison without fabricating a subwindow. Product
runtime never depends on this external tool. Missing profiler sampling does not
excuse omitting valid wait4/SDK/Stats evidence. Preserve failed tool invocations
even if their exit is zero; an absent/empty sampling file is not valid data.

Output evidence is separately traced and labeled instrumented; never compare its
CPU directly to untraced CPU. `output.csv` separates initial/update/exit and joins
run identity. Native `write`/`writev` return values on the **actual terminal fd**
define successful bytes/calls. Distinguish requested bytes, success, short writes,
failed/EINTR attempts and retries; PTY read chunks cannot count writes. Include
raw trace and phase-boundary evidence, tool version, fd identity, real terminal
host/version/capabilities/size and overhead limits. Synthetic PTY+TERM runs are
test facilities and cannot establish multiple real-host acceptance. Existing
M005 source confirms wait4/strace/SDK support and cjprof/NewArray8 limits; this
suite does not depend on or rerun those development probes.

The external process schema is:

```text
run_id,process_pid,executable,scope,instrumentation,cpu_user_us,cpu_system_us,wall_us,peak_rss_kib,exit_code,limitations
```

The native output summary schema is:

```text
run_id,phase,observer,target_fd,trace_path,host,host_version,width,height,capability_source,output_requested_bytes,output_success_bytes,output_success_calls,output_failed_calls,output_short_calls,limitations
```

`observer=native_write_returns`; each `trace_path` is a retained, phase-bounded
write/writev trace with the declared actual descriptor. The validator recomputes
all five output values from syscall returns. Use verbose iov_len records for
writev; an unfinished/resumed or truncated trace is explicitly insufficient for
this simple parser, not zero output. Keep the original complete trace plus exact
phase cuts so a filtered file alone cannot pretend to prove phase attribution.
Literal `.trace` files under `fixtures` are parser tests only, never measurements.

## Canonical method M013

1. **Mounted render state, factual source constraint:** startHeadless mounts but
   does not render. scrollTo/scrollBy clamp to last published viewportSnapshot;
   full mounted render uses commitGeometry=false, does not publish viewport/focus
   geometry or caret, and does not pump public posts. `Application.snapshot` does.
   A diagnostic render loop alone therefore cannot represent changing viewport
   bounds/root fallback/readonly caret fairly. Root ruling: PRIMARY headless cost
   uses the identical compat normal snapshot program against frozen old/new
   packages for all applicable workloads. Supplemental diagnostic render timing
   initializes once with a disclosed snapshot and supports only geometry- and
   caret-independent scenarios explicitly listed in `mode_matrix.csv`. Standalone
   m2-headless remains required for all non-idle stateful/caret scenarios, with
   actual snapshot costs and new counters but no fabricated global-render pair.
   Reject unsupported requests
   explicitly; no silent replacement or skipped workload. Keep stateful cases
   in full diagnostic correctness (snapshot then same-epoch render). Add common
   old/new **snapshot-headless** timings for the entire applicable matrix, with every
   snapshot cost inside the timed workload, and ordinary same-source TTY comparison.
   Do not compare the stateful diagnostic render subset as full workload CPU.
2. **TTY readiness/ack:** public Application.run renders before waiting for input;
   a second key callback can acknowledge a preceding event, as existing public
   harnesses do. A callback/post itself cannot claim its own frame is presented.
   Proposed sequence: action key; later fence key writes business ack via a side
   file and changes a dedicated fence row; observe its complete bytes. A subsequent
   key acknowledges that fence render. Keep fence-row work/output separately
   identified. For silent/glyph-equivalent events, no public onFrame callback exists;
   use the second-key ack, full raw phase bytes and ordinary input/render ordering.
   Output call counts still come exclusively from native trace, not fence reads.
3. **Already O(1) idle:** actual public input has no headless `processOneTurn` or
   pump API. Required idle is compat normal `Application.run` after warmup with no
   mutation, forced render, snapshot, export or stats polling inside the interval.
   Sample counters at its boundaries and real process CPU over a sufficient
   interval. Record actual poll CPU; do not claim zero CPU or unique M2 benefit.
   `snapshot-headless --scenario idle` and both diagnostic headless idle modes reject;
   smoke writes an explicit required-TTY-coverage marker. Repeated unchanged
   snapshot call cost, if separately reported later, cannot be labeled normal idle.
4. CLI spellings including the one opaque `--run-id` are canonical; report
   spellings remain derived from approved units. Binding M013 is `6bbf179e`.
   No implementation source-text assertion constrains internal layout. Source
   review by145 must establish actual counter instrumentation, no timed oracle/
   equality/hash/GC, and run-loop success/ack/phase ordering; CSV alone cannot.

## Eventual execution

After GO, `bash tests/rendering_benchmark/run.sh build` normally builds the test
validator and the three public projects. `run.sh smoke` checks the diagnostic
correctness matrix/Cell/caret outputs and separate headless modes, malformed CLI,
compat `not_available`, and direct binary status. It expects an artifact directory
argument and retains each command/output. `run.sh validate` can validate retained
reports without rebuilding. Old/new common-source compatibility and clean CJP
builds are explicit separate admission jobs with frozen dependency manifests;
this runner cannot silently skip them or call a new-only build old-M1 evidence.

```sh
bash tests/rendering_benchmark/run.sh build-tests
bash tests/rendering_benchmark/run.sh validate selftest tests/rendering_benchmark/fixtures
bash tests/rendering_benchmark/consume.sh OLD.cjp NEW.cjp /fresh/clean-consumption
bash tests/rendering_benchmark/run.sh smoke /clean/old-product old /fresh/old-results RUN_METADATA.csv
bash tests/rendering_benchmark/run.sh smoke /clean/new-product new /fresh/new-results RUN_METADATA.csv
bash tests/rendering_benchmark/run.sh compare /fresh/old-results /fresh/new-results
```

`consume.sh` unpacks actual ordinary archives, confirms delivered projects, copies
only final public compat/workloads into the older functional package if absent,
records equal common-source hashes and normally builds old common/new diagnostic
projects. It never borrows a development checkout, author dependency cache or probe.
The external caller supplies normal SDK/declared dependencies/official cache and
native build prerequisites; no test script silently patches them. A failed build
is failure, never skip. Product input/schema absence can be formal RED only after
the validator's own build/selftests succeed at GO. TTY, distributions, sufficient
duration and final actual bundle execution remain independent execution work;
smoke/headless success does not complete these obligations or TASK022/031.

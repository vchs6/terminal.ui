# Canonical M013 reconciliation and frozen windows

Binding authority: `6bbf179e` incremental-rendering design M013, rendering-benchmark
spec and tasks. This is source-only reconciliation of prepared `e0c9e47a`; D142
and root GO are still required for builds, selftests, RED and measurements.

## Per-scenario mode eligibility

`mode_matrix.csv` explicitly lists every scenario and every public mode. `required`
is not a passing result; `reject` means a nonzero request failure with no successful
sample, never silent skipping or replacement. Compat requirements apply to both
ordinary packages with identical common business source. Primary snapshot includes
every non-idle scenario, including gated posts and all preparation/return calls.
The supplemental paired comparison and m1-headless are restricted to the listed
fixed-geometry, caret-independent scenes. Standalone final-library m2-headless
supports every non-idle scenario to collect actual three-counter/slot costs,
including stateful/caret/first generation. The separate paired-comparison column
forbids inventing an M1 comparison for those standalone M2 rows. Every scenario
remains required in correctness and normal TTY. Idle correctness records are only
correctness/API observations; they do not measure normal-run idle.

Pair-eligible Text/Canvas panels have explicit fixed allocation, no requested caret,
no readonly viewport/focus dependence, no overlays, no deferred ensure/post, and
no fallback transition. Even `unicode_cells` has an explicit W×H root and W×1
leaf, so short text cannot change externally committed geometry. Ellipsis has a
fixed five-column leaf. Primary old/new snapshots still independently validate
these committed inputs. Excluded diagnostic requests are tested for both modes.

## Lifecycles, retention and counter windows

Steady snapshot and eligible diagnostic runs start one new Application per process,
mount once, explicitly initialize one snapshot, then execute the fixed warmup
actions using only that run's requested path. Initialization and warmup are outside
the inner wall/counter window and remain inside whole-process CPU/RSS. Never
initialize a second session/reference tree or prepare a snapshot per timed global
render. In primary compat, any action that requires a new public geometry commit
performs that snapshot inside its measured action; its complete cost is retained.
Gated post enqueue, normal snapshot pump and necessary business synchronization
are similarly included, without oracle/equality/hash. Standalone stateful
m2-headless uses this same normal snapshot lifecycle/preparation policy.

Across startup/warmup/measured iterations retain exactly the latest returned Frame
in one optional reference. During the next return, the previous Frame remains live
until assignment replaces it; do not accumulate history or release earlier in only
one version. Do not read/hash/export/mutate the retained Frame during timing. After
the ending samples, drop that reference, dispose Application once, then write the
report. Dispose and reporting are outside the inner window, inside process CPU.
Dropping a reference is not synchronous GC and no forced collection is requested.

`initial` is different: each measured update constructs a fresh root/Application,
starts, obtains its first snapshot, takes ending observations, drops its Frame and
disposes before the next fresh lifecycle. No initialization snapshot or prior
render is allowed in that measured lifecycle. Any requested warmup uses other fully
disposed lifecycles, never the measured instance. `lifecycles=updates`; work counts
are sums of actual per-lifecycle differences, not reset counters. State gauges are
the first lifecycle's pre-start and last lifecycle's pre-dispose observations, not
sums of mounted-node gauges. Initial inner wall is the sum of fresh root creation,
Application creation/start and first snapshot brackets. Precisely, bracket root/
Application creation, sample before start outside that bracket, then separately
bracket start/first snapshot and sample afterward. Ending sampling/disposal
between lifecycles remains whole-process overhead. First generation cannot be
removed as warmup or averaged into steady local workloads.

For each steady batch take `app.stats()` then the four SDK heap/freed/count/time
reads in that order before the window; take the same sequence after the loop.
The inner monotonic wall starts after the first sample block and ends before the
last block. `loop_wall_us` reports that actual interval; `sampling_wall_us` reports
the sum of the two separately clocked sample blocks, including their own small
clock overhead. Initial runs sum these brackets over fresh lifecycles. Samples
are non-atomic, allocate their own diagnostic objects and can straddle GC; raw
heap/GC values keep their actual scope and are never inferred total allocation.
No sampling-overhead estimate is subtracted from process CPU or measured slots.
`lifecycles`, `loop_wall_us`, `sampling_wall_us` are ordinary benchmark CSV facts,
not new product hooks/counters. Actual SDK clock signature must be compiled at GO.

External wait4 user/system/wall/peak RSS describe the whole child process, including
startup, all warmup, observation/report allocation, disposal and exit. They cannot
be relabeled inner-loop CPU. Performance runs are separate from correctness and
native tracing; measured workload duration/repeats and alternating order are fixed
before conclusions. Keep every repetition, distribution and all broad/negative data.

Normal idle uses compat `Application.run` only. Settle first target, capability/caret
probes and warmup before the beginning boundary. Take Stats before publishing a
business side-channel begin acknowledgement; during the idle interval send no
mutation, forced export or polling query. A later normal end event takes ending
Stats before stop/cleanup; boundary callbacks/acks remain outside the reported
idle interval. Do not change a fence row during idle. Whole-process CPU explicitly
includes setup/exit; an optional externally observed idle CPU subinterval must give
actual PID, sampling method/resolution and exact boundaries separately. No interval
CPU is derived by subtracting one different run. Work deltas are zero; polling CPU
is measured, never assumed zero or called an M2-only gain.

## Independent geometry and caret literals

The following fixed scenes use the empty-rule Theme and opaque default blank
background. `mixed(A)` is the eight explicitly enumerated Cells of `unicode_cells`;
`mixed(B)`/`mixed(C)`/`mixed(D)` replace only its first ASCII letter. All unlisted
Cells are default opaque spaces. These are hand-derived coordinate fixtures,
checked by the independent Cell/caret validators in each normal old/new snapshot
and both diagnostic correctness paths. The post-render caret read checks preservation,
not a second geometry/caret oracle.

| Scenario | Epoch | Independent screen/geometry expectation | Independent caret |
| --- | --- | --- | --- |
| root_fallback | 0 | Two fixed-height rows mixed(A), mixed(B), then blanks. Root viewport W×H, content height H, offset0. | hidden |
| root_fallback | 1 | Add H fixed-height mixed(C) rows. Visible A/B/C…; content height H+2, offset0. | hidden |
| root_fallback | 2 | Public root scrollTo(0,2). Every visible row is mixed(C); viewport W×H, offset2. | hidden |
| root_fallback | 3 | Restore two rows; offset clamps0; A/B then blanks. | hidden |
| viewport_caret | 0 | Header H at (0,0); W×2 ScrollView at y1; Canvas four rows mixed(A/B/C/D). Visible A/B; footer F at (0,3). | local(1,2) clipped; hidden |
| viewport_caret | 1 | Public scrollTo(0,1); visible B/C at y1/y2; content height4, offset1. | visible(1,2), owner viewport_caret |
| viewport_caret | 2 | Width W/2, height H; viewport width W/2, height2, content height4, offset1; B/C remain y1/y2. | visible(1,2), same owner |
| viewport_caret | 3 | Restore width W and offset0; A/B at y1/y2. Wrapper nonfocusable, Canvas focusable. | hidden |
| readonly_focus_caret | 0 | Blank W×1 Canvases at y0/y1, mixed(A) at y2; first Canvas focused. | visible(1,0), owner focus_first |
| readonly_focus_caret | 1 | Focus second; complete grid unchanged. | visible(2,1), owner focus_second |
| readonly_focus_caret | 2/3 | Focus/retain first; complete grid unchanged. | visible(1,0), owner focus_first |

Owners are stable business names resolved against actual public references via
`sameNode`/`isValid` in the business fixture. Cross-session internal node IDs or
addresses must not be exported as owner identity. Readonly viewport values above
are checked in workload correctness; independently exported full Cell positions
and manual caret coordinates remain the test-side geometry checks. Fixed-source
145 review must trace those public observations, actual counters and timing
boundaries; output labels alone cannot prove correct implementation.

Focus Canvases request their listed local caret only while their actual public
reference reports `isFocused()`. The viewport Canvas is explicitly focused and
its ScrollView wrapper is nonfocusable. Header/footer and each ordinary row have
their literal fixed one-row allocations; the viewport has exactly two screen rows.

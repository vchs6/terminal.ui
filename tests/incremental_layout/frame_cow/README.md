# Frame public consumer (TASK-128 / Unit B)

Execution of the approved incremental-rendering design sections 7/8, final M002/M003,
TASK128–132, and frozen R11/F003. No production changes or new design gate.
This ordinary SDK/CJPM 1.2 executable depends on public `cjtui` through the normal
build hook. The nine existing Unit A cases and their assertions are unchanged.
Each new entity has its own lowercase source file; helpers are pure functions.

Use these settings in every build/runtime shell:

```sh
source /workspace/work/validation/sdk/cangjie/envsetup.sh
export CANGJIE_STDX_PATH=/workspace/work/linux-build-recon/stdx-env
export CJTUI_UCD_ARCHIVE=/workspace/work/validation/replay-dependencies/UCD-17.0.0.zip
bash tests/incremental_layout/frame_cow/run.sh baseline
bash tests/incremental_layout/frame_cow/run.sh cow
```

Root and consumer ignored `cangjie-repo.toml` use the official registry
`https://pkg.cangjie-lang.cn/registry` and existing read cache
`/workspace/work/viewport-tests/cache`. No SDK/cache or config override is shipped.
For independent evidence, build once in this consumer, then directly execute
`target/release/bin/main baseline` and `target/release/bin/main cow`, each with
`ulimit -v 16777216` (KiB). Capture actual process statuses separately.

`baseline` runs all seven cases, observing real slot counts without requiring
COW. `cow` runs identical correctness/ownership cases and finally requires both
unchanged complete App snapshots to allocate zero new Cell slots. The scene is
8×3; snapshot two/three share width, Unicode glyph mode, and business epoch with
the first. `frames` staying unchanged confirms the cached-target path. Slot
deltas come directly from the actual readonly public counter, never dimensions
substituted for allocation counts. The 24-cell full-reference lower bound comes
from its required new target. Changed-generation counts are observations only.
No CPU, row-layout, exact temporary-allocation, heap-byte, or timing claim is made.
External first/repeated/same-row/other-row writes and copy/resize must add no App
counts, and retained snapshots remain independent across a later app generation.

## Hand oracles and mutations caught

| Case | Literal derivation and break caught |
| --- | --- |
| Aliases | A at 0, 中 lead/continuation at 1/2, e+combining at 3. Mutating either side, a second-generation copy, and resize siblings catches omitted detach and partner repair. Full raw Style and transparency are checked. |
| Write entrances | Literal 5×3 abcde/fghij/klmno grid. String and RichText/ANSI put, inherited/overridden span style, fill, clear, border, shadow branches independently mutate; later source mutation must leave each branch unchanged. |
| Opacity/compose | ABC under X/hole/Z gives XBZ; replacing hole with opaque styled space gives X-space-Z. Expansion uses source default opacity. Sibling and overlapping left/right self-composition read the starting source. |
| Unicode/resize | A, 中(2), woman-technologist ZWJ(2), e+combining(1), Z fill seven columns. Clipping either half yields styled single-column spaces. Tests cover negative offset, partner repair, right-edge omission, changed width, out-of-source copy, ambiguous-width/default-opacity/budget metadata. |
| Zero axes | Both `(0, Int64.Max)` and `(Int64.Max, 0)` plus copy/resize retain dimensions, width policy, default opacity, and budget without traversing/allocating virtual axes. Finite zero-width text keeps two LF for height 3. Address-space cap contains erroneous huge allocation; it is no performance assertion. |
| ANSI | Handwritten CUP/SGR full snapshots: reset, row position, red A/default 中, final reset. Monochrome removes red; re-export, old-copy edits, and wide partner overwrite catch stale content/style projection. |
| Allocation | Actual App counter deltas; same-epoch unchanged full snapshot must share existing Cell storage under COW. Caller-owned returned render/snapshot edits cannot charge App or corrupt cached target. |

The public API names are `Frame.copy` and `Frame.resized`; there is no assumed
`clone`, private identity/address/hash observation, test hook, forced product
mode, or generated expected visual output.

## Mandatory backend boundary (TASK130/131)

`TerminalRenderProfile` and `changesSinceForTerminal` are package-private.
This consumer tests public complete ANSI exports across color modes and old,
unrelated, caller-mutated Frames. It cannot submit an arbitrary old Frame to the
terminal diff API. That obligation remains mandatory in TASK130 source review:
row identity only with compatible profile; arbitrary/unrelated old versions,
external mutation, missing lineage, and dimension/profile changes use a correct
fallback; output baseline commits only after successful writes.
TASK131 must execute the existing `tests/output_recovery/run.sh` / `run.mjs`
public Application/native-fault frontdoor (`src/live.cj`, `native/output_fault.c`),
including normal, supplement resize/profile, short write/EINTR, and fatal cuts;
also run affected frozen R11/F003 and snapshot/output consumers. That harness
covers observable device correctness and failure fences; it does not expose an
arbitrary-old-Frame injection API. No private coverage is claimed here, and this
test-author run is not independent execution/acceptance, full M2, or Linux closure.

## Author baseline observation

On accepted Unit A `0f83f73d0268b30b429f3f7482f4c9d1031b5006`, normal CJPM
build exits 0. Direct `baseline` exits 0 (seven cases); direct `cow` exits 1
with only the zero-new-slot assertion failing. The actual cached-snapshot
deltas are 48 and 48 slots; changed-generation delta is 72, full reference 24.
These counts are baseline measurements; the COW oracle remains zero newly
allocated Cell slots for the two unchanged full snapshots. Zero-axis cases pass
under the documented 16 GiB process address-space cap. The existing nine Unit A
cases reuse accepted A126 execution evidence after byte-identity verification;
this delivery does not replace independent TASK131 execution.

## ADDED Requirements

### Requirement: Public benchmarks are normal independently consumable projects

benchmarks/rendering SHALL be an ordinary CJPM project using only public product APIs and declared dependencies. The production library MUST NOT expose a benchmark-specific mode, reset hook, private diff method or alternate renderer. Complete M1 baseline artifacts SHALL be frozen after all required functionality and before M2 implementation.

#### Scenario: Headless and actual-terminal comparisons
- **WHEN** the benchmark measures headless M1 and M2
- **THEN** it uses public global render and Application.snapshot with equivalent business inputs
- **AND WHEN** terminal comparisons are reported
- **THEN** the same benchmark source is normally built against fixed complete M1 and M2 packages, with real host/configuration evidence and no production mode toggle.

#### Scenario: Clean product consumption
- **WHEN** the product archive is unpacked in a clean directory
- **THEN** the benchmark builds and runs through its ordinary CJPM manifest without development paths, author caches, GUI/JS or terminal-emulator runtime dependencies.

### Requirement: Correctness and timing measure matching states independently

Correctness pairing SHALL compare full structured frames after a controlled public batch with external producers gated at a common business epoch. Timing SHALL run separately without M1 oracle, full equality or frame hashing in the M2 measurement window.

#### Scenario: Concurrent updates are controlled for pairing
- **WHEN** a workload uses posted state, theme completion or other background producers
- **THEN** business-level barriers prevent different API cutoffs from producing a false M1/M2 mismatch
- **AND** no production runtime freeze hook is added.

#### Scenario: Oracle allocation does not pollute M2 timing
- **WHEN** CPU and allocation effects are compared
- **THEN** M1/M2 are measured in separate processes with identical workloads, documented warmup/optimization/runtime settings and repeated runs
- **AND** truthful M1 statistics are retained in correctness runs rather than reset or hidden.

### Requirement: Cost evidence states scope and covers sparse and broad updates

Reports SHALL include work deltas, real process CPU, scoped Cell-storage allocations, SDK heap/GC metrics, process memory and successful output bytes/calls. The allocation field SHALL be named frame_allocated_cell_slots and MUST NOT be presented as bytes or total heap allocations. No arbitrary FPS or speedup threshold is required, but local workloads MUST demonstrate actual reduced unrelated work and assess corresponding total costs.

#### Scenario: Required workload matrix
- **WHEN** the benchmark runs its required matrix
- **THEN** it includes at least 80x24 and 160x48, Chinese/combining/emoji text, color-only, long/short text, sizes/wrap, batch changes, keyed/manual structure, theme, scrolling and moved/nested layers
- **AND** it separately reports initial generation, already-O(1)-idle, same-row multi-column costs, large-area changes and full resize/theme degradation.

#### Scenario: Measurement tools have limited coverage
- **WHEN** CPU sampling is denied or an external allocator observer misses inlined allocations
- **THEN** reports state the precise failure/coverage, use valid scoped diagnostics and process CPU methods, and never label occupancy/RSS/slowpath counts as total allocated bytes
- **AND** missing optional profiler permissions do not become an invented requirement to rewrite the runtime.

#### Scenario: Results are reproducible and complete
- **WHEN** a performance conclusion is published
- **THEN** it includes exact source/artifact/dependency/SDK hashes, OS/CPU/terminal/size/capability configuration, workload seed/actions, all repeated raw results and distributions
- **AND** output trace instrumentation is separated from undisturbed CPU timing, negative/global results are retained, and counts alone do not imply overall performance improvement.

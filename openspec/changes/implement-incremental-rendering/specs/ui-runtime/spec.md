## ADDED Requirements

### Requirement: Local invalidation uses the existing runtime and layout kernel

The runtime SHALL maintain Content, Style, Layout and Structure invalidation on the existing RuntimeNode identity and committed child sequence. M2 SHALL reuse valid bounded measure/arrange results, propagate constraint and placement dependencies, and avoid unrelated layout work. Ordinary construction, binding, batch, notify and lifecycle APIs MUST retain their contracts.

#### Scenario: Paint-only output changes
- **WHEN** a node's effective color, RichText span-only style, or Canvas draw-only dependency changes
- **THEN** M2 repaints affected rows and actual inherited dependents without measuring or arranging unrelated nodes, including constant setters and manual notifications
- **AND** equal typed results update dependency subscriptions without manufacturing new visual change.

#### Scenario: Constraint changes move dependent siblings
- **WHEN** Row flex allocation, Column child height, four-side padding, viewport width or wrap changes
- **THEN** the shared layout algorithm recalculates affected allocations and constrained measurements, updates dependent positions/clips, and reuses unrelated results
- **AND** width-zero/overwide grapheme behavior follows the frozen theme layout contract.

#### Scenario: Structure preserves identity and invalidates geometry
- **WHEN** If/ForEach or manual operations commit key movement, insertions, removal or visibility changes
- **THEN** M2 consumes the single committed sequence, retains surviving identity and valid content caches, and damages old/new visible bounds
- **AND** hidden deferred invalidation is retained until needed, while removed nodes do not remain alive merely for damage cleanup.

### Requirement: Full reference rendering is isolated from incremental caches

Global render SHALL remain the complete M1 reference using the same algorithms and an independent temporary result table. It MUST NOT read or publish M2 layout/paint caches, consume M2 dirtiness through reference computation, alter persistent Canvas dependencies, or run extra lifecycle effects. Normal entry binding stabilization and truthful public statistics remain in force.

#### Scenario: Paired frames at a stable business epoch
- **WHEN** a public benchmark stabilizes one deterministic batch and prevents further external state writes during snapshot/render pairing
- **THEN** M2 and M1 agree on width, height and every Cell grapheme, width, continuation, raw Style and transparency
- **AND** M1 computation records its real work without clearing or warming M2 caches.

#### Scenario: Mounted root and detached root
- **WHEN** render receives a mounted application root
- **THEN** it consumes the same session's committed viewport/offset/visible layer stack as snapshot, including the implicit Vertical overflow fallback, without creating a second session
- **AND WHEN** the root is detached
- **THEN** temporary runtime mode does not create an Application implicit root viewport or lifecycle effects.

### Requirement: Runtime diagnostics report actual work and bounded allocation scope

RuntimeStats SHALL retain the original eight counters' meanings and add read-only Int64 arranges, cellWrites and frameAllocatedCells. Counters SHALL reflect actual owned work, reset on new session only, and retain final cumulative values after disposal. Statistics queries MUST NOT pump, render or silently reset counters.

#### Scenario: Shared rows and actual storage allocation
- **WHEN** target generation or returned snapshot allocates Cell storage
- **THEN** frameAllocatedCells increases by successfully allocated Cell slot capacity at the allocation site, including needed scratch storage
- **AND** sharing existing rows adds zero slots; garbage collection does not subtract from the cumulative value.

#### Scenario: User modifies a saved snapshot
- **WHEN** the caller later changes its independently mutable Frame snapshot outside application generation
- **THEN** the owning Application counters do not increase
- **AND** this mutation cannot affect cached targets or previously saved snapshots.

#### Scenario: Full reference costs remain visible
- **WHEN** global render computes a complete frame for a mounted session
- **THEN** its actual measure, arrange, paint, frame, Cell writes and Cell storage allocations increase the same session counters
- **AND** benchmarks separate reference correctness runs from M2 timing rather than hiding costs by counter resets.

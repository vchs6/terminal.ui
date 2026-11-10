## ADDED Requirements

### Requirement: Incremental targets remain complete and composition-equivalent

M2 SHALL retain a complete target Frame while using full-row damage derived from old and new paint bounds. It MUST clear stale contents and redraw all intersecting nodes and layers in normal scene order, with the existing Frame/Unicode/Style kernel and original user-visible PaintContext allocation and clip.

#### Scenario: Moved or removed content reveals current lower layers
- **WHEN** text shortens, a node moves/hides/unmounts, a shadow changes, or a parent modal closes attached layers
- **THEN** old and new affected rows are rebuilt from current lower-layer state through all intersecting upper layers
- **AND** opaque StyledSpace and shadows cover, while transparent holes pass through according to F003.

#### Scenario: Grapheme partners and clipping
- **WHEN** local clearing, drawing or composition touches a wide-cluster continuation or clips a source cluster
- **THEN** existing R11/F003 whole-cluster rules remain valid, including partner cells outside the original geometric operation
- **AND** full-row damage introduces no artificial horizontal clip, no orphan continuation and no second Unicode algorithm.

#### Scenario: Controlled draw context remains stable
- **WHEN** only some rows intersect a Canvas
- **THEN** its callback sees the original allocation, viewport clip and styles, runs at most once for that target generation, and writes through the same bounded Frame kernel
- **AND** damage filtering does not become a new user-observable layout constraint.

### Requirement: Frame sharing preserves independent mutation

Frame SHALL use private immutable shared storage only when source/target semantics permit. Public copy, resized, subrect composition, clear and exports MUST retain existing policy, transparency, budgets and independent mutation behavior.

#### Scenario: Copy and self-composition
- **WHEN** a full snapshot shares frozen rows and either Frame later writes
- **THEN** the changed row detaches before any Cell or partner write
- **AND** overlapping self-composition reads its operation-start source image.

#### Scenario: Zero-area large virtual axis
- **WHEN** Frame has zero area with a legal extreme other axis
- **THEN** storage does not allocate or iterate a giant row directory
- **AND** existing validation, short-circuit and plain-text export budget semantics remain unchanged.

### Requirement: Damage optimization never substitutes for display synchronization

The backend SHALL commit frame/profile/size/caret baseline only after all required output succeeds. Row identity or damage hints MAY skip work only with exact immutable content and valid baseline relationship; arbitrary unrelated Frame comparisons MUST remain correct through complete fallback. Hashes alone MUST NOT prove equality.

#### Scenario: Unrelated baseline or profile change
- **WHEN** the supplied old Frame is unrelated, externally mutated, missing exact lineage, or terminal projection differs
- **THEN** the backend compares every unproved row correctly and does not discard damage based on a stale target token.

#### Scenario: Partial write or resize
- **WHEN** output fails partially or display synchronization becomes invalid
- **THEN** shared rows and clean compute caches cannot skip TASK-008 recovery/full resynchronization or its required stop/error behavior
- **AND** no unshown target is recorded as successfully displayed.

#### Scenario: Caret-only changes
- **WHEN** the logical caret changes while grid cells remain equal
- **THEN** required caret controls are still emitted and committed only after success
- **AND** cached requests obey focused owner, clipping, viewport and actual opaque layer coverage, including same-character StyledSpace coverage.

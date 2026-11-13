## ADDED Requirements

### Requirement: Persistent declarative construction
The framework SHALL materialize each component instance once, retain mounted identity, and invalidate references and subscriptions on unmount. Native Cangjie macros SHALL preserve typed component blocks, properties and callbacks without a second language runtime.

#### Scenario: Repeated updates retain construction
- **WHEN** a mounted component's bound text changes repeatedly
- **THEN** build executes once and the current rendered text reflects each accepted change

### Requirement: Scheduled targeted updates
The framework SHALL track observable reads, coalesce invalidation, and execute all UI callbacks on the owning UI session. Explicit notifications SHALL reevaluate stored getters of the selected category.

#### Scenario: Background update and teardown
- **WHEN** a background task changes shared state and its view is subsequently disposed
- **THEN** UI evaluation occurs only at its UI boundary and disposed references and queued owner work cannot affect a later mount

### Requirement: Unified child sequence
The framework SHALL combine declared and manually inserted children in one committed sequence using the slot reconciliation contract in design.md.

#### Scenario: Reorder around a manual child
- **WHEN** A X B C contains declared A/B/C and manual X, then the data changes to C/B/A
- **THEN** the sequence is C X B A and surviving keys retain identity

## ADDED Requirements

### Requirement: Independent glyph delivery and bounded acceptance
The glyph sub-interface SHALL be delivered through independent test-design, product, review, execution and acceptance roles TASK-093 through TASK-097, tracking parent TASK-041. Product implementation SHALL consume fixed accepted runtime080 and richtext084 inputs and SHALL precede theme product implementation without changing frozen theme085 public APIs. Limited glyph acceptance SHALL NOT close full AC-041 or claim complete ellipsis layout before Theme013 and its independent tests and acceptance.

#### Scenario: Fixed role handoff
- **WHEN** test design, product implementation, review, execution or acceptance changes role
- **THEN** the next role receives fixed contract and source/test artifacts with reproducible commands, rather than author reasoning or a preselected passing conclusion

#### Scenario: Real Linux VT evidence
- **WHEN** glyph behavior is reported as verified on Linux VT
- **THEN** evidence includes the actual implementation and viewport, permissions and font mapping source, tested source hash, raw logs and actual PNG with hash; changing TERM inside the same PTY does not qualify as another terminal implementation

#### Scenario: Full Linux acceptance remains pending
- **WHEN** TASK-097 accepts only glyph projection, diagnostics, device diff and marker-policy interfaces
- **THEN** remaining full input, size, recovery, all-component, M2, artifact and host scenarios remain tracked under the original full AC-041 and subsequent integration tasks

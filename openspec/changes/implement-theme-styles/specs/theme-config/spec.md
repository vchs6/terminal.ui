## ADDED Requirements

### Requirement: Typed per-property style resolution
The framework SHALL resolve each property using explicit component declarations, ordered reusable styles, the active theme, and defaults, with the state and reset rules in design.md.

#### Scenario: Reset and inheritance
- **WHEN** a child explicitly resets its foreground while its parent provides a text color
- **THEN** the child uses the framework default and does not inherit the parent color

### Requirement: Bounded transactional theme loading
The framework SHALL parse the closed TOML schema through the selected upstream lexer/parser and SHALL retain the accepted theme when a candidate fails. Only the latest requested candidate may commit at a safe UI boundary.

#### Scenario: Latest request fails
- **WHEN** an older legal request finishes after a newer invalid request
- **THEN** the newer request fails, the older request remains superseded, and the previously accepted theme remains active

### Requirement: Theme changes preserve view state
The framework SHALL apply theme changes without rebuilding mounted component identities, business values or interaction state.

#### Scenario: Spacing reload
- **WHEN** the application explicitly reloads a file changing spacing and colors
- **THEN** the view is laid out and repainted with one accepted theme version while node identities remain stable

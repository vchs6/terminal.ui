## ADDED Requirements

### Requirement: Explicit structured rich text
The framework SHALL render RichText through the existing Component/LayoutNode/Frame path and SHALL segment the concatenated text into grapheme clusters before applying span styles.

#### Scenario: Style boundary inside a cluster
- **WHEN** a span boundary separates a base character from its combining mark
- **THEN** the text remains one cluster and uses its first scalar's span style

### Requirement: Bounded ANSI text adaptation
The framework SHALL only interpret the supported SGR whitelist and SHALL discard device controls using bounded incremental parsing without forwarding source control bytes.

#### Scenario: Oversized unterminated control string
- **WHEN** an OSC or DCS payload exceeds the configured bound
- **THEN** the decoder discards it until its legitimate terminator and never treats its remaining payload as visible text

#### Scenario: Split UTF-8 and C1
- **WHEN** valid text or a supported control is split at any byte boundary
- **THEN** the normalized text, styles and diagnostic offsets equal the unsplit result

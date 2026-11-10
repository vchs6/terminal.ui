## ADDED Requirements

### Requirement: Bounded frame composition primitives

The framework SHALL distinguish transparent cells from opaque styled spaces and provide bounded clipping, copying, clearing, resizing, and ordered composition through the existing character frame.

#### Scenario: Transparent overlay and opaque space
- **WHEN** a transparent layer and an opaque styled space are composed over an existing frame
- **THEN** transparent cells preserve the lower content while the opaque space covers it, and all wide grapheme cells remain complete

#### Scenario: Complete independent file snapshot
- **WHEN** an application exports a composed frame as plain text or ANSI
- **THEN** the file contains a complete UTF-8 snapshot independent of terminal history and any file failure is reported

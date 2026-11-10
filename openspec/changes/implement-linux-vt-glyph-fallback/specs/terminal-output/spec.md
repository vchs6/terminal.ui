## ADDED Requirements

### Requirement: Automatic glyph adaptation preserves logical text
The framework SHALL provide optional GlyphMode.Auto, Unicode, and Ascii; normal Application construction SHALL default to Auto. Device glyph projection SHALL preserve the original logical Frame, business Unicode, grapheme widths and continuation integrity. A known missing or unsupported positive-width cluster SHALL be replaced with printable ASCII occupying exactly its original display columns; the framework SHALL NOT claim to recover unavailable human text meaning.

#### Scenario: Known VT missing wide cluster
- **WHEN** Auto runs on a confirmed Linux text VT and a two-column cluster lacks a proven supported representation
- **THEN** device output uses two ASCII placeholder columns, while logical text and default file exports retain the original cluster

#### Scenario: Unknown emulator coverage
- **WHEN** the actual output device is a PTY or glyph coverage cannot be identified as a concrete Linux text VT
- **THEN** Auto retains Unicode output and reports coverage unknown without treating TERM or terminfo as font coverage evidence

#### Scenario: Explicit advanced override
- **WHEN** the application selects Unicode or Ascii through the optional constructor parameter or glyphMode setter
- **THEN** the selected mode determines device projection without altering raw detected capability facts or requiring normal applications to select a mode

### Requirement: Bounded read-only Linux VT mapping
The framework SHALL probe the actual output fd using read-only native device and text-VT queries and SHALL read at most 65535 unipair entries in one GIO_UNIMAP allocation/read. It SHALL expose a read-only diagnostic snapshot without exposing the bitmap as a normal application requirement. Probe failures SHALL NOT elevate permissions, load fonts, mutate console decoding modes, scan another VT, or claim complete support.

#### Scenario: Confirmed text VT map is unavailable
- **WHEN** the actual stdout fd has been confirmed as a concrete Linux text VT and GIO_UNIMAP fails with a permission or allocation error
- **THEN** Auto uses conservative ASCII projection and preserves a diagnostic source, reason and native error

#### Scenario: Aliased or non-VT output
- **WHEN** stdout is a console alias that the bounded probe cannot bind to a concrete text VT, or a PTY
- **THEN** the probe reports unknown and does not open a different console or infer a font from environment variables

#### Scenario: BMP map is not shaping proof
- **WHEN** a map includes component scalars of a multi-scalar cluster, or cannot represent a non-BMP scalar
- **THEN** Auto on the known VT conservatively replaces the whole cluster and does not infer combining, VS, ZWJ or emoji shaping support

#### Scenario: Successful empty map
- **WHEN** GIO_UNIMAP succeeds with zero entries
- **THEN** diagnostics record a known empty BMP map rather than universal coverage

### Requirement: Projected device equality suppresses output
The framework SHALL compare the previous successful logical Frame with its previous profile against the current logical Frame with its current profile using the same canonical device projection used by encoding. Equal projected rows SHALL produce no screen update even when raw grapheme or continuation representation differs. A mode change SHALL invalidate affected layout/profile work without committing a new baseline before complete output success.

#### Scenario: Different logical clusters have identical placeholders
- **WHEN** a two-column Chinese cluster changes to another such cluster or to two ASCII question marks and both device projections and effective styles are equal
- **THEN** no screen update bytes are emitted for the unchanged projected row

#### Scenario: Mode changes while no content binding is dirty
- **WHEN** glyphMode changes in the existing supported UI execution domain
- **THEN** the next safe refresh reevaluates the profile and layout policy, uses old and new profiles independently for comparison, and emits only changed projected output

### Requirement: Generated markers use layout policy before clipping
The framework SHALL provide the single layout path with a glyph policy and production marker selector. Generated ellipsis SHALL be selected using the actual layout ambiguous-width policy before prefix budgeting: U+2026 is eligible only when it occupies one column; otherwise ASCII uses up to three dots. Literal U+2026 device projection SHALL preserve its original span. Theme013 SHALL own actual prefix selection and ellipsis layout.

#### Scenario: ASCII marker changes the prefix budget
- **WHEN** ellipsis text layout is implemented under the existing Theme013 contract and a truncated ASCII source abcdef has five content columns with explicit Ascii layout policy
- **THEN** it lays out ab... using a three-column marker budget rather than laying out abcd… and expanding it during device encoding

#### Scenario: Ambiguous-wide ellipsis uses the real width policy
- **WHEN** the layout uses ambiguousWide=true and U+2026 therefore occupies two display columns
- **THEN** marker selection uses ASCII dots and reserves their actual columns without treating U+2026 as one column or changing the global width policy

#### Scenario: Marker-only interface precedes text overflow product
- **WHEN** the glyph sub-interface is accepted before Theme013 implements TextOverflow
- **THEN** acceptance covers policy transport and the real marker selection function but records complete ellipsis prefix layout as pending Theme013, its added 085 tests and 088 acceptance

### Requirement: Offline rendering is independent from device font evidence
Application.snapshot and the top-level render function SHALL accept an optional explicit glyphMode parameter defaulting to Unicode. Offline Auto SHALL resolve as Unicode without probing or reading prior device capabilities. Ascii offline policy SHALL select framework-generated ASCII markers while preserving business Unicode in the logical Frame. Default Frame plain and ANSI exports SHALL retain logical Unicode and existing color snapshot semantics.

#### Scenario: Device ASCII does not change default offline snapshot
- **WHEN** an Application uses Ascii for its device run and the caller invokes snapshot without a glyphMode argument
- **THEN** the snapshot uses offline Unicode generation semantics and its default plain or ANSI export retains business Unicode

#### Scenario: Explicit headless ASCII policy
- **WHEN** the caller explicitly requests Ascii in snapshot or render
- **THEN** generated marker selection uses ASCII policy with correct column budgeting while original Chinese, combining and emoji text remains logical Unicode

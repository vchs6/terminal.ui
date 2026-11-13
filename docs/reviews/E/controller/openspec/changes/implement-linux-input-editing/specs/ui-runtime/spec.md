## ADDED Requirements

### Requirement: One normalized keyboard event stream
The framework SHALL normalize the documented Linux keyboard sequences into the existing KeyEvent code/text contract with immutable ctrl, alt and shift fields, SHALL retain interrupt compatibility, and SHALL route all resulting events through the existing Runtime UIKeyEvent path.

#### Scenario: Shift navigation and a legacy interrupt event
- **WHEN** the device supplies CSI 1;2 D and a public consumer separately dispatches KeyEvent("interrupt") without modifier arguments
- **THEN** the first event is left with shift=true
- **AND** the legacy interrupt event retains the existing preventable exit default and does not reach the old onKey callback

#### Scenario: A protocol cannot distinguish a physical modifier
- **WHEN** the input is HT, BS, LF, CR or an ordinary uppercase printable character
- **THEN** the framework preserves its documented logical-key or text meaning and does not invent a physical Shift/Ctrl distinction absent from the protocol

### Requirement: Bounded incremental keyboard decoding
The framework SHALL decode valid UTF-8 and recognized sequences across arbitrary byte boundaries using one bounded state machine, SHALL document unknown and malformed input disposal, and SHALL not release discarded control payload as text or shortcut events.

#### Scenario: Chunk-independent UTF-8 and navigation
- **WHEN** the same valid input and the same timeout boundaries are supplied whole or split at any byte
- **THEN** normalized events and diagnostic kind/offset pairs are equivalent

#### Scenario: Oversized or unterminated control input
- **WHEN** a sequence exceeds maxSequenceBytes or a control string remains unterminated
- **THEN** decoder state remains bounded and the sequence's remaining payload is discarded until its documented boundary
- **AND** a control-string timeout does not release its payload as ordinary text

#### Scenario: Bare escape versus incomplete navigation
- **WHEN** input has been idle for 100ms after a bare ESC or an incomplete CSI
- **THEN** the bare ESC becomes one escape event and the incomplete CSI is discarded with IncompleteInput

### Requirement: Atomic bracketed paste with target ownership
The framework SHALL treat the exact seven-bit bracketed paste frame as one data event, SHALL capture the active target and input domain at its start, and SHALL never execute payload newlines, ESC or CtrlC bytes as business shortcuts. It SHALL accept at most maxPasteBytes payload bytes per paste, defaulting to 1048576 bytes, and SHALL discard the whole overlimit paste while remaining in drain until its exact end delimiter or session termination.

#### Scenario: Multiblock control-containing paste
- **WHEN** paste delimiters, UTF-8 and payload newlines or 0x03 are split across device reads
- **THEN** no partial text, enter or interrupt event is dispatched
- **AND** only a complete valid UTF-8 payload can become one paste event for the original valid target

#### Scenario: Focus changes during paste
- **WHEN** paste starts at target A and focus moves to B while A remains mounted and permitted in the same active input domain
- **THEN** the completed paste remains assigned to A and is not redirected to B

#### Scenario: Original target becomes unavailable
- **WHEN** the captured target unmounts, becomes hidden or disabled, or is isolated by a new modal domain
- **THEN** the entire paste is discarded with PasteTargetUnavailable
- **AND** it is not redirected to another node or the application shortcut handler

#### Scenario: Boundary and overflow
- **WHEN** a valid payload contains exactly the configured byte limit
- **THEN** it can produce one complete paste event
- **WHEN** the next payload byte exceeds that limit
- **THEN** the decoder discards the entire transaction, reports PasteTooLarge once, and does not reinterpret later payload as commands

#### Scenario: Idle incomplete paste
- **WHEN** the stream has started paste and multiple 100ms polls contain no bytes
- **THEN** the framework retains isolation without submitting any prefix
- **AND** UI posts, resize handling and external stop remain serviceable

### Requirement: EOF, process interruption and device recovery are distinct
The Linux adapter SHALL distinguish no data, EOF, read failure and external interruption, SHALL drain readable tail bytes before HUP termination, and SHALL close the session through its existing recovery boundary.

#### Scenario: EOF with incomplete paste
- **WHEN** EOF arrives before the closing delimiter
- **THEN** no partial paste is committed, IncompletePaste is reported, and the session exits through mode/termios cleanup

#### Scenario: External termination during paste
- **WHEN** SIGINT, SIGTERM or Application.stop terminates a session while paste or drain is active
- **THEN** pending payload and target handles are released without an editing callback
- **AND** termination is not blocked by treating the process control as a preventable keyboard event

#### Scenario: Large input while a post is pending
- **WHEN** a device read contains more than the per-turn input budget and a UI post is ready
- **THEN** decoding yields at the documented 4096-byte budget and the UI turn services queued work without reordering the input stream

### Requirement: Public single-line and multiline editors
The framework SHALL provide TextInput and TextArea through the same public Canvas, focus, default-action, theme and viewport primitives available to user components, without an editor-specific renderer or Unicode implementation.

#### Scenario: A normal public consumer
- **WHEN** an application binds an Observable<String> to TextInput or TextArea using only documented imports
- **THEN** it can edit the value without coordinates, manual refresh, private runtime access or direct terminal output

#### Scenario: Enter default and interception
- **WHEN** Enter reaches TextInput without preventDefault
- **THEN** onSubmit runs once and does not modify the text
- **WHEN** Enter reaches TextArea without preventDefault
- **THEN** it replaces the selection with LF
- **AND** an earlier preventDefault prevents either default action

### Requirement: Grapheme-safe selection and editing
The framework SHALL interpret caret and anchor as whole-text grapheme boundaries, SHALL resegment edits at their new concatenation boundaries using the existing Unicode adapter, and SHALL not use byte or rune counts as character positions.

#### Scenario: A combining mark arrives after its base
- **WHEN** a text event inserts a combining mark adjacent to an existing base character
- **THEN** selection/caret are snapped to valid boundaries of the newly combined cluster and one subsequent Backspace removes the complete cluster

#### Scenario: Emoji selection crosses a visual boundary
- **WHEN** a selection includes a ZWJ emoji, regional-indicator pair or a wide CJK cluster partly outside the viewport
- **THEN** deletion and copied logical text include complete clusters independent of the clipped display

### Requirement: Atomic input validation and bounded history
The framework SHALL validate an entire paste before replacing a selection, SHALL reject multiline paste into TextInput without submission, and SHALL retain bounded whole undo records for accepted editing actions.

#### Scenario: Invalid single-line paste
- **WHEN** a complete paste contains a newline, forbidden control or overlimit text for TextInput
- **THEN** text, selection and undo/redo history remain unchanged and the corresponding edit issue is reported
- **AND** onSubmit does not run

#### Scenario: One paste is one undo transaction
- **WHEN** valid multiline paste replaces a selection in TextArea
- **THEN** one undo restores the previous complete text and selection, and redo restores the accepted replacement

#### Scenario: An external value replaces local history
- **WHEN** the bound value is externally set or notified, including a supported background Observable write
- **THEN** the view advances its revision, invalidates earlier captured cut intent, clamps selection and clears local undo/redo without changing another view's caret

#### Scenario: A background write races an edit
- **WHEN** an allowed background Observable write changes the actual source version between an editor's atomic read and conditional commit
- **THEN** the editor does not overwrite that newer source with its stale computed edit
- **AND** it reports ConcurrentValueChanged without adding a successful local undo transaction or onChange callback

### Requirement: Standard keyboard editing and routing defaults
The framework SHALL implement the documented navigation, selection, deletion, select-all, undo/redo and copy/cut bindings at Target default phase, SHALL respect earlier preventDefault, and SHALL leave framework Tab/Escape behavior available when the editor has no matching default.

#### Scenario: Propagation stop is not default prevention
- **WHEN** a user handler calls stopPropagation without preventDefault for an editable text key
- **THEN** that event's editor default can still run once
- **WHEN** the handler calls preventDefault
- **THEN** the editor does not modify text

#### Scenario: No double scrolling
- **WHEN** TextArea handles PageDown inside a ScrollView
- **THEN** it consumes that default action and the ancestor viewport does not also scroll from the same event

#### Scenario: Host paste shortcut reaches the application
- **WHEN** CtrlV or ShiftInsert reaches the editor instead of being intercepted by its terminal host
- **THEN** the framework does not query the local clipboard or claim that text was pasted
- **AND** actual host-delivered content is accepted only through the standard input/paste contract

### Requirement: Unified caret, style and viewport ownership
The framework SHALL store offsets only in the mounted public viewport, SHALL use the same character-width profile and selected-style resolver as Canvas/Frame, and SHALL request a logical caret rather than write terminal controls from the editor.

#### Scenario: Wide character at a narrow edge
- **WHEN** a two-column grapheme cannot fit completely within the effective clip
- **THEN** the editor does not draw half of it, preserves the logical value, and keeps the caret at a valid grapheme boundary

#### Scenario: Resize and theme change
- **WHEN** terminal dimensions shrink or a valid theme is replaced
- **THEN** offsets are clamped by the shared viewport and the existing text, focus identity and selection remain intact
- **AND** zero-size viewports hide the caret without deleting data

### Requirement: Conservative cut from truthful clipboard outcomes
The framework SHALL retain selected content for SentUnconfirmed, Unsupported, Unknown or Failed copy outcomes and SHALL delete on Applied only if the initiating mount, cut identity, text revision and selection revision still match.

#### Scenario: OSC52 sent without acknowledgement
- **WHEN** a cut request completes SentUnconfirmed
- **THEN** the original text, selection and undo history remain unchanged and the result remains visibly unconfirmed

#### Scenario: Applied result after a stale edit
- **WHEN** an actual confirmed result arrives after text or selection changed, including movement away and back
- **THEN** the editor preserves the current text and reports CutStale

#### Scenario: Copy is independent of deletion
- **WHEN** the application calls copyLocalText directly or the editor copies a selected range
- **THEN** sending does not require or cause a text deletion
- **AND** missing optional clipboard support does not prevent ordinary editing

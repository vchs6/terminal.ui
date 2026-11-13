# Rich text and explicit ANSI input

All types below are available from `import cjtui.*`. `Text(String)` and
`Frame.put(..., String)` remain strict plain text: LF and CRLF are allowed;
ESC, lone CR, tabs and other controls throw `IllegalArgumentException` before
writing. `validatePlainText(String)` exposes the same validator from both
`cjtui` and `cjtui.text`.

```cangjie
let content = RichText([
    TextSpan("Ready: ", style: TextStylePatch(bold: Some(true))),
    TextSpan("界", style: TextStylePatch(foreground: Some(Color.Green)))
])
let root = Column { Text(content); Text(content).foreground(Color.Cyan) }
let frame = Frame(20, 2)
frame.put(0, 0, content, style: Style(background: Color.Blue))
```

`TextStylePatch` has optional `foreground`, `background`, `bold`, `dim`, `italic`,
`underline`, `inverse` and `strikethrough` fields, all defaulting to `None`.
`None` inherits the corresponding base field; `Some(Color.Default)` and
`Some(false)` explicitly replace it. `resolve(base: Style)` returns a complete
`Style`. A patch is a value, and equality preserves unset versus explicit reset.

`TextSpan(text: String, style: TextStylePatch = TextStylePatch())` stores a
fragment without validating it separately. `RichText(String)` and
`RichText(Array<TextSpan>)` validate the concatenated document, discard empty
spans and merge adjacent equal patches. Input arrays and the `spans` getter
cannot mutate the value. Equality compares this normalized sequence, including
styles; `toPlainText()` returns the original concatenated text, without Unicode
normalization or added decoration.

The complete document uses the framework's existing Unicode grapheme segmenter.
A grapheme crossing spans (combining marks, ZWJ emoji, flags or CRLF) uses its
first scalar's patch. A fragment never splits a grapheme. Existing width,
clipping, line alignment and overflow rules apply equally to plain and rich text.
The `style` argument of `Frame.put` is a base overridden by spans. In components,
explicit attributes override each corresponding span field; other fields inherit
the enclosing component's base style. For example `.foreground(Color.Cyan)`
changes every span's foreground while retaining span bold and background values.

`Text(RichText)`, `Text(() -> RichText)`, and `Component.text` with either form
share the existing Text component and typed binding lifecycle. Replacing a
String or RichText getter detaches its old subscription. Equal normalized values
do not generate a frame. Style-only changes paint without measuring; text and
line changes invalidate layout. Setters are limited to Text and the owning UI
context, using the existing `UIException` contract.

## Decode ANSI deliberately

```cangjie
let result = parseAnsiText("\u{1b}[31;1mError\u{1b}[0m: retry")
let root = Text(result.text)
// result.diagnostics contains rejected control sequences with byte offsets.
```

ANSI input is converted into structured text; its source bytes are never sent
to the terminal. Supported SGR operations are reset (0 or an empty top-level
field), bold/dim/italic/underline/inverse/strikethrough (1/2/3/4/7/9), selective
resets (22/23/24/27/29), foreground/background 16 colors (30–37/90–97 and
40–47/100–107), default colors (39/49), indexed colors (`38;5;n`, `48;5;n`),
and RGB (`38;2;r;g;b`, `48;2;r;g;b`). Channels must be 0–255. Initial fields
are unset; SGR reset sets all eight fields explicitly. A bad sequence applies
none of its operations. Automatic terminal output downgrade remains the normal
framework policy; raw `Cell` styles retain the supplied colors.

For bytes arriving in chunks, create `AnsiTextDecoder(limits: AnsiTextLimits())`,
call `feed(Array<UInt8>)` and finally `finish()`. Both return an `AnsiTextBatch`
with defensive `spans` and `diagnostics` arrays. Concatenate all returned spans
and construct `RichText` after finishing. `parseAnsiText` does exactly this and
returns `AnsiTextResult` with `text` and a defensive diagnostics array. Batches
may end within a grapheme; combine them before rendering. A decoder has one
owning calling thread and is not thread safe; it retains no past batches or
whole document. `finish` closes it; any later call throws
`AnsiTextException` with code `DecoderClosed`. Use a new decoder for new input.

`AnsiTextLimits(maxSequenceBytes: 4096, maxParameters: 64)` accepts positive
values up to 1048576 and 4096 respectively; invalid values throw
`IllegalArgumentException`. The byte budget includes introducer and terminator
in their original encoding. Every CSI, including unknown operations, is limited
to the parameter count (semicolon-separated fields including empty fields) and
three consecutive decimal digits per token. Violations are reported immediately.
These are parser state limits, not limits on document length.

Diagnostics contain `kind: AnsiTextIssue` and `offset: Int64`, an absolute,
zero-based input byte offset at the control or sequence introducer. Kinds are
`UnsupportedSequence`, `MalformedSequence`, `SequenceTooLong` and
`IncompleteSequence`. Each sequence reports its first syntax/resource fault
once; an unfinished sequence can additionally report incomplete at `finish`.
Offsets count original UTF-8 bytes. Successful complete streams have equivalent
normalized spans and ordered diagnostics for every chunk division.

Unknown CSI and ESC operations are discarded. OSC accepts BEL or ST; DCS/SOS/PM/APC
accept only ST. Their payload is never cached, interpreted or exposed as text,
even after exceeding a limit or encountering nested escapes and CAN/SUB. Raw
and UTF-8 C1 controls are recognized only at scalar boundaries. LF and CRLF are
preserved; other isolated controls are discarded and diagnosed. Valid UTF-8
continuations resembling controls remain character data. Invalid or unfinished
UTF-8 throws `AnsiTextException(code: "InvalidUtf8")` and permanently closes the
decoder, including inside discarded control strings. An unrepresentable cumulative
input offset throws `InputTooLarge` and closes it. A failed call delivers no batch;
previously returned batches remain delivered, so exceptional streams need not
have identical delivered prefixes under different chunk divisions.

Run `examples/rich-text` in a terminal; `t` changes a bound span color and `q`
exits. After `cjpm build`, run `target/release/bin/main --smoke` for a headless
example. Full snapshots are generated from the resulting Frame, never from the
source ANSI. Device control, cursor movement and terminal emulation are outside
this decoder's scope.

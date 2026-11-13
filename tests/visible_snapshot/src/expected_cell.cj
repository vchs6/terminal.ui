package visible_snapshot

import cjtui.*

// Test data only. Widths come from the fixed manual fixtures, never production output.
struct ExpectedCell {
    let glyph: String
    let width: Int64
    let continuation: Bool
    let style: Style
    init(glyph: String, width!: Int64 = 1, continuation!: Bool = false, style!: Style = Style()) {
        this.glyph = glyph; this.width = width; this.continuation = continuation; this.style = style
    }
}

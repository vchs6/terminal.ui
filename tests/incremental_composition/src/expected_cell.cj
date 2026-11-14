package incremental_composition

import cjtui.*

struct ExpectedCell {
    let glyph: String
    let width: Int64
    let continuation: Bool
    let style: Style
    let transparent: Bool
    init(glyph: String, width!: Int64 = 1, continuation!: Bool = false,
        style!: Style = Style(), transparent!: Bool = false) {
        this.glyph = glyph; this.width = width; this.continuation = continuation
        this.style = style; this.transparent = transparent
    }
}

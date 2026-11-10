package cjtui

func projectTerminalGlyph(grapheme: String, width: Int64, policy: GlyphRenderPolicy): String {
    if (width < 0) {
        throw IllegalArgumentException("negative terminal glyph width")
    }
    if (width == 0) {
        return ""
    }
    if (!policy.conservative) {
        return grapheme
    }
    var remaining = width
    var matches = true
    for (scalar in grapheme.runes()) {
        let scalarWidth = displayWidth(scalar.toString())
        // Subtract from the stored column budget, so the sum cannot overflow.
        if (scalarWidth < 0 || scalarWidth > remaining) {
            matches = false
            break
        }
        remaining -= scalarWidth
    }
    if (matches && remaining == 0) {
        return grapheme
    }
    // Positive widths come from validated Frame heads and their allocation budget.
    String.fromUtf8(Array<UInt8>(width, repeat: 63))
}

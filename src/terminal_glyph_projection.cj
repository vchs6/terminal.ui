package cjtui

func projectTerminalGlyph(grapheme: String, width: Int64, policy: GlyphRenderPolicy): String {
    if (width < 0) { throw IllegalArgumentException("negative terminal glyph width") }
    if (width == 0) { return "" }
    if (policy.kind == 0) { return grapheme }
    if (policy.kind == 1) {
        var remaining = width
        for (scalar in grapheme.runes()) {
            let scalarWidth = displayWidth(scalar.toString())
            if (scalarWidth < 0 || scalarWidth > remaining) {
                return String.fromUtf8(Array<UInt8>(width, repeat: 63))
            }
            remaining -= scalarWidth
        }
        if (remaining == 0) { return grapheme }
        return String.fromUtf8(Array<UInt8>(width, repeat: 63))
    }
    var count: Int64 = 0
    var code: UInt32 = 0
    for (scalar in grapheme.runes()) { count++; code = UInt32(scalar) }
    if (width == 1 && count == 1 && code >= 32 && !(code >= 127 && code <= 159) && code <= 65535 &&
        displayWidth(grapheme) == 1 &&
        ((policy.kind == 2 && code <= 126) || (policy.kind == 3 && policy.has(code)))) {
        return grapheme
    }
    var fallback = if (width == 1) { borderFallback(grapheme) } else { "?" }
    if (policy.kind == 3) {
        let byte = UInt32(fallback.toArray()[0])
        if (!policy.has(byte)) { fallback = if (policy.has(63)) { "?" } else { " " } }
    }
    if (width == 1) { return fallback }
    let byte = fallback.toArray()[0]
    String.fromUtf8(Array<UInt8>(width, repeat: byte))
}

func generatedEllipsis(policy: GlyphRenderPolicy, availableColumns: Int64, ambiguousWide!: Bool = false): String {
    if (availableColumns <= 0) { return "" }
    if (policy.kind != 2 && displayWidth("…", ambiguousWide: ambiguousWide) == 1 &&
        (policy.kind != 3 || policy.has(0x2026))) { return "…" }
    if (availableColumns == 1) { return "." }
    if (availableColumns == 2) { return ".." }
    "..."
}

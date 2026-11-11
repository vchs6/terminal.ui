package cjtui

func detectTerminalGlyphs(): (TerminalGlyphCapabilities, GlyphRenderPolicy) {
    let bitmap = Array<UInt8>(8192, repeat: 0u8)
    let result = Array<Int64>(3, repeat: 0)
    unsafe {
        let b = acquireArrayRawData(bitmap)
        let r = acquireArrayRawData(result)
        cjt_glyph_probe(b.pointer, r.pointer)
        releaseArrayRawData(r)
        releaseArrayRawData(b)
    }
    let status = result[0]
    let known = status == 0
    let vt = known || status == 5 || status == 6 || status == 7
    let source = if (known) { "linux-vt-unimap" } else if (vt) { "linux-vt-unavailable" } else { "unknown" }
    let reason = match (status) {
        case 0 => if ((bitmap[7] & 128u8) == 0) { "ascii-fallback-unavailable" } else { "" }
        case 1 => "not-tty"
        case 2 => "not-concrete-linux-vt"
        case 3 => "vt-query-failed"
        case 4 => "not-text-mode"
        case 5 => "map-allocation-failed"
        case 6 => "map-query-failed"
        case 7 => "map-invalid"
        case _ => "unsupported-platform"
    }
    let cap = TerminalGlyphCapabilities(vt, known, result[2], source, reason, result[1])
    let policy = if (known) { GlyphRenderPolicy.mapped(bitmap) } else if (vt) {
        GlyphRenderPolicy.ascii()
    } else { GlyphRenderPolicy.conservativeUnicode() }
    (cap, policy)
}

func offlineGlyphPolicy(mode: GlyphMode): GlyphRenderPolicy {
    if (mode == GlyphMode.Ascii) { GlyphRenderPolicy.ascii() } else { GlyphRenderPolicy.unicode() }
}

package glyph_api

import cjtui.*

// Keep this consumer free of future RichText/Theme names: its RED diagnoses G002.
main(): Int64 {
    if (GlyphMode.Auto == GlyphMode.Ascii || GlyphMode.Ascii == GlyphMode.Unicode ||
        GlyphMode.Unicode == GlyphMode.Auto || GlyphMode.Ascii != GlyphMode.Ascii) {
        throw Exception("three distinct Equatable modes")
    }
    let app = Application(Text("é中文"), glyphMode: GlyphMode.Auto)
    if (app.glyphMode() != GlyphMode.Auto) { throw Exception("default/requested mode") }
    let receiver: Application = app.glyphMode(GlyphMode.Ascii)
    if (receiver.glyphMode() != GlyphMode.Ascii) { throw Exception("setter/getter") }
    receiver.glyphMode(GlyphMode.Unicode)
    if (app.glyphMode() != GlyphMode.Unicode) { throw Exception("setter must return same receiver") }
    let legacy = Application(Text("legacy"))
    let legacyColored = Application(Text("legacy"), colorMode: ColorMode.Basic8)
    if (legacy.glyphMode() != GlyphMode.Auto || legacyColored.glyphMode() != GlyphMode.Auto) {
        throw Exception("both existing constructors default Auto")
    }
    let colored = Application(Text("x"), colorMode: ColorMode.Basic8, glyphMode: GlyphMode.Unicode)
    if (colored.glyphMode() != GlyphMode.Unicode) { throw Exception("second existing constructor") }
    if (app.terminalGlyphCapabilities().isSome()) { throw Exception("must not probe before run") }
    app.startHeadless()
    try {
        app.snapshot(8, 1, glyphMode: GlyphMode.Ascii)
        app.snapshot(8, 1)
    } finally { app.dispose() }
    render(Text("x"), 1, 1, glyphMode: GlyphMode.Auto)
    render(Text("x"), 1, 1)
    println("PASS glyph public API")
    return 0
}

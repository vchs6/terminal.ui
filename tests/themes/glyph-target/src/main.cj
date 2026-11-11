package theme_glyph_target
import cjtui.*
import cjtui.theme.*
// Isolated target admission: no future layout names can hide missing Theme.
main(): Int64 {
    let value = Theme.preset(ThemePreset.Classic)
    let app = Application(Text("ABCDE"),glyphMode:GlyphMode.Ascii,theme:value)
    app.startHeadless()
    try {
        if (app.snapshot(4,1,glyphMode:GlyphMode.Auto).toPlainText() != "ABCD") { throw Exception("Theme positive control") }
    } finally { app.dispose() }
    println("PASS actual public Theme target")
    0
}

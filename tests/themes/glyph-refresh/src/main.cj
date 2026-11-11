package theme_glyph_refresh
import cjtui.*
main(): Int64 {
    let value = Theme.preset(ThemePreset.Classic)
    let probe = Application(Text("Theme"),theme:value)
    probe.startHeadless()
    try { check(probe.snapshot(5,1).toPlainText() == "Theme","real Theme positive") }
    finally { probe.dispose() }
    markerWidths()
    layoutContext()
    cacheContext()
    println("PASS TASK085 appended Glyph/ellipsis public consumer")
    0
}

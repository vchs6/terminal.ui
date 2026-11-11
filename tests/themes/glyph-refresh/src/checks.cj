package theme_glyph_refresh
import cjtui.*
func check(value: Bool, label: String): Unit {
    if (!value) { throw Exception("FAIL ${label}") }
    println("PASS ${label}")
}
func grid(root: Component, width: Int64, height: Int64, mode: GlyphMode,
    expected: String, label: String): Unit {
    let frame = render(root,width,height,glyphMode:mode)
    check(frame.toPlainText() == expected,"${label}: [${frame.toPlainText()}] expected [${expected}]")
}

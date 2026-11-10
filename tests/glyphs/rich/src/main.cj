package glyph_rich

import cjtui.*

func check(value: Bool, name: String): Unit {
    if (!value) { throw Exception("FAIL ${name}") }
    println("PASS ${name}")
}

main(): Int64 {
    let content = RichText([
        TextSpan("e", style: TextStylePatch(foreground: Some(Color.Red))),
        TextSpan("\u{301}中👩", style: TextStylePatch(foreground: Some(Color.Blue))),
        TextSpan("‍💻", style: TextStylePatch(bold: Some(true)))
    ])
    for (mode in [GlyphMode.Unicode, GlyphMode.Auto, GlyphMode.Ascii]) {
        let frame = render(Text(content), 6, 1, glyphMode: mode)
        check(frame.toPlainText() == "e\u{301}中👩‍💻 ", "offline RichText Unicode logical source")
        check(frame.cellAt(0, 0).grapheme == "e\u{301}" && frame.cellAt(0, 0).width == 1,
            "combining cluster survives cross-span boundary")
        check(frame.cellAt(3, 0).grapheme == "👩‍💻" && frame.cellAt(4, 0).continuation,
            "ZWJ cluster survives cross-span boundary")
    }
    return 0
}

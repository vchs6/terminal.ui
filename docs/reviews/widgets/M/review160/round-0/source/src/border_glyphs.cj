package cjtui

func borderGlyphs(border: BorderStyle): (String, String, String, String, String, String) {
    if (border == BorderStyle.Ascii) { return ("+", "+", "+", "+", "-", "|") }
    if (border == BorderStyle.Rounded) { return ("╭", "╮", "╰", "╯", "─", "│") }
    if (border == BorderStyle.Double) { return ("╔", "╗", "╚", "╝", "═", "║") }
    ("┌", "┐", "└", "┘", "─", "│")
}

func borderFallback(glyph: String): String {
    let (at, ar, ab, ac, ah, av) = borderGlyphs(BorderStyle.Ascii)
    for (style in [BorderStyle.Single, BorderStyle.Rounded, BorderStyle.Double]) {
        let (tl, tr, bl, br, horizontal, vertical) = borderGlyphs(style)
        if (glyph == tl) { return at }
        if (glyph == tr) { return ar }
        if (glyph == bl) { return ab }
        if (glyph == br) { return ac }
        if (glyph == horizontal) { return ah }
        if (glyph == vertical) { return av }
    }
    "?"
}

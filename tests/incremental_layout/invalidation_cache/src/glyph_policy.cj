package incremental_invalidation_cache

import cjtui.*

// Breaks: generated marker cache ignores effective policy/available width or transcodes business text.
func glyphPolicy(): Unit {
    let epoch = [Int64(0)]
    let root = Column {
        Text("abcdef").overflow(TextOverflow.Ellipsis).foreground(Color.Red)
        Text("中e\u{301}")
    }
    let app = Application(root)
    app.startHeadless()
    try {
        paired(app, root, epoch, 5, 2, "abcd…\n中e\u{301}  ", "Unicode generated marker")
        let ascii = paired(app, root, epoch, 5, 2, "ab...\n中e\u{301}  ", "ASCII generated marker", glyphMode: GlyphMode.Ascii)
        check(ascii.frame.cellAt(2, 0).style.foreground == Color.Red &&
            ascii.frame.cellAt(0, 1).width == 2 && ascii.frame.cellAt(1, 1).continuation, "marker style and raw business wide cluster")
        paired(app, root, epoch, 2, 2, "..\n中", "ASCII two-column marker", glyphMode: GlyphMode.Ascii)
        paired(app, root, epoch, 1, 2, ".\n ", "ASCII one-column marker", glyphMode: GlyphMode.Ascii)
        paired(app, root, epoch, 5, 2, "ab...\n中e\u{301}  ", "ASCII original width restored", glyphMode: GlyphMode.Ascii)
        paired(app, root, epoch, 5, 2, "abcd…\n中e\u{301}  ", "Unicode policy restored")
        paired(app, root, epoch, 5, 2, "abcd…\n中e\u{301}  ", "offline Auto same effective Unicode", glyphMode: GlyphMode.Auto).noTarget()
    } finally { app.dispose() }
}

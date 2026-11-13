package visible_snapshot

import cjtui.*

func glyphSnapshots(): Unit {
    let source = Observable<String>("éBCDE")
    let root = Column {
        Text({ => source.get() }).overflow(TextOverflow.Ellipsis).height(1)
        Text("中e\u{301}").height(1)
    }.viewport(ScrollAxes.Off)
    let app = Application(root, glyphMode: GlyphMode.Ascii, theme: bareTheme())
    app.startHeadless()
    try {
        let unicode = grid(["éBC…", "__e "])
        mark(unicode, 0, 1, "中", width: 2); mark(unicode, 2, 1, "e\u{301}")
        let ascii = grid(["é...", "__e "])
        mark(ascii, 0, 1, "中", width: 2); mark(ascii, 2, 1, "e\u{301}")
        let old = app.snapshot(4, 2) // Existing two-argument public call stays source-compatible.
        save(old, "éBC…\n中e\u{301} ", unicode, "glyph-default")
        save(app.snapshot(4, 2, glyphMode: GlyphMode.Auto), "éBC…\n中e\u{301} ", unicode, "glyph-auto")
        save(app.snapshot(4, 2, glyphMode: GlyphMode.Ascii), "é...\n中e\u{301} ", ascii, "glyph-ascii")
        save(app.snapshot(4, 2, glyphMode: GlyphMode.Unicode), "éBC…\n中e\u{301} ", unicode, "glyph-unicode")
        app.batch({ => source.set("Q"); app.glyphMode(GlyphMode.Unicode); () })
        let changed = grid(["Q   ", "__e "])
        mark(changed, 0, 1, "中", width: 2); mark(changed, 2, 1, "e\u{301}")
        save(app.snapshot(4, 2), "Q   \n中e\u{301} ", changed, "glyph-changed")
        save(old, "éBC…\n中e\u{301} ", unicode, "glyph-old")
        check(app.terminalGlyphCapabilities().isNone(), "offline snapshots do not probe a device")
        check(source.get() == "Q", "snapshot never modifies business Unicode")
    } finally { app.dispose() }
}

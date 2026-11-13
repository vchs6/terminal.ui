package visible_snapshot

import cjtui.*

func layerSnapshots(): Unit {
    let value = Observable<String>("ijklmnop")
    let root = Column {
        Text(RichText([
            TextSpan("e\u{301}", style: TextStylePatch(foreground: Some(Color.Rgb(17, 34, 51)), underline: Some(true))),
            TextSpan("中👩‍💻ABC")
        ])).height(1)
        Text({ => value.get() }).height(1)
        Text("qrstuvwx").height(1)
    }.viewport(ScrollAxes.Off)
    let app = Application(root, theme: bareTheme()); app.startHeadless()
    try {
        let base = grid(["e____ABC", "ijklmnop", "qrstuvwx"])
        mark(base, 0, 0, "e\u{301}", style: Style(foreground: Color.Rgb(17, 34, 51), underline: true))
        mark(base, 1, 0, "中", width: 2); mark(base, 3, 0, "👩‍💻", width: 2)
        save(app.snapshot(8, 3), "e\u{301}中👩‍💻ABC\nijklmnop\nqrstuvwx", base, "layers-base")
        let cover = Canvas({ _ => Size(3, 1) }, { p =>
            p.put(0, 0, "X")
            p.put(1, 0, " ", patch: TextStylePatch(background: Some(Color.Blue), bold: Some(true)))
        }).width(3).height(1)
        let parent = open(app, root, cover, OverlayMode.NonModal)
        let holes = grid(["e____ABC", "ijX mnop", "qrstuvwx"])
        mark(holes, 0, 0, "e\u{301}", style: Style(foreground: Color.Rgb(17, 34, 51), underline: true))
        mark(holes, 1, 0, "中", width: 2); mark(holes, 3, 0, "👩‍💻", width: 2)
        mark(holes, 3, 1, " ", style: Style(background: Color.Blue, bold: true))
        let old = app.snapshot(8, 3)
        save(old, "e\u{301}中👩‍💻ABC\nijX mnop\nqrstuvwx", holes, "layers-holes")
        let modal = Text("M").width(3).height(1).underline().inverse()
        let child = open(app, cover, modal, OverlayMode.Modal)
        let nested = grid(["e____ABC", "ijM  nop", "qrstuvwx"])
        mark(nested, 0, 0, "e\u{301}", style: Style(foreground: Color.Rgb(17, 34, 51), underline: true))
        mark(nested, 1, 0, "中", width: 2); mark(nested, 3, 0, "👩‍💻", width: 2)
        region(nested, Rect(2, 1, 3, 1), Style(underline: true, inverse: true))
        save(app.snapshot(8, 3), "e\u{301}中👩‍💻ABC\nijM  nop\nqrstuvwx", nested, "layers-nested")
        value.set("IJKLMNOP")
        let latest = grid(["e____ABC", "IJM  NOP", "qrstuvwx"])
        mark(latest, 0, 0, "e\u{301}", style: Style(foreground: Color.Rgb(17, 34, 51), underline: true))
        mark(latest, 1, 0, "中", width: 2); mark(latest, 3, 0, "👩‍💻", width: 2)
        region(latest, Rect(2, 1, 3, 1), Style(underline: true, inverse: true))
        save(app.snapshot(8, 3), "e\u{301}中👩‍💻ABC\nIJM  NOP\nqrstuvwx", latest, "layers-covered-update")
        app.batch({ => parent.close() })
        check(!parent.isOpen() && !child.isOpen(), "closing parent closes nested modal")
        let closed = grid(["e____ABC", "IJKLMNOP", "qrstuvwx"])
        mark(closed, 0, 0, "e\u{301}", style: Style(foreground: Color.Rgb(17, 34, 51), underline: true))
        mark(closed, 1, 0, "中", width: 2); mark(closed, 3, 0, "👩‍💻", width: 2)
        save(app.snapshot(8, 3), "e\u{301}中👩‍💻ABC\nIJKLMNOP\nqrstuvwx", closed, "layers-closed")
        save(old, "e\u{301}中👩‍💻ABC\nijX mnop\nqrstuvwx", holes, "layers-old")
    } finally { app.dispose() }
}

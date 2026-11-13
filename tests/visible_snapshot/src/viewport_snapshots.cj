package visible_snapshot

import cjtui.*

func viewportSnapshots(): Unit {
    let value = Observable<String>("A界B")
    let saved = Array<?Component>(1, repeat: Option<Component>.None)
    let root = Row {
        Text("#").width(1)
        saved[0] = Some(Canvas({ b => Size(b.textWidth(value.get()), 1) },
            { p => p.put(0, 0, value.get()) }).width(2).viewport(ScrollAxes.Horizontal))
        Text("!").width(1)
    }.viewport(ScrollAxes.Off)
    let app = Application(root, theme: bareTheme()); app.startHeadless()
    try {
        let old = app.snapshot(4, 1)
        save(old, "#A !", grid(["#A !"]), "viewport-right-clip")
        app.batch({ => node(saved[0].getOrThrow()).scrollTo(1, 0) })
        let whole = grid(["#__!"]); mark(whole, 1, 0, "界", width: 2)
        save(app.snapshot(4, 1), "#界!", whole, "viewport-whole")
        let cover = Text("X").width(2).height(1).surface(SurfaceMode.Transparent)
        let handle = open(app, root, cover, OverlayMode.NonModal)
        save(app.snapshot(4, 1), "#X !", grid(["#X !"]), "viewport-overlay-initial")
        app.batch({ => node(saved[0].getOrThrow()).scrollTo(2, 0) })
        save(app.snapshot(4, 1), "#XB!", grid(["#XB!"]), "viewport-overlay-scroll")
        app.batch({ => handle.close() })
        save(app.snapshot(4, 1), "# B!", grid(["# B!"]), "viewport-left-clip")
        value.set("B")
        save(app.snapshot(4, 1), "#B !", grid(["#B !"]), "viewport-shrunk")
        save(old, "#A !", grid(["#A !"]), "viewport-old")
    } finally { app.dispose() }
}

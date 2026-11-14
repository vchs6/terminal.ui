package incremental_layout_baseline

import cjtui.*

// Breaks: second tree/remount, duplicate children, consumed target dirty, snapshot aliasing.
func referenceLifetime(): Unit {
    let effects = [Int64(0), Int64(0)]
    let text = Observable<String>("ab")
    let root = Column {
        Text({ => text.get() }).onMount({ _ =>
            effects[0]++
            { => effects[1]++; () }
        })
        Text("Z")
    }
    plain(render(root, 4, 2), "ab  \nZ   ", "detached reference")
    check(effects[0] == 0 && effects[1] == 0 && root.reference().isNone(), "detached has no lifecycle or ref")
    let app = Application(root)
    let initial = app.stats()
    check(initial.mountedNodes == 0 && initial.activeBindings == 0 && initial.subscriptions == 0 &&
        initial.pendingPosts == 0 && initial.builds == 0 && initial.measures == 0 &&
        initial.paints == 0 && initial.frames == 0, "old eight stats initially zero")
    app.startHeadless()
    try {
        let saved = paired(app, root, 4, 2, "ab  \nZ   ", "mounted lifetime")
        let ref = root.reference().getOrThrow().children()[0]
        let before = app.stats()
        render(root, 3, 2)
        let after = app.stats()
        check(after.frames == before.frames + 1 && after.measures >= before.measures + 3 &&
            after.paints == before.paints + 3, "reference forces full old stages")
        check(after.builds == before.builds && after.mountedNodes == 3 &&
            after.activeBindings == before.activeBindings && after.subscriptions == before.subscriptions,
            "reference preserves nodes/builds/binding stock")
        check(ref.sameNode(root.reference().getOrThrow().children()[0]) && root.reference().getOrThrow().children().size == 2,
            "reference retains identity and child sequence")
        saved.put(0, 0, "XX")
        app.batch({ => text.set("c") })
        plain(render(root, 4, 2), "c   \nZ   ", "reference stabilizes pending binding")
        paired(app, root, 4, 2, "c   \nZ   ", "reference leaves target invalidation available")
        check(effects[0] == 1 && effects[1] == 0, "no reference remount/cleanup")
        plain(saved, "XX  \nZ   ", "saved snapshot independently editable")
    } finally { app.dispose() }
    check(effects[1] == 1 && root.reference().isNone(), "one cleanup and released ref")
    let end = app.stats()
    check(end.mountedNodes == 0 && end.activeBindings == 0 && end.subscriptions == 0 && end.frames > 0,
        "dispose clears stocks and retains cumulative stats")
    println("PASS CASE 5 detached/mounted reference/lifetime/old stats/snapshot")
}

// Breaks: reference reads replace Canvas M/P subscriptions, raw style/width loss, caret commit.
func canvasDependencies(): Unit {
    let height = Observable<Int64>(1)
    let wide = Observable<String>("中")
    let narrow = Observable<String>("N")
    let root = Row {
      Canvas({ _ => Size(3, height.get()) }, { context =>
        let text = if (context.size.width >= 3) { wide.get() } else { narrow.get() }
        context.put(0, 0, text, patch: TextStylePatch(foreground: Some(Color.Blue), bold: Some(true)))
        if (context.size.height > 1) { context.put(0, 1, "!") }
        context.caret(if (context.size.width >= 3) { 2 } else { 0 }, 0)
      }).layoutWeight(1).focusable(true)
      Text("Z")
    }
    let app = Application(root)
    app.startHeadless()
    try {
        paired(app, root, 4, 2, "中 Z\n    ", "canvas initial")
        app.batch({ => root.reference().getOrThrow().children()[0].requestFocus() })
        let frame = app.snapshot(4, 2)
        cell(frame, 0, 0, "中", 2, false, Style(foreground: Color.Blue, bold: true), "canvas wide lead")
        cell(frame, 1, 0, "", 0, true, Style(foreground: Color.Blue, bold: true), "canvas wide continuation")
        let caret = app.caretSnapshot()
        check(caret.visible && caret.x == 2 && caret.y == 0, "canvas persistent caret")
        let stock = app.stats().subscriptions
        plain(render(root, 2, 1), "NZ", "narrow reference uses its own draw input")
        check(app.stats().subscriptions == stock, "reference narrow dependency not persisted")
        check(app.caretSnapshot().visible && app.caretSnapshot().x == 2, "reference does not publish caret")
        app.batch({ => wide.set("文") })
        paired(app, root, 4, 2, "文 Z\n    ", "persistent draw subscription survives reference")
        app.batch({ => height.set(2) })
        paired(app, root, 4, 2, "文 Z\n!   ", "independent measure subscription survives reference")
    } finally { app.dispose() }
    println("PASS CASE 6 Canvas measure/draw/reference/width/style/caret")
}

// Breaks: generated marker policy leaks between entry points in a mounted session.
func glyphGeneration(): Unit {
    let root = Text("abcdef").overflow(TextOverflow.Ellipsis)
    let app = Application(root)
    app.startHeadless()
    try {
        plain(app.snapshot(5, 1), "abcd…", "Unicode marker")
        let ascii = app.snapshot(5, 1, glyphMode: GlyphMode.Ascii)
        plain(ascii, "ab...", "ASCII marker consumes three columns")
        equalCells(ascii, render(root, 5, 1, glyphMode: GlyphMode.Ascii), "ASCII reference")
        paired(app, root, 5, 1, "abcd…", "Unicode marker restored")
    } finally { app.dispose() }
    println("PASS CASE 7 Unicode/ASCII generated marker")
}

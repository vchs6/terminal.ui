package interaction_b

import cjtui.*

// Catches Bool derived from committed rather than already queued offsets, and overflow arithmetic.
func acceptedCommandsAndClamping(): Unit {
    let text = Observable<String>("0123456789\nabcdefghij\nKLMNOPQRST\nuvwxyzABCD")
    let root = Column({ => Text({ => text.get() }) }).viewport(ScrollAxes.Both)
    let app = Application(root)
    app.startHeadless()
    try {
        app.snapshot(4, 2)
        app.batch({ =>
            check(!ref(root).scrollBy(0, 0), "B04 zero movement false")
            check(ref(root).scrollTo(6, 2), "B04 accepted end true")
            check(!ref(root).scrollTo(6, 2), "B04 same queued offset false")
            check(!ref(root).scrollBy(Int64.Max, Int64.Max), "B02 saturated at end false")
            check(ref(root).scrollBy(Int64.Min, Int64.Min), "B02 saturated negative movement true")
            check(!ref(root).scrollBy(-1, -1), "B04 at start false")
        })
        offset(root, 0, 0, "B02 saturation reaches start")
        app.batch({ =>
            check(ref(root).scrollTo(Int64.Max, Int64.Max), "B02 huge To accepted")
            text.set("X")
        })
        app.snapshot(4, 2)
        offset(root, 0, 0, "B02 shrink clamps accepted candidate")
        app.batch({ => illegal({ => ref(root).scrollTo(-1, 0) }, "B02 negative x rejected") })
    } finally { app.dispose() }
}

// Catches disabled-axis offsets retained and zero viewport destroying identity.
func axesAndZeroResize(): Unit {
    let axes = Observable<ScrollAxes>(ScrollAxes.Both)
    let root = Column({ => Text("0123456789\nabcdefghij\nKLMNOPQRST\nuvwxyzABCD") })
        .viewport({ => axes.get() }).focusable(true)
    let app = Application(root)
    app.startHeadless()
    try {
        app.snapshot(4, 2)
        let retained = ref(root)
        app.batch({ => ref(root).scrollTo(6, 2) })
        app.batch({ => axes.set(ScrollAxes.Vertical) })
        app.snapshot(4, 2)
        check(ref(root).viewportSnapshot().offsetX == 0, "B02 disabled X resets")
        app.snapshot(0, 0)
        check(retained.sameNode(ref(root)), "B02 zero preserves node")
        check(app.focusedNode().getOrThrow().sameNode(retained), "B02 zero preserves focus")
        app.batch({ => retained.ensureVisible(rect: Rect(0, 3, 1, 1)) })
        check(!app.caretSnapshot().visible, "B02 zero hides caret")
        app.snapshot(10, 4)
        offset(root, 0, 0, "B02 resize clamps to full extent")
    } finally { app.dispose() }
}

func horizontalTable(): Unit {
    let row = Row({ => Text("ABCD"); Text("EFGH"); Text("IJKL") }).viewport(ScrollAxes.Horizontal)
    let app = Application(row)
    app.startHeadless()
    try {
        picture(app.snapshot(4, 1), "ABCD", "B01 horizontal initial")
        app.batch({ => ref(row).scrollTo(8, 0) })
        picture(app.snapshot(4, 1), "IJKL", "B01 horizontal tail")
        app.dispatch(ref(row), KeyEvent("home", text: ""))
        offset(row, 0, 0, "B04 horizontal Home")
        app.dispatch(ref(row), KeyEvent("end", text: ""))
        offset(row, 8, 0, "B04 horizontal End")
    } finally { app.dispose() }
}

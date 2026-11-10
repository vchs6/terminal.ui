package interaction_b

import cjtui.*

// Literal geometry: outer H4, spacer3, inner box H3/document H10, tail3.
// Target row9 => inner7; visible row is outer local5 => nearest outer2.
func nestedEnsure(): Unit {
    var inner: ?Component = None
    let outer = Column({ =>
        Text("s\ns\ns").height(3)
        inner = ScrollView({ => Text("0\n1\n2\n3\n4\n5\n6\n7\n8\n9") }).height(3)
        Text("t\nt\nt").height(3)
    })
        .viewport(ScrollAxes.Vertical)
    let app = Application(outer)
    app.startHeadless()
    try {
        app.snapshot(1, 4)
        app.batch({ => ref(inner).ensureVisible(rect: Rect(0, 9, 1, 1)) })
        app.snapshot(1, 4)
        offset(inner, 0, 7, "B03 nearest inner")
        offset(outer, 0, 2, "B03 nearest uses visible fragment")
        picture(app.snapshot(1, 4), "s\n7\n8\n9", "B03 nested target screen bottom")
        app.batch({ =>
            ref(inner).scrollTo(0, 0); ref(outer).scrollTo(0, 0)
            ref(inner).ensureVisible(rect: Rect(0, 8, 1, 1), vertical: ScrollAlign.Start)
        })
        app.snapshot(1, 4)
        offset(inner, 0, 7, "B03 Start inner clamps")
        offset(outer, 0, 4, "B03 Start outer visible fragment")
    } finally { app.dispose() }
}

// Catches incorrect Center rounding, oversized-target jumps, empty rect movement.
func alignmentsAndOversizedTarget(): Unit {
    let root = ScrollView({ => hundredRows() })
    let app = Application(root)
    app.startHeadless()
    try {
        app.snapshot(4, 6)
        app.batch({ => ref(root).ensureVisible(rect: Rect(0, 20, 1, 1), vertical: ScrollAlign.Center) })
        app.snapshot(4, 6)
        offset(root, 0, 18, "B03 Center floors half remainder")
        app.batch({ => ref(root).ensureVisible(rect: Rect(0, 20, 1, 1), vertical: ScrollAlign.End) })
        app.snapshot(4, 6)
        offset(root, 0, 15, "B03 End")
        app.batch({ => ref(root).ensureVisible(rect: Rect(0, 10, 1, 30)) })
        app.snapshot(4, 6)
        offset(root, 0, 15, "B03 oversized already inside preserves window")
        app.batch({ => ref(root).ensureVisible(rect: Rect(0, 99, 0, 0)) })
        app.snapshot(4, 6)
        offset(root, 0, 15, "B03 empty rect no-op")
        app.batch({ => code("InvalidProperty", { =>
            ref(root).ensureVisible(rect: Rect(0, 100, 1, 1))
        }, "B03 beyond finite extent") })
    } finally { app.dispose() }
}

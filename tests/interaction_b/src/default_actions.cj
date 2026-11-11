package interaction_b

import cjtui.*

// Catches viewport-before-user ordering, stop suppressing defaults, and double ScrollView callbacks.
func defaultActionOrder(): Unit {
    for (prevent in [false, true]) {
        let trace=Box<String>("")
        let target=Box<?Component>(Option<Component>.None)
        let inner=Box<?Component>(Option<Component>.None)
        let root = Column({ =>
            inner.value = ScrollView({ =>
                target.value = Text("T").height(1).focusable(true)
                    .defaultAction({ e => trace.value += "target;"; e.stopPropagation() })
                Text("1\n2\n3\n4\n5").height(5)
            }).height(3)
            Text("o\no\no\no").height(4)
        }).viewport(ScrollAxes.Vertical)
            .defaultAction({ _ => trace.value += "outer;" }, phase: DefaultActionPhase.Ancestor)
        inner.value.getOrThrow().defaultAction({ e =>
            trace.value += "inner@${ref(inner.value).viewportSnapshot().offsetY};"
            if (prevent) { e.preventDefault() } else { e.stopPropagation() }
        }, phase: DefaultActionPhase.Ancestor)
        let app = Application(root)
        app.startHeadless()
        try {
            app.snapshot(1, 4)
            trace.value = ""
            app.dispatch(ref(target.value), KeyEvent("down", text: ""))
            check(trace.value == "target;inner@0;", "B04 trace user before builtin / no outer")
            offset(inner.value, 0, if (prevent) { 0 } else { 1 }, "B04 prevent versus stop")
            offset(root, 0, 0, "B04 nearest consumes once")
            if (!prevent) {
                app.batch({ => ref(inner.value).scrollTo(0, 3) })
                trace.value = ""
                app.dispatch(ref(target.value), KeyEvent("down", text: ""))
                check(trace.value == "target;inner@3;outer;", "B04 boundary handoff trace")
                offset(root, 0, 1, "B04 boundary moves outer once")
            }
        } finally { app.dispose() }
    }
}

func targetPrevent(): Unit {
    let target=Box<?Component>(Option<Component>.None)
    let root = ScrollView({ =>
        target.value = Text("T").height(1).focusable(true).defaultAction({ e => e.preventDefault() })
        hundredRows()
    })
    let app = Application(root)
    app.startHeadless()
    try {
        app.snapshot(4, 6)
        app.dispatch(ref(target.value), KeyEvent("down", text: ""))
        offset(root, 0, 0, "B04 Target prevent stops viewport")
    } finally { app.dispose() }
}

// Codes are the upstream K002 normalized navigation codes; no device decoding claim.
func pageSteps(): Unit {
    let root = ScrollView({ => hundredRows() })
    let app = Application(root)
    app.startHeadless()
    try {
        app.snapshot(4, 6)
        app.dispatch(ref(root), KeyEvent("pagedown", text: ""))
        offset(root, 0, 5, "B04 pagedown height minus one")
        app.dispatch(ref(root), KeyEvent("pageup", text: ""))
        offset(root, 0, 0, "B04 pageup")
        app.snapshot(4, 1)
        app.dispatch(ref(root), KeyEvent("pagedown", text: ""))
        offset(root, 0, 1, "B04 zero page overlap minimum step one")
    } finally { app.dispose() }
}

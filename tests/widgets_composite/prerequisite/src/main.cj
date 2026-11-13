package widgets_composite_prerequisite

import cjtui.*

func check(value: Bool, name: String): Unit {
    if (!value) { throw Exception(name) }
}

main(): Int64 {
    let values = Observable<Array<String>>(["a", "b"])
    let root = Column {
        ForEach({ => values.get() }, { key => key }, { item =>
            Text({ => item.value }).focusable(true)
        })
    }
    let app = Application(root)
    app.startHeadless()
    try {
        check(app.snapshot(4, 2).toPlainText() == "a   \nb   ", "public ForEach/ListItem frame")
        let before = root.reference().getOrThrow().children()
        app.batch({ => before[1].requestFocus() })
        check(before[1].isFocused(), "queued focus committed before dispatch")
        app.batch({ => values.set(["b", "a"]) })
        let after = root.reference().getOrThrow().children()
        check(after[0].sameNode(before[1]) && after[1].sameNode(before[0]), "retained physical children")
        app.batch({ => root.reference().getOrThrow().moveBefore(after[1], after[0]) })
        check(root.reference().getOrThrow().children()[0].sameNode(before[0]), "public physical move")
        let popup = Column { Text("P").focusable(true) }.surface(SurfaceMode.Opaque)
        let held = Array<?OverlayHandle>(1, repeat: Option<OverlayHandle>.None)
        app.batch({ => held[0] = Some(before[1].openOverlay(popup, options: OverlayOptions(mode: OverlayMode.Modal))) })
        let handle = held[0].getOrThrow()
        check(handle.isOpen(), "public overlay mounted")
        app.dispatch(app.activeTarget().getOrThrow(), KeyEvent("escape"))
        check(handle.closeReason().getOrThrow() == OverlayCloseReason.Escape && before[1].isFocused(), "public Esc restores focus")
        let requests = [0]
        let button = Button("B", { => requests[0]++ })
        app.batch({ => root.reference().getOrThrow().append(button) })
        let target = button.reference().getOrThrow()
        app.batch({ => target.requestFocus() })
        app.dispatch(target, KeyEvent("enter"))
        app.dispatch(target, KeyEvent("text", text: " ", ctrl: true, alt: true, shift: true))
        check(requests[0] == 1, "accepted S public activation")
    } finally { app.dispose() }
    check(app.stats().mountedNodes == 0 && app.stats().activeBindings == 0 && app.stats().subscriptions == 0, "public cleanup")
    check(render(Row { Text("A").layoutWeight(1); Text("B").layoutWeight(1) }, 5, 1).toPlainText() == "A  B ", "public odd remainder")
    check(render(Text("x"), 0, 2).toPlainText() == "\n", "zero width full frame")
    acceptedS02()
    originalContracts()
    println("TASK158_ACCEPTED_PREREQUISITE_PASS")
    0
}

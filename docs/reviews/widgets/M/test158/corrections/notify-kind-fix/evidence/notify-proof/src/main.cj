package notify_style_proof

import cjtui.{Application, ChangeKind, Color, Component, Row, Text}

func check(value: Bool, name: String): Unit {
    if (!value) { throw IllegalStateException(name) }
}

main(): Int64 {
    let color = [Color.Red]
    let callbacks = [0]
    let children = Array<?Component>(2, repeat: Option<Component>.None)
    let root = Row {
        children[0] = Some(Text("A").focusable(true).onKey({ _ => callbacks[0]++ }))
        children[1] = Some(Text("B").enabled(false).foreground({ => color[0] }))
    }
    let first = children[0].getOrThrow()
    let disabled = children[1].getOrThrow()
    let app = Application(root)
    app.startHeadless()
    try {
        let target = disabled.reference().getOrThrow()
        let focused = first.reference().getOrThrow()
        let before = app.snapshot(2, 1)
        check(before.toPlainText() == "AB" && before.cellAt(1, 0).style.foreground == Color.Red, "literal initial public frame/style")
        check(focused.isFocused() && !target.isEnabled(), "fixture eligible focus and disabled target")
        color[0] = Color.Blue
        app.batch({ => target.notify(ChangeKind.Style) })
        let after = app.snapshot(2, 1)
        check(after.toPlainText() == "AB" && after.cellAt(1, 0).style.foreground == Color.Blue, "Style notification refreshes existing paint attributes")
        check(focused.isFocused() && target.isValid() && !target.isEnabled() && callbacks[0] == 0, "notification preserves focus/identity/eligibility and invokes no input callback")
    } finally { app.dispose() }
    check(app.stats().mountedNodes == 0 && app.stats().subscriptions == 0, "proof cleanup")
    println("ACCEPTED_PUBLIC_NOTIFY_STYLE_PASS")
    0
}

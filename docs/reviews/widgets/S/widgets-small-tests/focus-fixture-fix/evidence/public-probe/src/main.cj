package focus_boundary_public_probe

import cjtui.{Application, Column, Text}

func check(value: Bool, name: String): Unit {
    if (!value) { throw Exception(name) }
}

main(): Int64 {
    let root = Column { Text("A").focusable(true); Text("B").focusable(true) }
    let app = Application(root)
    app.startHeadless()
    let children = root.reference().getOrThrow().children()
    check(children[0].isFocused() && !children[1].isFocused(), "accepted initial eligible focus")
    app.batch({ => children[1].requestFocus() })
    check(children[1].isFocused() && !children[0].isFocused(), "batch boundary commits requested focus before any dispatch")
    check(app.focusedNode().getOrThrow().sameNode(children[1]), "public focus identity matches requested target")
    app.dispose()
    println("PUBLIC_TEXT_BATCH_FOCUS_PRECONDITION_PASS")
    0
}

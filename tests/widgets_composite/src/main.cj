package widgets_composite

import cjtui.*

// Normal cross-package consumer. Its build is gated until the accepted product
// API exists; no local stand-in declarations or private imports are permitted.
func check(ok: Bool, message: String): Unit {
    if (!ok) { throw Exception(message) }
}

func publicShapes(): Unit {
    let a = MenuEntry("a", "Alpha")
    let b = MenuEntry("b", "Beta", enabled: false)
    check(a.key == "a" && a.label == "Alpha" && a.enabled, "M01 default immutable entry")
    check(!b.enabled, "M01 named enabled")
    let horizontal = HorizontalMenu([a, b], { _ => () })
    let popup = PopupMenu({ => [a, b] }, { _ => () })
    let bar = StatusBar { Text("ready") }
    let split = SplitPane { Text("L"); Text("R") }
    let vertical = SplitPane(axis: SplitAxis.Vertical) { Text("U"); Text("D") }
    check(horizontal.reference().isNone() && popup.reference().isNone() &&
        bar.reference().isNone() && split.reference().isNone() && vertical.reference().isNone(),
        "M01/M04 ordinary unmounted public roots")
}

func statusAndSplitFrames(): Unit {
    let single = Column { StatusBar { Text("OK") }; Text("Z") }
    check(render(single, 4, 2).toPlainText() == "OK  \nZ   ", "M04 natural row leaves next row")
    let empty = Column { StatusBar {}; Text("Z") }
    check(render(empty, 4, 2).toPlainText() == "Z   \n    ", "M04 empty natural row is zero")
    let multiline = Column { StatusBar { Text("A\nB") }; Text("Z") }
    check(render(multiline, 4, 3).toPlainText() == "A   \nB   \nZ   ", "M04 multiline row uses two rows")
    let clipped = Column { StatusBar { Text("A\nB") }.height(1); Text("Z") }
    check(render(clipped, 4, 3).toPlainText() == "A   \nZ   \n    ", "M04 explicit height wins")
    let horizontal = SplitPane { Text("A").layoutWeight(1); Text("B").layoutWeight(1) }
    check(render(horizontal, 5, 1).toPlainText() == "A  B ", "M04 odd width remainder first")
    let vertical = SplitPane(axis: SplitAxis.Vertical) {
        Text("A").layoutWeight(1)
        Text("B").layoutWeight(1)
    }
    check(render(vertical, 1, 5).toPlainText() == "A\n \n \nB\n ", "M04 odd height remainder first")
    check(render(horizontal, 0, 0).toPlainText() == "", "M04 zero viewport")
}

main(): Int64 {
    publicShapes()
    statusAndSplitFrames()
    menuIdentityAndNavigation()
    popupOwnership()
    println("TASK158 public consumer: M01/M04 smoke passed")
    0
}

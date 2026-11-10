package widgets_composite

import cjtui.*

// These cases bind to actual public Runtime A/B/C and menu APIs after admission.
// No synthetic focus tree, overlay, decoder, or business-state copy is used.
func mounted(component: Component): NodeRef { component.reference().getOrThrow() }

class Box<T> {
    var value: T
    init(value: T) { this.value = value }
}

func menuIdentityAndNavigation(): Unit {
    let items = Observable<Array<MenuEntry>>([
        MenuEntry("a", "Alpha"), MenuEntry("b", "Beta"), MenuEntry("c", "Gamma")
    ])
    let chosen = Box<String>("")
    let calls = Box<Int64>(0)
    let menu = HorizontalMenu({ => items.get() }, { key =>
        chosen.value = key
        calls.value++
    })
    let app = Application(menu)
    app.startHeadless()
    try {
        app.snapshot(18, 1)
        let original = mounted(menu).children()
        check(original.size == 3, "M01 three public entry refs")
        let a = original[0]
        let b = original[1]
        let c = original[2]
        app.batch({ => a.requestFocus() })
        app.batch({ => items.set([
            MenuEntry("b", "Beta2", enabled: false), MenuEntry("a", "Alpha"), MenuEntry("c", "Gamma")
        ]) })
        app.snapshot(18, 1)
        let ordered = mounted(menu).children()
        check(ordered.size == 3 && ordered[0].sameNode(b) && ordered[1].sameNode(a) && ordered[2].sameNode(c),
            "M01 retained refs in business order")
        check(app.focusedNode().getOrThrow().sameNode(a), "M01 focus retained by key")
        app.dispatch(a, KeyEvent("right", ""))
        check(app.focusedNode().getOrThrow().sameNode(c), "M02 right skips disabled b")
        app.dispatch(c, KeyEvent("right", ""))
        check(app.focusedNode().getOrThrow().sameNode(a), "M02 right wraps")
        app.dispatch(a, KeyEvent("end", ""))
        check(app.focusedNode().getOrThrow().sameNode(c), "M02 End last eligible")
        app.dispatch(c, KeyEvent("enter", ""))
        check(chosen.value == "c" && calls.value == 1, "M02 one callback with stable key")
        check(items.get()[0].key == "b" && items.get()[0].label == "Beta2", "M01 source unchanged")
    } finally { app.dispose() }
}

func popupOwnership(): Unit {
    let trigger = Text("open").focusable(true)
    let root = Column { trigger }
    let app = Application(root)
    app.startHeadless()
    try {
        app.batch({ => mounted(trigger).requestFocus() })
        let chosen = Box<String>("")
        let popup = PopupMenu([MenuEntry("a", "Alpha")], { key => chosen.value = key })
        let handle = mounted(trigger).openOverlay(popup,
            options: OverlayOptions(mode: OverlayMode.Modal, takeFocus: true))
        app.snapshot(12, 3)
        let entry = mounted(popup).children()[0]
        app.dispatch(entry, KeyEvent("enter", ""))
        check(chosen.value == "a" && handle.isOpen(), "M03 choose does not auto-close")
        app.batch({ => handle.close() })
        check(!handle.isOpen() && app.focusedNode().getOrThrow().sameNode(mounted(trigger)),
            "M03 explicit business close restores trigger")
    } finally { app.dispose() }
}

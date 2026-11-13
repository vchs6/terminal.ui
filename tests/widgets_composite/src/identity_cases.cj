package widgets_composite

import cjtui.*

// Breaks caught: mutable/trimmed keys, missing caption validation, duplicate
// registration, stale ListItem capture, rebuilt identities, resurrected refs.
func entryAndShapes(): Unit {
    let entry = MenuEntry(" a ", "界")
    check(entry.key == " a " && entry.label == "界" && entry.enabled, "M01 exact key/default enabled")
    check(!MenuEntry("a", "", enabled: false).enabled, "M01 explicit disabled/empty caption")
    expectCode({ => MenuEntry("", "a"); () }, "InvalidKey")
    for (caption in ["a\nb", "a\rb", "a\tb", "a\u{1b}b", "a\u{2028}b", "a\u{2029}b"]) {
        var rejected = false
        try { MenuEntry("a", caption) } catch (_: IllegalArgumentException) { rejected = true }
        check(rejected, "M01 caption controls rejected")
    }
    equal(render(HorizontalMenu([MenuEntry("a", "A"), MenuEntry("b", "B")], {_ => ()}), 4, 1).toPlainText(),
        "AB  ", "M01 constant horizontal")
    equal(render(PopupMenu({ => [MenuEntry("a", "A"), MenuEntry("b", "B")] }, {_ => ()}), 4, 2).toPlainText(),
        "A   \nB   ", "M01 getter popup")
    equal(render(HorizontalMenu([MenuEntry("u", "界")], {_ => ()}), 1, 1).toPlainText(), " ", "M01 whole Unicode clip")
    let root = Column {
        HorizontalMenu([MenuEntry("h", "H")], {_ => ()})
        PopupMenu([MenuEntry("p", "P")], {_ => ()})
        StatusBar { Text("S") }
        SplitPane { Text("L"); Text("R") }
        SplitPane(axis: SplitAxis.Vertical) { Text("V") }.height(1)
    }
    let app = Application(root)
    app.startHeadless()
    try { check(mounted(root).children().size == 5, "M01/M04 collector registers exactly one root per factory") }
    finally { app.dispose() }
}

func menuIdentity(): Unit {
    let source = Observable<Array<MenuEntry>>([MenuEntry("a", "A"), MenuEntry("b", "B"), MenuEntry("c", "C")])
    let selected = [""]
    let menu = HorizontalMenu({ => source.get() }, { key => selected[0] = key })
    let app = Application(menu)
    app.startHeadless()
    try {
        app.snapshot(12, 1)
        let original = mounted(menu).children()
        check(original.size == 3, "M01 three own entries")
        let a = original[0]; let b = original[1]; let c = original[2]
        focus(app, a)
        let replacement = [MenuEntry("b", "Beta2", enabled: false), MenuEntry("a", "Alpha2"), MenuEntry("c", "C")]
        app.batch({ => source.set(replacement) })
        let ordered = mounted(menu).children()
        check(ordered[0].sameNode(b) && ordered[1].sameNode(a) && ordered[2].sameNode(c), "M01 same-key replace/reorder refs")
        focused(app, a, "M01 reorder retains focused identity")
        check(!b.isEnabled() && a.isEnabled(), "M01 latest enabled from retained value")
        equal(app.snapshot(12, 1).toPlainText(), "Beta2Alpha2C", "M01 latest label from retained value")
        app.dispatch(a, KeyEvent("enter"))
        equal(selected[0], "a", "M01 callback stable key, not label")
        check(replacement[0].key == "b" && replacement[1].key == "a" && replacement[2].key == "c", "M01 caller array unmodified")
        app.batch({ => source.set([MenuEntry("b", "B"), MenuEntry("c", "C")]) })
        check(!a.isValid() && b.isValid() && c.isValid(), "M01 remove invalidates only removed ref")
        app.batch({ => source.set([MenuEntry("a", "Again"), MenuEntry("b", "B"), MenuEntry("c", "C")]) })
        let again = mounted(menu).children()[0]
        check(again.isValid() && !again.sameNode(a) && !a.isValid(), "M01 readd has new generation")
        focus(app, again)
        app.batch({ => source.set([MenuEntry("a", "Again", enabled: false), MenuEntry("b", "B"), MenuEntry("c", "C")]) })
        check(!again.isEnabled() && !again.isFocused(), "M01 disable focused item invokes public repair")
    } finally { app.dispose() }
    clean(app)
    let chosen = [""]
    let twins = HorizontalMenu([MenuEntry("a", "same"), MenuEntry("b", "same")], { key => chosen[0] = key })
    let twinApp = Application(twins)
    twinApp.startHeadless()
    try {
        let refs = mounted(twins).children()
        check(!refs[0].sameNode(refs[1]), "M01 duplicate label does not merge key identity")
        focus(twinApp, refs[1])
        twinApp.dispatch(refs[1], KeyEvent("enter"))
        equal(chosen[0], "b", "M01 duplicate label requests stable key")
    } finally { twinApp.dispose() }
    let constant = [MenuEntry("a", "A")]
    let fixed = HorizontalMenu(constant, {_ => ()})
    constant[0] = MenuEntry("b", "B")
    equal(render(fixed, 1, 1).toPlainText(), "A", "M01 constant overload copies caller array")
}

func duplicateBatch(): Unit {
    let source = Observable<Array<MenuEntry>>([MenuEntry("a", "A")])
    let menu = HorizontalMenu({ => source.get() }, {_ => ()})
    let cleanups = [0]
    let root = Column { menu }.onMount({ _ => { => cleanups[0]++ } })
    let app = Application(root)
    app.startHeadless()
    let previous = mounted(menu).children()[0]
    let invalid = [MenuEntry("new", "N"), MenuEntry("dup", "D"), MenuEntry("dup", "E")]
    expectCode({ => app.batch({ => source.set(invalid) }) }, "DuplicateKey")
    check(invalid.size == 3 && invalid[0].key == "new" && invalid[2].label == "E", "M01 rejected batch leaves source unchanged")
    check(!previous.isValid() && cleanups[0] == 1, "M01 failed batch cleans old tree once")
    clean(app)
    app.dispose()
    check(cleanups[0] == 1, "M01 disposal after failure is idempotent")
}

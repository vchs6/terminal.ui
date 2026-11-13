package widgets_composite

import cjtui.*

// Breaks caught: role omitted/incorrect, explicit Default background defeating
// popup color, priority reversal, model copies, ref reuse across instances,
// lost errors, leaked subscriptions, callbacks executed more than once.
func localTheme(): Unit {
    let theme = Theme.readFile("fixtures/local-theme.toml")
    let horizontal = HorizontalMenu([MenuEntry("a", "A"), MenuEntry("b", "B", enabled: false)], {_ => ()})
    let app = Application(horizontal, theme: theme)
    app.startHeadless()
    try {
        let frame = app.snapshot(4, 1)
        check(frame.cellAt(3, 0).style == Style(foreground: Color.Red, background: Color.Black), "M05 HorizontalMenu root role fills exact Style")
        check(frame.cellAt(0, 0).style == Style(foreground: Color.Blue, background: Color.Black), "M05 focused MenuItem exact Style includes inherited fields")
        check(frame.cellAt(1, 0).style == Style(foreground: Color.Red, background: Color.Black), "M05 disabled MenuItem exact Style overrides Classic dim")
    } finally { app.dispose() }
    let bar = StatusBar { Text("S") }.styles([StyleUse.Named("reused")]).foreground(Color.Red)
    let styled = Application(bar, theme: theme)
    styled.startHeadless()
    try { check(styled.snapshot(2, 1).cellAt(0, 0).style == Style(foreground: Color.Red, background: Color.Black),
        "M05 explicit beats reusable beats theme") }
    finally { styled.dispose() }
    let reused = Application(StatusBar { Text("S") }.styles([StyleUse.Named("reused")]), theme: theme)
    reused.startHeadless()
    try { check(reused.snapshot(1, 1).cellAt(0, 0).style == Style(foreground: Color.Green, background: Color.Black), "M05 reusable beats StatusBar theme") }
    finally { reused.dispose() }
    let status = Application(StatusBar { Text("S") }, theme: theme)
    status.startHeadless()
    try { check(status.snapshot(1, 1).cellAt(0, 0).style == Style(foreground: Color.Yellow, background: Color.Black), "M05 StatusBar theme role") }
    finally { status.dispose() }
    let split = Application(SplitPane { Text("L"); Text("R") }, theme: theme)
    split.startHeadless()
    try { check(split.snapshot(2, 1).cellAt(0, 0).style == Style(foreground: Color.Magenta, background: Color.Black), "M05 SplitPane theme role") }
    finally { split.dispose() }
    let triggerSlot = Array<?Component>(1, repeat: Option<Component>.None)
    let root = Column {
        triggerSlot[0] = Some(Text("abcdefgh").focusable(true))
        Text("ijklmnop")
        Text("qrstuvwx")
    }
    let trigger = triggerSlot[0].getOrThrow()
    let base = Application(root, theme: theme)
    base.startHeadless()
    try {
        base.snapshot(8, 3)
        let popup = PopupMenu([MenuEntry("a", "X")], {_ => ()}).width(3).height(1)
        let handle = open(base, mounted(trigger), popup, OverlayOptions(mode: OverlayMode.NonModal))
        let frame = base.snapshot(8, 3)
        equal(frame.toPlainText(), "abcdefgh\nijX  nop\nqrstuvwx", "M05 real popup themed opaque frame")
        check(frame.cellAt(3, 1).style == Style(foreground: Color.Green, background: Color.Blue), "M05 popup blank uses role fields and preserves theme background")
        check(handle.isOpen(), "M05 observing role does not alter overlay")
    } finally { base.dispose() }
    // Color-only overrides deliberately leave Classic focused underline intact.
    let inheritance = Theme.parse("schema_version = 1\nname = \"color-only\"\n[components.menu_item.states.focused.text]\nforeground = \"red\"\n")
    let inherited = Application(HorizontalMenu([MenuEntry("a", "A")], {_ => ()}), theme: inheritance)
    inherited.startHeadless()
    try { check(inherited.snapshot(1, 1).cellAt(0, 0).style == Style(foreground: Color.Red, underline: true), "M05 Classic focused underline inheritance remains exact") }
    finally { inherited.dispose() }
}

func sharedPanels(): Unit {
    let model = Observable<String>("old")
    let firstSlot = Array<?Component>(1, repeat: Option<Component>.None)
    let root = SplitPane(axis: SplitAxis.Vertical) { firstSlot[0] = Some(SharedPanel(model)) }
    let first = firstSlot[0].getOrThrow()
    let second = SharedPanel(model).width(8).height(4)
    let app = Application(root)
    app.startHeadless()
    try {
        equal(app.snapshot(8, 4).toPlainText(), "A       \nold     \nold     \n        ", "M05 first composed panel")
        let firstRef = mounted(first)
        let layer = open(app, firstRef, second, OverlayOptions(mode: OverlayMode.Modal))
        check(!firstRef.sameNode(mounted(second)), "M05 two instances have distinct refs")
        check(mounted(second).application().focusedNode().getOrThrow().sameNode(app.focusedNode().getOrThrow()) &&
            firstRef.application().focusedNode().getOrThrow().sameNode(app.focusedNode().getOrThrow()), "M05 one Application for ordinary and layer instances")
        app.batch({ => model.set("new") })
        equal(app.snapshot(8, 4).toPlainText(), "A       \nnew     \nnew     \n        ", "M05 both panel instances display latest shared model")
        let overlayEntry = mounted(second).children()[0].children()[0]
        focus(app, overlayEntry)
        app.dispatch(overlayEntry, KeyEvent("enter"))
        equal(model.get(), "latest", "M05 overlay instance updates common model")
        app.batch({ => layer.close() })
        equal(app.snapshot(8, 4).toPlainText(), "A       \nlatest  \nlatest  \n        ", "M05 closing overlay exposes latest inline instance")
        let posted = spawn { => app.post(firstRef, { => model.set("post") }) }
        check(posted.get(), "M05 owner worker post accepted")
        equal(app.snapshot(8, 4).toPlainText(), "A       \npost    \npost    \n        ", "M05 posted state updates composed panel")
        app.snapshot(1, 1)
        app.snapshot(0, 0)
        check(firstRef.isVisible(), "M05 narrow/zero does not hide business panel")
    } finally { app.dispose() }
    clean(app)
    equal(model.get(), "post", "M05 business data survives disposal")
    let again = Application(first)
    again.startHeadless()
    try { check(mounted(first).isValid(), "M05 reusable component remount") }
    finally { again.dispose() }
    clean(again)
}

func callbackRecovery(): Unit {
    let calls = [0]; let cleanups = [0]
    let menu = PopupMenu([MenuEntry("a", "A")], {_ => calls[0]++; throw Exception("M_CALLBACK_SENTINEL") })
        .onMount({ _ => { => cleanups[0]++ } })
    let app = Application(menu)
    app.startHeadless()
    let stale = mounted(menu).children()[0]
    focus(app, stale)
    var caught = false
    try { app.dispatch(stale, KeyEvent("enter")) }
    catch (error: Exception) { caught = error.message.contains("M_CALLBACK_SENTINEL") }
    check(caught && calls[0] == 1 && cleanups[0] == 1 && !stale.isValid(), "M05 callback first error/once cleanup/old ref invalid")
    clean(app)
    app.dispose()
    check(cleanups[0] == 1, "M05 failure cleanup idempotent")
    let source = Observable<Array<MenuEntry>>([MenuEntry("a", "A")])
    let getter = HorizontalMenu({ =>
        let items = source.get()
        if (items[0].key == "bad") { throw Exception("M_GETTER_SENTINEL") }
        items
    }, {_ => ()})
    let failed = Application(getter)
    failed.startHeadless()
    caught = false
    try { failed.batch({ => source.set([MenuEntry("bad", "Bad")]) }) }
    catch (error: Exception) { caught = error.message.contains("M_GETTER_SENTINEL") }
    check(caught && source.get()[0].key == "bad", "M05 getter error and business data preserved")
    clean(failed)
    let fresh = Application(HorizontalMenu([MenuEntry("r", "Recovered")], {_ => ()}))
    fresh.startHeadless()
    try { equal(fresh.snapshot(9, 1).toPlainText(), "Recovered", "M05 fresh application recovers after failures") }
    finally { fresh.dispose() }
}

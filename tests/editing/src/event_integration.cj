package editing_contract
import cjtui.*

// Catches replacement of the shared default pipeline, double scrolling and stop behaving like prevent.
func eventIntegration(): Unit {
    let c = TextEditController(); let trace = Box<String>(""); let mode = Box<String>("normal")
    let targetBox = Box<?Component>(Option<Component>.None)
    let parent = Column {
        targetBox.value = Some(TextInput(Observable<String>(""), controller: Some(c),
            onChange: {_ => trace.value += "edit;"})
            .onKeyCapture({_ => trace.value += "Tc;"})
            .onKey({e => trace.value += "Tb;"; if (mode.value == "stop") { e.stopPropagation() }
                if (mode.value == "prevent") { e.preventDefault() }})
            .defaultAction({_ => trace.value += "TA;"}, phase: DefaultActionPhase.Ancestor))
    }.onKeyCapture({_ => trace.value += "Pc;"}).onKey({_ => trace.value += "Pb;"})
        .defaultAction({_ => trace.value += "PA;"}, phase: DefaultActionPhase.Ancestor)
    let app = Application(parent).onKeyEvent({_ => trace.value += "app;"}).onKey({_ => trace.value += "legacy;"})
    app.startHeadless()
    try {
        let node = targetBox.value.getOrThrow()
        key(app, node, "text", text: "a")
        check(trace.value == "Pc;Tc;Tb;Pb;app;legacy;edit;", "target editor prevents later ancestor defaults")
        mode.value = "prevent"; trace.value = ""
        key(app, node, "text", text: "b")
        check(trace.value == "Pc;Tc;Tb;Pb;app;legacy;", "prevent suppresses all defaults")
        mode.value = "stop"; trace.value = ""
        key(app, node, "text", text: "c")
        check(trace.value == "Pc;Tc;Tb;edit;" && c.snapshot().text == "ac", "stop still edits target")
        trace.value = ""
        illegal({ => key(app, node, "paste", text: "x", ctrl: true) })
        check(trace.value == "" && c.isValid(), "invalid reserved dispatch has no side effects/session cleanup")
    } finally { app.dispose() }
    let area = Box<?Component>(Option<Component>.None); let ctl = TextEditController(); let sibling = Box<?Component>(Option<Component>.None)
    let outer = Column {
        area.value = Some(TextArea(Observable<String>("0\n1\n2\n3\n4\n5"), controller: Some(ctl)).height(2))
        sibling.value = Some(TextInput(Observable<String>("s")))
        Text("tail\ntail\ntail")
    }.viewport(ScrollAxes.Vertical)
    let a = Application(outer, theme: plainTheme()); a.startHeadless()
    try {
        a.snapshot(3, 3)
        key(a, area.value.getOrThrow(), "pagedown")
        state(ctl, "0\n1\n2\n3\n4\n5", 2, 2, false, false, "editor height2 PageDown moves1 line")
        a.snapshot(3, 3)
        check(ref(outer).viewportSnapshot().offsetY == 0, "target PageDown does not scroll ancestor")
        ui(a, { => ctl.select(TextSelection(10, 10)) })
        key(a, area.value.getOrThrow(), "pagedown"); a.snapshot(3, 3)
        check(ref(outer).viewportSnapshot().offsetY == 0, "boundary PageDown still consumed")
        key(a, area.value.getOrThrow(), "tab")
        check(ref(sibling.value.getOrThrow()).isFocused(), "Tab leaves editor via framework")
        key(a, sibling.value.getOrThrow(), "backtab", shift: true)
        check(ref(area.value.getOrThrow()).isFocused(), "ShiftTab restores previous editor")
    } finally { a.dispose() }
    let single = Box<?Component>(Option<Component>.None); let scroll = Column {
        single.value = Some(TextInput(Observable<String>("x")).height(1))
        Text("a\nb\nc\nd")
    }.viewport(ScrollAxes.Vertical)
    let scrollApp = Application(scroll, theme: plainTheme()); scrollApp.startHeadless()
    try {
        scrollApp.snapshot(3, 2)
        key(scrollApp, single.value.getOrThrow(), "down"); scrollApp.snapshot(3, 2)
        check(ref(scroll).viewportSnapshot().offsetY == 1, "single-line down delegates once to ancestor viewport")
        key(scrollApp, single.value.getOrThrow(), "up"); scrollApp.snapshot(3, 2)
        check(ref(scroll).viewportSnapshot().offsetY == 0, "single-line up delegates once")
        let popupCtl = TextEditController(); let popup = TextInput(Observable<String>("modal"), controller: Some(popupCtl))
        let handle = ui(scrollApp, { => ref(scroll).openOverlay(popup, options: OverlayOptions(mode: OverlayMode.Modal)) })
        scrollApp.snapshot(6, 2)
        key(scrollApp, popup, "escape")
        check(!handle.isOpen() && !popupCtl.isValid() && ref(single.value.getOrThrow()).isFocused(),
            "Escape remains framework modal-close and focus restore")
    } finally { scrollApp.dispose() }
}

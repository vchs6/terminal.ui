package editing_contract
import cjtui.*

// Catches no-selection copy consuming CtrlC, cut fallback to business delete, and synthetic paste.
func clipboardDefaults(): Unit {
    let c = TextEditController(); let issues = Box<Int64>(0); let changes = Box<Int64>(0)
    let root = TextInput(Observable<String>("abc"), controller: Some(c),
        onIssue: {_ => issues.value++}, onChange: {_ => changes.value++})
    let app = Application(root); app.startHeadless()
    try {
        for (keyValue in [KeyEvent("insert", ctrl: true), KeyEvent("x", ctrl: true), KeyEvent("delete", shift: true)]) {
            app.dispatch(ref(root), keyValue)
        }
        check(issues.value == 0 && changes.value == 0, "empty-selection copy/cut no output issue/history")
        state(c, "abc", 0, 0, false, false, "empty shortcut no op")
        ui(app, { => c.select(TextSelection(0, 2)) })
        key(app, root, "interrupt", ctrl: true)
        check(c.isValid() && issues.value == 1 && changes.value == 0, "selected CtrlC copies without exit")
        key(app, root, "insert", ctrl: true)
        key(app, root, "x", ctrl: true)
        key(app, root, "delete", shift: true)
        check(issues.value == 4 && changes.value == 0, "unsupported shortcut once each")
        state(c, "abc", 0, 2, false, false, "unconfirmed shortcut cuts retain selection")
        let saved = c.snapshot()
        check(app.post({ =>
            c.select(TextSelection(2, 2)); c.select(TextSelection(0, 2))
            check(!c.replaceSelection("", ifUnchanged: Some(saved)), "posted move-away-back cancels delayed guard")
        }), "delayed application consumption queued")
        app.snapshot(4, 1)
        check(issues.value == 4 && changes.value == 0, "guard mismatch no implicit issue or change")
        let textGuard = c.snapshot()
        check(app.post({ =>
            c.replaceSelection("Z")
            let after = c.snapshot()
            check(!c.replaceSelection("BAD", ifUnchanged: Some(textGuard)), "posted changed text cancels guard")
            check(c.snapshot().text == "Zc" && c.snapshot().revision == after.revision,
                "failed posted guard itself leaves local history intact")
        }), "changed text result queued")
        app.snapshot(4, 1)
        check(changes.value == 1 && issues.value == 4, "one posted real edit")
        ui(app, { => c.select(TextSelection(0, 0)) })
        key(app, root, "interrupt", ctrl: true)
        check(!c.isValid(), "unselected CtrlC follows framework interrupt exit")
    } finally { app.dispose() }
}

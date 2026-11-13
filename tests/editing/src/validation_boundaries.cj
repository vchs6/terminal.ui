package editing_contract
import cjtui.*

// Catches scalar-vs-byte limits, incomplete validation and text truncation for history budgets.
func validationBoundaries(): Unit {
    for (make in [{ => TextEditLimits(maxTextBytes: -1) }, { => TextEditLimits(maxUndoEntries: 0) },
        { => TextEditLimits(maxUndoEntries: -1) }, { => TextEditLimits(maxUndoBytes: 0) },
        { => TextEditLimits(maxUndoBytes: -1) }]) { illegal({ => make(); () }) }
    for (bad in ["a\rb", "a\nb", "a\tb", "a\u{1b}b"]) {
        let original = Observable<String>(bad); let c = TextEditController(); var caught = false
        try { let a = Application(TextInput(original, controller: Some(c))); a.startHeadless(); a.dispose() }
        catch (_: Exception) { caught = true }
        check(caught && original.get() == bad && !c.isValid(), "invalid initial value diagnosed without normalization")
    }
    let c = TextEditController(); let value = Observable<String>("中"); let changes = Box<Int64>(0); let issues = Box<Int64>(0)
    let root = TextInput(value, controller: Some(c), limits: TextEditLimits(maxTextBytes: 4),
        onChange: {_ => changes.value++}, onIssue: {issue => check(issue == TextEditIssue.ControlCharacterRejected ||
            issue == TextEditIssue.InputTooLarge, "validation issue kind"); issues.value++})
    let app = Application(root); app.startHeadless()
    try {
        ui(app, { => c.select(TextSelection(1, 1)) })
        key(app, root, "text", text: "x")
        state(c, "中x", 2, 2, true, false, "4-byte boundary accepted")
        let before = c.snapshot()
        key(app, root, "paste", text: "y")
        exact(c, "中x", 2, 2, before.revision, before.selectionRevision, "5-byte boundary atomic")
        for (scalar in 0..32) {
            if (scalar != 10 && scalar != 13) {
                key(app, root, "paste", text: String.fromUtf8([UInt8(scalar)]))
            }
        }
        key(app, root, "paste", text: "\u{7f}")
        for (scalar in 0x80..0xa0) {
            key(app, root, "paste", text: String.fromUtf8([0xc2u8, UInt8(scalar)]))
        }
        // 30 C0 excluding LF/CR + DEL + 32 C1 + one size rejection.
        check(issues.value == 64 && changes.value == 1, "all C0/DEL/C1 rejected once")
        state(c, "中x", 2, 2, true, false, "all invalid pastes preserve history")
    } finally { app.dispose() }
    let byteCtl = TextEditController(); let bytes = Observable<String>(ascii(1048575))
    let byteRoot = TextInput(bytes, controller: Some(byteCtl),
        limits: TextEditLimits(maxTextBytes: 2097152, maxUndoBytes: 2097152))
    let byteApp = Application(byteRoot); byteApp.startHeadless()
    try {
        ui(byteApp, { => byteCtl.select(TextSelection(1048575, 1048575)); byteCtl.replaceSelection("yy") })
        check(bytes.get() == ascii(1048575) + "yy" && byteCtl.snapshot().canUndo,
            "exact 2MiB before+after record retained")
        check(ui(byteApp, { => byteCtl.undo() }) && !byteCtl.snapshot().canUndo && byteCtl.snapshot().canRedo,
            "exact byte record transfers to redo")
        check(ui(byteApp, { => byteCtl.redo() }), "exact byte redo retained")
    } finally { byteApp.dispose() }
    let h = TextEditController(); let hRoot = TextInput(Observable<String>(""), controller: Some(h),
        limits: TextEditLimits(maxUndoEntries: 3, maxUndoBytes: 12))
    let hApp = Application(hRoot); hApp.startHeadless()
    try {
        for (text in ["aa", "bbbb", "cc"]) { ui(hApp, { => h.selectAll(); h.replaceSelection(text) }) }
        check(ui(hApp, { => h.undo() }), "budget newest undo")
        state(h, "bbbb", 0, 4, true, true, "6+6 bytes split across undo+redo")
        check(ui(hApp, { => h.undo() }), "budget second undo")
        state(h, "aa", 0, 2, false, true, "oldest whole 2-byte record evicted")
        check(!ui(hApp, { => h.undo() }), "combined byte budget leaves no half record")
        check(ui(hApp, { => h.redo() }) && ui(hApp, { => h.redo() }), "both budget records redo")
        state(h, "cc", 2, 2, true, false, "redo moves entries without changing aggregate budget")
    } finally { hApp.dispose() }
    areaEnterAtTextLimit()
}

// E002: ordinary TextArea Enter is an atomic LF insertion subject to byte limits.
func areaEnterAtTextLimit(): Unit {
    let value = Observable<String>("x"); let ctl = TextEditController()
    let changes = Box<Int64>(0); let issues = Box<Int64>(0); let tooLarge = Box<Int64>(0)
    let area = TextArea(value, controller: Some(ctl), limits: TextEditLimits(maxTextBytes: 1),
        onChange: {_ => changes.value++}, onIssue: { issue =>
            issues.value++; if (issue == TextEditIssue.InputTooLarge) { tooLarge.value++ }
        })
    let app = Application(area); app.startHeadless()
    try {
        ui(app, { => ctl.select(TextSelection(1, 1)) })
        exact(ctl, "x", 1, 1, 0, 1, "literal x at byte limit before Enter")
        check(!ctl.snapshot().canUndo && !ctl.snapshot().canRedo, "initial limit-case history empty")
        key(app, area, "enter")
        exact(ctl, "x", 1, 1, 0, 1, "rejected LF preserves text/selection/both revisions")
        state(ctl, "x", 1, 1, false, false, "rejected LF creates no undo/redo record")
        check(value.get() == "x" && changes.value == 0 && issues.value == 1 && tooLarge.value == 1,
            "ordinary Enter at maxTextBytes1 rejects once as InputTooLarge with no onChange")
        check(ctl.isValid() && ref(area).isValid() && app.post({ => }),
            "rejected Enter leaves the application healthy")
    } finally { app.dispose() }
}

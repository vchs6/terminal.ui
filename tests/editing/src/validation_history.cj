package editing_contract

import cjtui.*
import std.collection.ArrayList

func validationAndHistory(): Unit {
    let value = Observable<String>("ab")
    let ctl = TextEditController()
    let changes = ArrayList<String>()
    let issues = ArrayList<TextEditIssue>()
    let submits = Box<Int64>(0)
    let root = TextInput(value, controller: Some(ctl),
        limits: TextEditLimits(maxTextBytes: 6, maxUndoEntries: 2, maxUndoBytes: 24),
        onChange: { text => changes.add(text) },
        onSubmit: { _ => submits.value++ },
        onIssue: { issue => issues.add(issue) })
    let app = Application(root)
    app.startHeadless()
    try {
        ui(app, { => ctl.select(TextSelection(2, 2)) })
        key(app, root, "paste", text: "x\ny")
        state(ctl, "ab", 2, 2, false, false, "single line LF paste rejected atomically")
        check(issues.size == 1 && issues[0] == TextEditIssue.MultilinePasteRejected,
            "one multiline issue")
        key(app, root, "paste", text: "x\ty")
        state(ctl, "ab", 2, 2, false, false, "HT paste rejected atomically")
        check(issues.size == 2 && issues[1] == TextEditIssue.ControlCharacterRejected,
            "one control issue")
        key(app, root, "paste", text: "x\u{1b}y")
        state(ctl, "ab", 2, 2, false, false, "ESC paste rejected atomically")
        check(issues.size == 3 && issues[2] == TextEditIssue.ControlCharacterRejected,
            "ESC control issue")
        key(app, root, "paste", text: "12345")
        state(ctl, "ab", 2, 2, false, false, "overlimit paste rejected atomically")
        check(issues.size == 4 && issues[3] == TextEditIssue.InputTooLarge,
            "one size issue")
        ui(app, { => illegal({ => ctl.replaceSelection("\u{1b}"); () }) })
        state(ctl, "ab", 2, 2, false, false, "bad program edit no side effects")
        check(changes.size == 0 && submits.value == 0, "all rejects have no onChange/onSubmit")

        check(ui(app, { => ctl.replaceSelection("c") }), "first transaction")
        state(ctl, "abc", 3, 3, true, false, "first transaction result")
        check(ui(app, { => ctl.replaceSelection("d") }), "second transaction")
        check(ui(app, { => ctl.replaceSelection("e") }), "third transaction")
        state(ctl, "abcde", 5, 5, true, false, "three transactions")
        check(ui(app, { => ctl.undo() }), "undo newest")
        state(ctl, "abcd", 4, 4, true, true, "undo e")
        check(ui(app, { => ctl.undo() }), "undo second")
        state(ctl, "abc", 3, 3, false, true, "oldest evicted by entry budget")
        check(!ui(app, { => ctl.undo() }), "third undo unavailable")
        check(ui(app, { => ctl.redo() }), "redo second")
        state(ctl, "abcd", 4, 4, true, true, "redo d")
        ui(app, { => ctl.selectAll() })
        let before = ctl.snapshot()
        check(!ui(app, { => ctl.replaceSelection("abcd") }), "same-text selection collapse is a no-op textwise")
        state(ctl, "abcd", 4, 4, true, true, "redo retained on same-text collapse")
        check(ctl.snapshot().revision == before.revision &&
            ctl.snapshot().selectionRevision == before.selectionRevision + 1,
            "same-text collapse only selection revision")
        check(ui(app, { => ctl.redo() }), "redo e after selection collapse")
        state(ctl, "abcde", 5, 5, true, false, "redo after collapse")

        let rev = ctl.snapshot().revision
        value.notify()
        app.batch({ => })
        check(ctl.snapshot().revision == rev + 1 && !ctl.snapshot().canUndo &&
            !ctl.snapshot().canRedo, "external same-value notify clears history")
        check(changes.size == 7, "only successful edits and undo/redo notify")
    } finally { app.dispose() }

    let multi = Observable<String>("A")
    let edit = TextEditController()
    let area = TextArea(multi, controller: Some(edit))
    let session = Application(area)
    session.startHeadless()
    try {
        ui(session, { => edit.select(TextSelection(1,1)) })
        key(session, area, "paste", text: "\r\nB\rC")
        state(edit, "A\nB\nC", 5, 5, true, false, "CRLF and CR normalize to LF")
        check(ui(session, { => edit.undo() }), "whole paste one undo")
        state(edit, "A", 1, 1, false, true, "one undo restores text and selection")
        check(ui(session, { => edit.redo() }), "whole paste one redo")
        state(edit, "A\nB\nC", 5, 5, true, false, "redo restores normalized paste")
    } finally { session.dispose() }

    let countValue = Observable<String>("")
    let bounded = TextEditController()
    let countRoot = TextInput(countValue, controller: Some(bounded))
    let countApp = Application(countRoot)
    countApp.startHeadless()
    try {
        for (i in 0..129) { key(countApp, countRoot, "text", text: "x") }
        check(bounded.snapshot().text.size == 129, "129 one-byte transactions")
        for (i in 0..128) { check(ui(countApp, { => bounded.undo() }), "each of 128 entries retained") }
        state(bounded, "x", 1, 1, false, true, "oldest of 129 entries evicted")
        check(!ui(countApp, { => bounded.undo() }), "default 128-entry budget exact boundary")
    } finally { countApp.dispose() }

    var million = "x"
    for (i in 0..20) { million += million }
    check(million.size == 1048576, "independent 1MiB ASCII fixture")
    let byteValue = Observable<String>(million)
    let byteCtl = TextEditController()
    let byteRoot = TextInput(byteValue, controller: Some(byteCtl),
        limits: TextEditLimits(maxTextBytes: 2097152, maxUndoBytes: 2097152))
    let byteApp = Application(byteRoot)
    byteApp.startHeadless()
    try {
        ui(byteApp, { => byteCtl.select(TextSelection(1048576, 1048576)) })
        check(ui(byteApp, { => byteCtl.replaceSelection("y") }), "over-budget history cannot truncate accepted text")
        check(byteValue.get().size == 1048577 && !byteCtl.snapshot().canUndo,
            "2MiB before+after history budget rejects whole record only")
    } finally { byteApp.dispose() }
}

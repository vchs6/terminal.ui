package editing_contract

import cjtui.*
import std.collection.ArrayList

func publicConstructors(): Unit {
    illegal({ => TextSelection(-1, 0); () })
    illegal({ => TextSelection(0, -1); () })
    illegal({ => TextEditLimits(maxTextBytes: 0); () })
    illegal({ => TextEditLimits(maxTextBytes: 16777217); () })
    illegal({ => TextEditLimits(maxUndoEntries: 65537); () })
    illegal({ => TextEditLimits(maxUndoBytes: 67108865); () })
    let limits = TextEditLimits(maxTextBytes: 4, maxUndoEntries: 2, maxUndoBytes: 20)
    check(limits.maxTextBytes == 4 && limits.maxUndoEntries == 2 && limits.maxUndoBytes == 20,
        "public limits")

    let value = Observable<String>("first")
    let controller = TextEditController()
    let changes = ArrayList<String>()
    let submits = ArrayList<String>()
    let issues = ArrayList<TextEditIssue>()
    let root = TextInput(value, controller: Some(controller),
        onChange: { text => changes.add(text) },
        onSubmit: { text => submits.add(text) },
        onIssue: { issue => issues.add(issue) })
    check(!controller.isValid(), "detached controller invalid")
    errorCode("StaleReference", { => controller.snapshot(); () })
    let app = Application(root)
    app.startHeadless()
    try {
        check(controller.isValid(), "mounted controller valid")
        let s = controller.snapshot()
        check(s.text == "first" && s.selection == TextSelection(0,0) &&
            s.revision == 0 && s.selectionRevision == 0 && !s.canUndo && !s.canRedo,
            "first mount zero state")
        check(changes.size == 0 && submits.size == 0 && issues.size == 0,
            "mount has no notifications")
        illegal({ => controller.select(TextSelection(0, 6)) })
        state(controller, "first", 0, 0, false, false, "invalid selection atomic")
        controller.selectAll()
        state(controller, "first", 0, 5, false, false, "select all")
        let r = controller.snapshot().selectionRevision
        controller.selectAll()
        check(controller.snapshot().selectionRevision == r, "idempotent selection revision")
        check(controller.replaceSelection("first") == false, "same-text replacement false")
        state(controller, "first", 5, 5, false, false, "same-text replacement collapses")
        check(controller.snapshot().revision == 0 && controller.snapshot().selectionRevision == r + 1,
            "same-text collapse changes only selection revision")
        check(changes.size == 0, "no text notification for same text")
        let guard = controller.snapshot()
        check(!controller.replaceSelection("X", ifUnchanged: Some(s)), "stale selection guard")
        state(controller, "first", 5, 5, false, false, "guard false atomic")
        check(controller.replaceSelection("!", ifUnchanged: Some(guard)), "current guard succeeds")
        state(controller, "first!", 6, 6, true, false, "guarded edit")
        check(changes.size == 1 && changes[0] == "first!", "one change after commit")
    } finally { app.dispose() }
    check(!controller.isValid(), "unmounted invalid")
    errorCode("StaleReference", { => controller.undo(); () })

    // Each factory is a normal public consumer even without a controller.
    let passive = TextArea(Observable<String>("a\nb"))
    let second = Application(passive)
    second.startHeadless()
    try { key(second, passive, "text", text: "Z") }
    finally { second.dispose() }
}

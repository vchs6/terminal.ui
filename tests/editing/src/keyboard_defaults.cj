package editing_contract

import cjtui.*
import std.collection.ArrayList

func keyboardDefaults(): Unit {
    let value = Observable<String>("ab\n中x\nyz")
    let ctl = TextEditController()
    let issues = ArrayList<TextEditIssue>()
    let area = TextArea(value, controller: Some(ctl), onIssue: { issue => issues.add(issue) })
    let app = Application(area)
    app.startHeadless()
    try {
        ctl.select(TextSelection(1,1))
        key(app, area, "end")
        state(ctl, "ab\n中x\nyz", 2, 2, false, false, "line end")
        key(app, area, "down")
        state(ctl, "ab\n中x\nyz", 4, 4, false, false, "preferred column 2 after wide 中")
        key(app, area, "down")
        state(ctl, "ab\n中x\nyz", 8, 8, false, false, "preferred column retained")
        key(app, area, "home", ctrl: true)
        state(ctl, "ab\n中x\nyz", 0, 0, false, false, "CtrlHome")
        key(app, area, "end", ctrl: true, shift: true)
        state(ctl, "ab\n中x\nyz", 0, 8, false, false, "CtrlShiftEnd extends selection")
        key(app, area, "left")
        state(ctl, "ab\n中x\nyz", 0, 0, false, false, "left collapses selection to low end")
        key(app, area, "right", shift: true)
        state(ctl, "ab\n中x\nyz", 0, 1, false, false, "ShiftRight extends")
        key(app, area, "backspace")
        state(ctl, "b\n中x\nyz", 0, 0, true, false, "selection deletion")
        key(app, area, "a", ctrl: true)
        state(ctl, "b\n中x\nyz", 0, 7, true, false, "CtrlA select all")
        key(app, area, "z", ctrl: true)
        state(ctl, "ab\n中x\nyz", 0, 1, false, true, "CtrlZ restores prior selection")
        key(app, area, "y", ctrl: true)
        state(ctl, "b\n中x\nyz", 0, 0, true, false, "CtrlY redo")
        key(app, area, "v", ctrl: true)
        check(issues.size == 1 && issues[0] == TextEditIssue.PasteFromTerminalRequired,
            "CtrlV emits one truthful issue")
        state(ctl, "b\n中x\nyz", 0, 0, true, false, "CtrlV does not paste")
        key(app, area, "insert", shift: true)
        check(issues.size == 2 && issues[1] == TextEditIssue.PasteFromTerminalRequired,
            "ShiftInsert same host boundary")
    } finally { app.dispose() }

    let input = Observable<String>("hi")
    let editor = TextEditController()
    var submits = 0
    let single = TextInput(input, controller: Some(editor), onSubmit: { text =>
        check(text == "hi", "submit sees stable text"); submits++
    })
    let singleApp = Application(single)
    singleApp.startHeadless()
    try {
        key(singleApp, single, "enter")
        check(submits == 1 && input.get() == "hi" && !editor.snapshot().canUndo,
            "single Enter submits once without edit")
    } finally { singleApp.dispose() }
}

func eventPhaseDefaults(): Unit {
    let value = Observable<String>("")
    let ctl = TextEditController()
    var mode = "prevent"
    let root = TextInput(value, controller: Some(ctl)).onKey({ event =>
        if (mode == "prevent") { event.preventDefault() }
        if (mode == "stop") { event.stopPropagation() }
    })
    let app = Application(root)
    app.startHeadless()
    try {
        key(app, root, "text", text: "a")
        state(ctl, "", 0, 0, false, false, "preventDefault suppresses target edit")
        mode = "stop"
        key(app, root, "text", text: "b")
        state(ctl, "b", 1, 1, true, false, "stopPropagation still allows target default")
    } finally { app.dispose() }
}

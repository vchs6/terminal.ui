package editing_contract

import cjtui.*

func check(ok: Bool, label: String): Unit {
    if (!ok) { throw Exception("FAIL ${label}") }
}

func errorCode(expected: String, action: () -> Unit): Unit {
    var actual = "none"
    try { action() } catch (error: UIException) { actual = error.code }
    check(actual == expected, "error ${expected}; got ${actual}")
}

func illegal(action: () -> Unit): Unit {
    var caught = false
    try { action() } catch (_: IllegalArgumentException) { caught = true }
    check(caught, "IllegalArgumentException")
}

func key(app: Application, root: Component, code: String, text!: String = "",
    ctrl!: Bool = false, shift!: Bool = false): Unit {
    app.dispatch(root.reference().getOrThrow(),
        KeyEvent(code, text: text, ctrl: ctrl, shift: shift))
}

func state(controller: TextEditController, text: String, anchor: Int64, caret: Int64,
    undo: Bool, redo: Bool, label: String): Unit {
    let s = controller.snapshot()
    check(s.text == text && s.selection == TextSelection(anchor, caret) &&
        s.canUndo == undo && s.canRedo == redo,
        "${label}: text/selection/history")
}

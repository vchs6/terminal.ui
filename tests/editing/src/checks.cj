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

// Controller mutations have the same event/post/batch permission as NodeRef.
func ui<T>(app: Application, action: () -> T): T {
    let result = Box<?T>(Option<T>.None)
    app.batch({ => result.value = Some(action()) })
    result.value.getOrThrow()
}

func ref(component: Component): NodeRef { component.reference().getOrThrow() }
func exact(controller: TextEditController, text: String, anchor: Int64, caret: Int64,
    revision: UInt64, selectionRevision: UInt64, label: String): Unit {
    let s = controller.snapshot()
    check(s.text == text && s.selection == TextSelection(anchor, caret) &&
        s.revision == revision && s.selectionRevision == selectionRevision, label)
}
func plainTheme(): Theme { Theme.parse("schema_version=1\nname=\"editing plain\"\n") }
func ascii(count: Int64): String { String.fromUtf8(Array<UInt8>(count, repeat: 0x78u8)) }
func cell(frame: Frame, x: Int64, y: Int64, text: String, width: Int64,
    continuation: Bool, style: Style): Unit {
    let c = frame.cellAt(x, y)
    check(c.grapheme == text && c.width == width && c.continuation == continuation && c.style == style,
        "cell ${x},${y}")
}

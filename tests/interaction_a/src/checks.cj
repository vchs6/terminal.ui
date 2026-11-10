package interaction_a_contract
import cjtui.*
func check(value: Bool, message: String): Unit {
    if (!value) { throw Exception("FAIL: ${message}") }
}
func ref(c: Component): NodeRef { c.reference().getOrThrow() }
func code(expected: String, action: () -> Unit): Unit {
    var actual = "NO_EXCEPTION"
    try { action() } catch (e: UIException) { actual = e.code }
    check(actual == expected, "error ${expected}; actual=${actual}")
}
func illegal(action: () -> Unit): Unit {
    var rejected = false
    try { action() } catch (_: IllegalArgumentException) { rejected = true }
    check(rejected, "invalid value rejected before mutation")
}
func plainTheme(): Theme { Theme.parse("schema_version=1\nname=\"A hand-written\"\n") }
func cell(f: Frame, x: Int64, y: Int64, glyph: String, width: Int64, continuation: Bool,
    style: Style): Unit {
    let c = f.cellAt(x,y)
    check(c.grapheme == glyph && c.width == width && c.continuation == continuation &&
        c.style == style && !c.isTransparent, "full cell (${x},${y})")
}
func sameFrame(a: Frame, b: Frame, width: Int64, height: Int64): Unit {
    for (y in 0..height) { for (x in 0..width) {
        let c = a.cellAt(x,y); let d = b.cellAt(x,y)
        check(c.grapheme == d.grapheme && c.width == d.width && c.continuation == d.continuation &&
            c.style == d.style && c.isTransparent == d.isTransparent, "reference full cell (${x},${y})")
    } }
}
func focus(app: Application, c: Component): Unit {
    check(app.focusedNode().getOrThrow().sameNode(ref(c)), "focused identity")
}
func hiddenCaret(app: Application): Unit {
    let s = app.caretSnapshot()
    check(s.owner.isNone() && s.x == 0 && s.y == 0 && !s.visible, "canonical hidden caret")
}
func empty(app: Application): Unit {
    let s = app.stats()
    check(s.mountedNodes == 0 && s.activeBindings == 0 && s.subscriptions == 0 && s.pendingPosts == 0,
        "all session resources released")
}

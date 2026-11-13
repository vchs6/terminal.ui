package session_lifecycle

import cjtui.*
import std.env.*
import std.fs.*

func check(value: Bool, label: String): Unit {
    if (!value) { throw Exception("ASSERT:${label}") }
}

func record(name: String, value: String): Unit {
    File.writeTo(getVariable("CJTUI_020_OUTPUT").getOrThrow() + "/" + name, value.toArray())
}

func empty(app: Application): Unit {
    let s = app.stats()
    check(s.mountedNodes == 0 && s.activeBindings == 0 && s.subscriptions == 0 && s.pendingPosts == 0,
        "closed session resources 0/0/0/0")
    check(app.focusedNode().isNone(), "closed focus None")
    let caret = app.caretSnapshot()
    check(!caret.visible && caret.owner.isNone() && caret.x == 0 && caret.y == 0,
        "closed caret canonical empty")
    check(!app.post({ => throw Exception("INACTIVE_POST_RAN") }), "inactive post refused")
}

func expectCode(code: String, action: () -> Unit): Unit {
    var observed = false
    try { action() } catch (e: UIException) { observed = e.code == code }
    check(observed, "expected UIException ${code}")
}

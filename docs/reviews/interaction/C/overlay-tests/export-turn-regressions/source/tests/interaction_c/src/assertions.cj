package interaction_c

import cjtui.*

func check(ok: Bool, name: String): Unit {
    if (!ok) {
        throw Exception("FAIL ${name}")
    }
    println("PASS ${name}")
}

func node(component: Component): NodeRef {
    component.reference().getOrThrow()
}

func picture(frame: Frame, expected: String, name: String): Unit {
    check(frame.toPlainText() == expected, "${name}: expected [${expected}], actual [${frame.toPlainText()}]")
}

func focused(app: Application, expected: NodeRef, name: String): Unit {
    check(app.focusedNode().getOrThrow().sameNode(expected), name)
}

func target(app: Application, expected: NodeRef, name: String): Unit {
    check(app.activeTarget().getOrThrow().sameNode(expected), name)
}

func code(expected: String, action: () -> Unit, name: String): Unit {
    var observed = "NO_ERROR"
    try {
        action()
    } catch (error: UIException) {
        observed = error.code
    }
    check(observed == expected, "${name}: expected ${expected}, actual ${observed}")
}

func illegal(action: () -> Unit, name: String): Unit {
    var observed = false
    try {
        action()
    } catch (_: IllegalArgumentException) {
        observed = true
    }
    check(observed, name)
}

func reason(handle: OverlayHandle): String {
    match (handle.closeReason()) {
        case None => "None"
        case Some(OverlayCloseReason.Requested) => "Requested"
        case Some(OverlayCloseReason.Escape) => "Escape"
        case Some(OverlayCloseReason.OwnerGone) => "OwnerGone"
        case Some(OverlayCloseReason.OwnerHidden) => "OwnerHidden"
        case Some(OverlayCloseReason.AnchorGone) => "AnchorGone"
    }
}

func released(app: Application, name: String): Unit {
    let stats = app.stats()
    check(stats.mountedNodes == 0 && stats.activeBindings == 0 && stats.subscriptions == 0 && stats.pendingPosts == 0,
        name)
}

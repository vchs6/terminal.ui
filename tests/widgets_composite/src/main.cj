package widgets_composite

import cjtui.*

func check(ok: Bool, message: String): Unit {
    if (!ok) { throw IllegalStateException(message) }
}
func equal(actual: String, expected: String, name: String): Unit {
    check(actual == expected, name + ": got [" + actual + "], expected [" + expected + "]")
}
func mounted(component: Component): NodeRef { component.reference().getOrThrow() }
func focus(app: Application, target: NodeRef): Unit {
    app.batch({ => target.requestFocus() })
    check(app.focusedNode().getOrThrow().sameNode(target), "fixture focus commits before dispatch")
}
func focused(app: Application, target: NodeRef, name: String): Unit {
    check(app.focusedNode().getOrThrow().sameNode(target), name)
}
func clean(app: Application): Unit {
    let stats = app.stats()
    check(stats.mountedNodes == 0 && stats.activeBindings == 0 && stats.subscriptions == 0 && stats.pendingPosts == 0,
        "M05 all resources released")
}
func expectCode(action: () -> Unit, code: String): Unit {
    var actual = ""
    try { action() } catch (error: UIException) { actual = error.code }
    equal(actual, code, "public error code")
}

main(): Int64 {
    entryAndShapes()
    menuIdentity()
    duplicateBatch()
    navigation(false)
    navigation(true)
    navigationBoundaries()
    activationMatrix(false)
    activationMatrix(true)
    affectedS02()
    popupOwnership()
    popupEscapeBoundaries()
    nestedPopup()
    popupOwnerAndAnchor()
    statusAndSplitFrames()
    localTheme()
    sharedPanels()
    callbackRecovery()
    println("TASK158_M01_M05_S02_PASS")
    0
}

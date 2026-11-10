package dynamic_contract

import cjtui.*

func check(value: Bool, name: String): Unit {
    if (!value) { throw Exception("FAIL: ${name}") }
}

func ref(component: Component): NodeRef {
    component.reference().getOrThrow({ => Exception("expected mounted component") })
}

func sequence(parent: NodeRef, expected: Array<NodeRef>, name: String): Unit {
    let actual = parent.children()
    check(actual.size == expected.size, "${name}: direct child count")
    for (i in 0..expected.size) {
        check(actual[i].sameNode(expected[i]), "${name}: child identity at ${i}")
    }
}

func picture(app: Application, width: Int64, height: Int64, expected: String, name: String): Unit {
    let actual = app.snapshot(width, height).toPlainText()
    check(actual == expected, "${name}: frame [${actual}] expected [${expected}]")
}

func expectUI(code: String, action: () -> Unit): Unit {
    var caught = false
    try { action() } catch (error: UIException) {
        caught = true
        check(error.code == code, "error code ${error.code}, expected ${code}")
    }
    check(caught, "expected UIException(${code})")
}

func expectSomeUI(action: () -> Unit): Unit {
    var caught = false
    try { action() } catch (_: UIException) { caught = true }
    check(caught, "expected structural UIException")
}

func dead(app: Application, refs: Array<NodeRef>, name: String): Unit {
    for (node in refs) { check(!node.isValid(), "${name}: invalidated ref") }
    let stats = app.stats()
    check(stats.mountedNodes == 0 && stats.activeBindings == 0 && stats.subscriptions == 0 &&
        stats.pendingPosts == 0, "${name}: no retained runtime resources")
}

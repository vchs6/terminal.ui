package runtime_contract

import cjtui.*

func check(value: Bool, name: String): Unit {
    if (!value) { throw Exception("FAIL: ${name}") }
    println("PASS: ${name}")
}

func picture(frame: Frame, expected: String, name: String): Unit {
    check(frame.toPlainText() == expected,
        "${name}: got [${frame.toPlainText()}], want [${expected}]")
}

func code(expected: String, action: () -> Unit, name: String): Unit {
    var actual = "no exception"
    try { action() } catch (error: UIException) { actual = error.code }
    check(actual == expected, "${name}: code=${actual}, want=${expected}")
}

func failsWith(sentinel: String, action: () -> Unit, name: String): Unit {
    var actual = "no exception"
    try { action() } catch (error: Exception) { actual = error.message }
    check(actual.contains(sentinel), "${name}: ${actual}")
}

func illegal(action: () -> Unit, name: String): Unit {
    var caught = false
    try { action() } catch (_: IllegalArgumentException) { caught = true }
    check(caught, name)
}

func ref(component: Component): NodeRef { component.reference().getOrThrow() }

func emptyStats(app: Application, name: String): Unit {
    let s = app.stats()
    check(s.mountedNodes == 0 && s.activeBindings == 0 && s.subscriptions == 0 &&
        s.pendingPosts == 0, name)
}

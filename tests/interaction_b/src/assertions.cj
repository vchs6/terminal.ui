package interaction_b

import cjtui.*

func check(value: Bool, name: String): Unit {
    if (!value) { throw Exception("FAIL: ${name}") }
}

func picture(frame: Frame, expected: String, name: String): Unit {
    check(frame.toPlainText() == expected,
        "${name}: got [${frame.toPlainText()}], want [${expected}]")
}

func ref(component: Component): NodeRef { component.reference().getOrThrow() }

func ref(component: ?Component): NodeRef { ref(component.getOrThrow()) }

func offset(component: ?Component, x: Int64, y: Int64, name: String): Unit {
    offset(component.getOrThrow(), x, y, name)
}

func offset(component: Component, x: Int64, y: Int64, name: String): Unit {
    let state = ref(component).viewportSnapshot()
    check(state.offsetX == x && state.offsetY == y,
        "${name}: offset ${state.offsetX},${state.offsetY}; want ${x},${y}")
}

func code(expected: String, action: () -> Unit, name: String): Unit {
    var actual = "no exception"
    try { action() } catch (error: UIException) { actual = error.code }
    check(actual == expected, "${name}: code=${actual}, want=${expected}")
}

func illegal(action: () -> Unit, name: String): Unit {
    var caught = false
    try { action() } catch (_: IllegalArgumentException) { caught = true }
    check(caught, name)
}

// Data fixture only: no layout, offset calculation, or expected grid generation.
func hundredRows(): Unit {
    for (i in 0..100) { Text("r${i}").height(1) }
}

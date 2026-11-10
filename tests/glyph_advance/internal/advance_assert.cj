package cjtui

func advanceCheck(value: Bool, name: String): Unit {
    if (!value) { throw Exception("FAIL: ${name}") }
}

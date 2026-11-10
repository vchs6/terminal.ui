package rich_text_contract

import cjtui.*

func check(value: Bool, name: String): Unit {
    if (!value) { throw Exception("FAIL: ${name}") }
}

func illegal(action: () -> Unit, name: String): Unit {
    let caught = [false]
    try { action() } catch (_: IllegalArgumentException) { caught[0] = true }
    check(caught[0], name)
}

func ansiError(expected: String, action: () -> Unit, name: String): Unit {
    let actual = ["no exception"]
    try { action() } catch (error: AnsiTextException) { actual[0] = error.code }
    check(actual[0] == expected, "${name}: ${actual[0]}, expected ${expected}")
}

func cell(frame: Frame, x: Int64, y: Int64, glyph: String, width: Int64,
    continuation: Bool, style: Style, name: String): Unit {
    let actual = frame.cellAt(x, y)
    check(actual.grapheme == glyph && actual.width == width && actual.continuation == continuation &&
        actual.style == style && !actual.isTransparent, name)
}

func uiError(expected: String, action: () -> Unit, name: String): Unit {
    let actual = ["no exception"]
    try { action() } catch (error: UIException) { actual[0] = error.code }
    check(actual[0] == expected, "${name}: ${actual[0]}, expected ${expected}")
}

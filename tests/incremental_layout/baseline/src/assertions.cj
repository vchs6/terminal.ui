package incremental_layout_baseline

import cjtui.*

func check(value: Bool, label: String): Unit {
    if (!value) { throw Exception("FAIL: ${label}") }
}

func plain(frame: Frame, expected: String, label: String): Unit {
    check(frame.toPlainText() == expected, "${label}: got [${frame.toPlainText()}], want [${expected}]")
}

func cell(frame: Frame, x: Int64, y: Int64, grapheme: String, width: Int64,
    continuation: Bool, style: Style, label: String): Unit {
    let value = frame.cellAt(x, y)
    check(value.grapheme == grapheme && value.width == width && value.continuation == continuation &&
        value.style == style && !value.isTransparent, label)
}

func equalCells(actual: Frame, reference: Frame, label: String): Unit {
    check(actual.width == reference.width && actual.height == reference.height, "${label}: size")
    for (y in 0..actual.height) {
        for (x in 0..actual.width) {
            let a = actual.cellAt(x, y)
            let b = reference.cellAt(x, y)
            check(a.grapheme == b.grapheme && a.width == b.width && a.continuation == b.continuation &&
                a.style == b.style && a.isTransparent == b.isTransparent, "${label}: cell ${x},${y}")
        }
    }
}

func paired(app: Application, root: Component, width: Int64, height: Int64, expected: String, label: String): Frame {
    let frame = app.snapshot(width, height)
    plain(frame, expected, label)
    equalCells(frame, render(root, width, height), label)
    frame
}

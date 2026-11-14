package incremental_frame_cow

import cjtui.*

func check(value: Bool, label: String): Unit {
    if (!value) { throw Exception(label) }
}
func plain(frame: Frame, expected: String, label: String): Unit {
    check(frame.toPlainText() == expected, "${label}: got [${frame.toPlainText()}], want [${expected}]")
}
func cell(frame: Frame, x: Int64, y: Int64, glyph: String, width: Int64,
    continuation: Bool, style: Style, transparent: Bool, label: String): Unit {
    let c = frame.cellAt(x, y)
    check(c.grapheme == glyph && c.width == width && c.continuation == continuation &&
        c.style == style && c.isTransparent == transparent, "${label}: cell ${x},${y}")
}
func same(a: Frame, b: Frame, label: String): Unit {
    check(a.width == b.width && a.height == b.height, "${label}: dimensions")
    for (y in 0..a.height) {
        for (x in 0..a.width) {
            let c = b.cellAt(x, y)
            cell(a, x, y, c.grapheme, c.width, c.continuation, c.style, c.isTransparent, label)
        }
    }
}
func rejects(action: () -> Unit, label: String): Unit {
    var caught = false
    try { action() } catch (_: IllegalArgumentException) { caught = true }
    check(caught, label)
}
func unchanged(a: RuntimeStats, b: RuntimeStats, label: String): Unit {
    check(a.frameAllocatedCells == b.frameAllocatedCells && a.cellWrites == b.cellWrites &&
        a.frames == b.frames, label)
}

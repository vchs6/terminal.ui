package cjtui

func projectTerminalRow(frame: Frame, y: Int64, profile: TerminalRenderProfile): Array<Cell> {
    let row = Array<Cell>(frame.width, {_ => blankCell(false)})
    var raw = Style()
    var style = projectTerminalStyle(raw, profile)
    var x = 0
    while (x < frame.width) {
        let cell = frame.cellAt(x, y)
        if (cell.style != raw) {
            raw = cell.style
            style = projectTerminalStyle(raw, profile)
        }
        let glyph = projectTerminalGlyph(cell.grapheme, cell.width, profile.glyphPolicy)
        if (glyph == cell.grapheme) {
            row[x] = Cell(glyph, cell.width, false, style)
            for (i in 1..cell.width) {
                row[x + i] = Cell("", 0, true, style)
            }
        } else {
            // A fallback occupies independent printable columns, just like literal '?'.
            let bytes = glyph.toArray()
            for (i in 0..cell.width) {
                row[x + i] = Cell(String.fromUtf8([bytes[i]]), 1, false, style)
            }
        }
        x += cell.width
    }
    row
}

func terminalRowsEqual(a: Array<Cell>, b: Array<Cell>): Bool {
    for (x in 0..a.size) {
        if (a[x].grapheme != b[x].grapheme || a[x].width != b[x].width || a[x].continuation != b[x].continuation ||
            a[x].style != b[x].style) {
            return false
        }
    }
    true
}

func encodeTerminalRow(row: Array<Cell>, resetAtEnd: Bool): String {
    var out = ""
    let defaultStyle = Style()
    var previous = defaultStyle
    for (cell in row) {
        if (!cell.continuation) {
            if (cell.style != previous) {
                out += encodeStyle(cell.style)
                previous = cell.style
            }
            out += cell.grapheme
        }
    }
    if (resetAtEnd && previous != defaultStyle) {
        out += resetStyle()
    }
    out
}

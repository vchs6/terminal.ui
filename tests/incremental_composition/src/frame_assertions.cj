package incremental_composition

import cjtui.*

// These arrays enumerate literal cells; no text segmentation, layout or width oracle.
func row(glyphs: Array<String>, style!: Style = Style()): Array<ExpectedCell> {
    Array<ExpectedCell>(glyphs.size,{ i => ExpectedCell(glyphs[i],style:style) })
}

func cellDescription(value: Cell): String {
    let s = value.style
    "glyph=[${value.grapheme}] width=${value.width} continuation=${value.continuation} transparent=${value.isTransparent} style=${colorDescription(s.foreground)}/${colorDescription(s.background)}/${s.bold}/${s.dim}/${s.italic}/${s.underline}/${s.inverse}/${s.strikethrough}"
}

func colorDescription(value: Color): String {
    match (value) {
        case Color.Default => "Default"
        case Color.Black => "Black"
        case Color.Red => "Red"
        case Color.Green => "Green"
        case Color.Yellow => "Yellow"
        case Color.Blue => "Blue"
        case Color.Magenta => "Magenta"
        case Color.Cyan => "Cyan"
        case Color.White => "White"
        case Color.BrightBlack => "BrightBlack"
        case Color.BrightRed => "BrightRed"
        case Color.BrightGreen => "BrightGreen"
        case Color.BrightYellow => "BrightYellow"
        case Color.BrightBlue => "BrightBlue"
        case Color.BrightMagenta => "BrightMagenta"
        case Color.BrightCyan => "BrightCyan"
        case Color.BrightWhite => "BrightWhite"
        case Color.Indexed(index) => "Indexed(${index})"
        case Color.Rgb(r,g,b) => "Rgb(${r},${g},${b})"
    }
}

func sameCells(a: Frame, b: Frame, label: String): Unit {
    Checks.equal(a.width == b.width && a.height == b.height,"${label}: dimensions")
    if (a.width != b.width || a.height != b.height) { return }
    for (y in 0..a.height) { for (x in 0..a.width) {
        let left = a.cellAt(x,y); let right = b.cellAt(x,y)
        Checks.equal(left.grapheme == right.grapheme && left.width == right.width &&
            left.continuation == right.continuation && left.isTransparent == right.isTransparent && left.style == right.style,
            "${label}: (${x},${y}) actual=${cellDescription(left)} reference=${cellDescription(right)}")
    } }
}

func literal(frame: Frame, cells: Array<Array<ExpectedCell>>, label: String): Unit {
    Checks.equal(frame.height == cells.size,"${label}: literal height")
    if (frame.height != cells.size) { return }
    for (y in 0..cells.size) {
        let expectedRow = cells[y]
        Checks.equal(frame.width == expectedRow.size,"${label}: literal row ${y} width")
        if (frame.width != expectedRow.size) { continue }
        for (x in 0..expectedRow.size) {
            let a = frame.cellAt(x,y); let e = expectedRow[x]
            Checks.equal(a.grapheme == e.glyph && a.width == e.width && a.continuation == e.continuation &&
                a.style == e.style && a.isTransparent == e.transparent,
                "${label}: literal (${x},${y}) actual=${cellDescription(a)} expected glyph=[${e.glyph}] width=${e.width} continuation=${e.continuation} transparent=${e.transparent}")
        }
    }
}

func caret(app: Application, owner: Component, x: Int64, y: Int64, label: String): Unit {
    let value = app.caretSnapshot()
    let ownerRef = owner.reference()
    Checks.equal(value.visible && value.x == x && value.y == y && value.owner.isSome() && ownerRef.isSome(),
        "${label}: visible caret at (${x},${y}), actual=${value.visible}/${value.x}/${value.y}")
    if (value.owner.isSome() && ownerRef.isSome()) {
        Checks.equal(value.owner.getOrThrow().sameNode(ownerRef.getOrThrow()),"${label}: caret owner")
    }
}

func noCaret(app: Application, label: String): Unit {
    let value = app.caretSnapshot()
    Checks.equal(!value.visible && value.owner.isNone() && value.x == 0 && value.y == 0,"${label}: canonical hidden caret")
}

func node(component: Component): NodeRef { component.reference().getOrThrow() }
func plainTheme(): Theme { Theme.parse("schema_version=1\nname=\"D literal composition\"\n") }

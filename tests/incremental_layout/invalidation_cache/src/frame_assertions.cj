package incremental_invalidation_cache

import cjtui.*

func check(value: Bool, label: String): Unit {
    if (!value) { throw Exception("FAIL: ${label}") }
}

func describeColor(value: Color): String {
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
        case Color.Rgb(r, g, b) => "Rgb(${r},${g},${b})"
    }
}

func describeCell(value: Cell): String {
    let s = value.style
    "[grapheme=${value.grapheme};width=${value.width};continuation=${value.continuation};transparent=${value.isTransparent};foreground=${describeColor(s.foreground)};background=${describeColor(s.background)};bold=${s.bold};dim=${s.dim};italic=${s.italic};underline=${s.underline};inverse=${s.inverse};strikethrough=${s.strikethrough}]"
}

func equalCells(actual: Frame, reference: Frame, label: String): Unit {
    check(actual.width == reference.width && actual.height == reference.height, "${label}: frame size")
    for (y in 0..actual.height) {
        for (x in 0..actual.width) {
            let a = actual.cellAt(x, y)
            let b = reference.cellAt(x, y)
            if (!(a.grapheme == b.grapheme && a.width == b.width && a.continuation == b.continuation &&
                a.style == b.style && a.isTransparent == b.isTransparent)) {
                throw Exception("${label}: Cell(${x},${y}) actual=${describeCell(a)} reference=${describeCell(b)}")
            }
        }
    }
}

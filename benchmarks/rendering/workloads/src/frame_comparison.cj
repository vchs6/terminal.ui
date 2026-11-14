package rendering_workloads

import cjtui.*

// Correctness only. Timing code must never call this function.
public func assertFramesEqual(actual: Frame, reference: Frame): Unit {
    if (actual.width != reference.width || actual.height != reference.height) {
        throw Exception("frame dimensions differ: ${actual.width}x${actual.height} versus ${reference.width}x${reference.height}")
    }
    for (y in 0..actual.height) {
        for (x in 0..actual.width) {
            let left = actual.cellAt(x, y)
            let right = reference.cellAt(x, y)
            if (left.grapheme != right.grapheme || left.width != right.width ||
                left.continuation != right.continuation || left.isTransparent != right.isTransparent ||
                left.style != right.style) {
                throw Exception("cell mismatch at (${x},${y}): ${describeCell(left)} versus ${describeCell(right)}")
            }
        }
    }
}

private func describeCell(cell: Cell): String {
    let style = cell.style
    "grapheme=${cell.grapheme},width=${cell.width},continuation=${cell.continuation},transparent=${cell.isTransparent},foreground=${colorName(style.foreground)},background=${colorName(style.background)},bold=${style.bold},dim=${style.dim},italic=${style.italic},underline=${style.underline},inverse=${style.inverse},strikethrough=${style.strikethrough}"
}

public func colorName(color: Color): String {
    match (color) {
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
        case Color.Indexed(value) => "Indexed(${value})"
        case Color.Rgb(r, g, b) => "Rgb(${r},${g},${b})"
    }
}

package rendering_workloads

import cjtui.*

// Hand-specified logical Cells for the frozen simple scenes. No text-layout or
// width oracle participates; all unspecified positions are default spaces.
public func assertLiteralFrame(frame: Frame, name: String, epoch: Int64): Unit {
    if (!["unicode_cells", "ellipsis_policy", "caret_only", "root_fallback", "viewport_caret", "readonly_focus_caret"].contains(name)) { return }
    for (y in 0..frame.height) {
        for (x in 0..frame.width) {
            let (grapheme, width, continuation, foreground) = literalCell(name, epoch, x, y)
            let cell = frame.cellAt(x, y)
            if (cell.grapheme != grapheme || cell.width != width || cell.continuation != continuation ||
                cell.isTransparent || cell.style != Style(foreground: foreground)) {
                let expected = "grapheme=${grapheme},width=${width},continuation=${continuation},transparent=false,foreground=${colorName(foreground)},background=Default,bold=false,dim=false,italic=false,underline=false,inverse=false,strikethrough=false"
                throw Exception("literal ${name} epoch ${epoch} mismatch at (${x},${y}): ${describeCell(cell)} versus ${expected}")
            }
        }
    }
}

private func literalCell(name: String, epoch: Int64, x: Int64, y: Int64): (String, Int64, Bool, Color) {
    if (name == "unicode_cells" && y == 0) {
        if (epoch == 2 || epoch == 3) {
            if (x == 0) { return ("A", 1, false, if (epoch == 3) { Color.Red } else { Color.Default }) }
        } else { return mixedCell("A", x, alternate: epoch == 1) }
    }
    if (name == "ellipsis_policy" && y == 0 && x < 5) {
        let unicode = ["a", "b", "c", "d", "…"]
        let ascii = ["a", "b", ".", ".", "."]
        return (if (epoch % 2 == 1) { ascii[x] } else { unicode[x] }, 1, false, Color.Default)
    }
    if (name == "root_fallback") {
        let step = epoch % 3
        if (step == 2) { return mixedCell("C", x) }
        if (y == 0) { return mixedCell("A", x) }
        if (y == 1) { return mixedCell("B", x) }
        if (step == 1) { return mixedCell("C", x) }
    }
    if (name == "viewport_caret") {
        if (y == 0 && x == 0) { return ("H", 1, false, Color.Default) }
        if (y == 3 && x == 0) { return ("F", 1, false, Color.Default) }
        if (y == 1) { return mixedCell(if (epoch % 3 == 0) { "A" } else { "B" }, x) }
        if (y == 2) { return mixedCell(if (epoch % 3 == 0) { "B" } else { "C" }, x) }
    }
    if (name == "readonly_focus_caret" && y == 2) { return mixedCell("A", x) }
    (" ", 1, false, Color.Default)
}

private func mixedCell(first: String, x: Int64, alternate!: Bool = false): (String, Int64, Bool, Color) {
    match (x) {
        case 0 => (first, 1, false, Color.Default)
        case 1 => (if (alternate) { "文" } else { "中" }, 2, false, Color.Default)
        case 2 => ("", 0, true, Color.Default)
        case 3 => ("é", 1, false, Color.Default)
        case 4 => ("👩‍💻", 2, false, Color.Default)
        case 5 => ("", 0, true, Color.Default)
        case 6 => ("🇨🇳", 2, false, Color.Default)
        case 7 => ("", 0, true, Color.Default)
        case _ => (" ", 1, false, Color.Default)
    }
}

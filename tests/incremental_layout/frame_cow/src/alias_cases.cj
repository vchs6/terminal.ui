package incremental_frame_cow

import cjtui.*

// Catches a missing source OR destination detach, including second-generation aliases.
func aliasBranches(): Unit {
    let original = Frame(6, 2, transparent: true)
    let red = Style(foreground: Color.Red, background: Color.Blue, bold: true, dim: true,
        italic: true, underline: true, inverse: true, strikethrough: true)
    original.put(0, 0, "A中é", style: red)
    let left = original.copy(Rect(0, 0, 6, 2))
    let right = original.resized(6, 2)
    let grandchild = left.copy(Rect(0, 0, 6, 2))
    original.put(1, 0, "x") // writes the old lead; partner is restored to transparent default
    plain(original, "Ax é  \n      ", "source write")
    cell(original, 2, 0, " ", 1, false, Style(), true, "source partner repair")
    left.put(2, 0, "L") // writes continuation, repairs lead outside anchor
    plain(left, "A Lé  \n      ", "clone continuation write")
    cell(left, 1, 0, " ", 1, false, Style(), true, "clone partner repair")
    right.clear(Rect(2, 0, 1, 1), transparent: false)
    cell(right, 1, 0, " ", 1, false, Style(), false, "explicit clear whole cluster")
    cell(grandchild, 0, 0, "A", 1, false, red, false, "grandchild style")
    cell(grandchild, 1, 0, "中", 2, false, red, false, "grandchild lead")
    cell(grandchild, 2, 0, "", 0, true, red, false, "grandchild continuation")
    cell(grandchild, 3, 0, "é", 1, false, red, false, "combining cluster")
    cell(grandchild, 5, 1, " ", 1, false, Style(), true, "untouched hole")
    grandchild.put(5, 1, "G")
    cell(original, 5, 1, " ", 1, false, Style(), true, "grandchild does not change source")
    cell(left, 5, 1, " ", 1, false, Style(), true, "grandchild does not change parent")
    cell(right, 5, 1, " ", 1, false, Style(), true, "grandchild does not change sibling")
}

// Catches a write entrance bypassing detach; all expectations are handwritten.
func writeEntrances(): Unit {
    let base = Frame(5, 3)
    base.put(0, 0, "abcde\nfghij\nklmno")
    let style = Style(background: Color.Blue, underline: true)
    let text = base.copy(Rect(0, 0, 5, 3))
    text.put(0, 0, RichText([TextSpan("R", style: TextStylePatch(bold: Some(true))), TextSpan("S")]), style: style)
    cell(text, 0, 0, "R", 1, false, Style(background: Color.Blue, underline: true, bold: true), false, "span patch")
    cell(text, 1, 0, "S", 1, false, style, false, "span inheritance")
    let ansi = base.copy(Rect(0, 0, 5, 3))
    ansi.put(0, 1, parseAnsiText("\u{1b}[31mZ\u{1b}[0m").text)
    cell(ansi, 0, 1, "Z", 1, false, Style(foreground: Color.Red), false, "ANSI write")
    let fill = base.copy(Rect(0, 0, 5, 3))
    fill.fillRect(Rect(-1, 1, 3, 1), style: style)
    plain(fill, "abcde\n  hij\nklmno", "clipped fill")
    cell(fill, 0, 1, " ", 1, false, style, false, "styled space")
    let border = base.copy(Rect(0, 0, 5, 3))
    border.drawBorder(Rect(0, 0, 5, 3), border: BorderStyle.Ascii, style: style)
    plain(border, "+---+\n|ghi|\n+---+", "border")
    let shadow = base.copy(Rect(0, 0, 5, 3))
    shadow.drawShadow(Rect(0, 0, 2, 1), offsetX: 1, offsetY: 1, style: style)
    plain(shadow, "abcde\nf░░ij\nklmno", "shadow")
    let clear = base.copy(Rect(0, 0, 5, 3))
    clear.clear(Rect(1, 2, 3, 1), transparent: true)
    plain(clear, "abcde\nfghij\nk   o", "clear")
    cell(clear, 2, 2, " ", 1, false, Style(), true, "clear hole normalization")
    // Mutate the common source after every branch has already changed.
    base.put(4, 2, "B")
    plain(text, "RScde\nfghij\nklmno", "text branch remains independent")
    plain(ansi, "abcde\nZghij\nklmno", "ANSI branch remains independent")
    cell(fill, 4, 2, "o", 1, false, Style(), false, "fill branch remains independent")
    cell(border, 4, 2, "+", 1, false, style, false, "border branch remains independent")
    cell(shadow, 4, 2, "o", 1, false, Style(), false, "shadow branch remains independent")
    cell(clear, 4, 2, "o", 1, false, Style(), false, "clear branch remains independent")
}

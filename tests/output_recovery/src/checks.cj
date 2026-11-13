package output_recovery

import cjtui.*

func check(value: Bool, label: String): Unit {
    if (!value) { throw Exception("ASSERT: " + label) }
}

func plainTheme(): Theme { Theme.parse("schema_version=1\nname=\"Output contract\"\n") }

func pureFrames(): Unit {
    let a = Frame(4, 1)
    a.put(0, 0, "Aé")
    check(a.cellAt(0, 0).grapheme == "A" && a.cellAt(1, 0).grapheme == "é" &&
        a.cellAt(2, 0).grapheme == " " && a.cellAt(3, 0).grapheme == " ", "literal initial grid")
    let esc = "\u{1b}["
    let expected = esc + "0m" + esc + "1;1HAé  " + esc + "0m"
    check(a.toAnsi() == expected, "literal CUP/default style/full row/reset wire")
    let b = Frame(4, 1)
    b.put(0, 0, "é", style: Style(foreground: Color.Rgb(1, 128, 254), bold: true))
    check(b.cellAt(0, 0).grapheme == "é" && b.cellAt(1, 0).grapheme == " " &&
        b.cellAt(2, 0).grapheme == " " && b.cellAt(3, 0).grapheme == " ", "literal shortened grid clears tail")
    check(a.cellAt(0, 0).grapheme == "A", "separate target does not alias old frame")
    check(b.cellAt(0, 0).style == Style(foreground: Color.Rgb(1, 128, 254), bold: true), "literal style")
}

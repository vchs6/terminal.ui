package color_contract
import cjtui.*
func check(value: Bool, name: String): Unit {
    if (!value) { throw Exception("FAIL: ${name}") }
    println("PASS: ${name}")
}
let esc = "\u{1b}["
let reset = "\u{1b}[0m"
let modes = [ColorMode.Basic16, ColorMode.Indexed256, ColorMode.TrueColor, ColorMode.Monochrome]
let named = [Color.Black, Color.Red, Color.Green, Color.Yellow, Color.Blue, Color.Magenta, Color.Cyan, Color.White,
    Color.BrightBlack, Color.BrightRed, Color.BrightGreen, Color.BrightYellow, Color.BrightBlue,
    Color.BrightMagenta, Color.BrightCyan, Color.BrightWhite]
func one(style: Style, mode: ColorMode): String {
    let f = Frame(1, 1)
    f.put(0, 0, "X", style: style)
    f.toAnsi(colorMode: mode)
}
func expected(codes: String): String {
    reset + esc + "1;1H" + (if (codes.isEmpty()) { "X" + reset } else { reset + codes + "X" + reset + reset })
}
func color(c: Color, mode: ColorMode, code: String, name: String): Unit {
    check(one(Style(foreground: c), mode) == expected(code), name)
}
func models(): Unit {
    let all = [Color.Default, Color.Black, Color.Red, Color.Green, Color.Yellow, Color.Blue,
        Color.Magenta, Color.Cyan, Color.White, Color.BrightBlack, Color.BrightRed, Color.BrightGreen,
        Color.BrightYellow, Color.BrightBlue, Color.BrightMagenta, Color.BrightCyan, Color.BrightWhite,
        Color.Indexed(0), Color.Indexed(255), Color.Rgb(0, 0, 0), Color.Rgb(255, 255, 255),
        Color.Rgb(255, 0, 0), Color.Rgb(0, 255, 0), Color.Rgb(0, 0, 255)]
    for (i in 0..all.size) {
        for (j in 0..all.size) {
            check((all[i] == all[j]) == (i == j) && (all[i] != all[j]) == (i != j), "Color constructor/channel Eq ${i}/${j}")
        }
    }
    for (i in 0..modes.size) {
        for (j in 0..modes.size) { check((modes[i] == modes[j]) == (i == j), "ColorMode Eq ${i}/${j}") }
    }
    let none = Style()
    check(!none.bold && !none.dim && !none.italic && !none.underline && !none.inverse && !none.strikethrough, "all six attributes default false")
    let styles = [none, Style(foreground: Color.Red), Style(background: Color.Red), Style(bold: true),
        Style(dim: true), Style(italic: true), Style(underline: true), Style(inverse: true), Style(strikethrough: true)]
    for (i in 0..styles.size) {
        for (j in 0..styles.size) {
            check((styles[i] == styles[j]) == (i == j) && (styles[i] != styles[j]) == (i != j), "Style Eq includes field ${i}/${j}")
        }
    }
    check(Color.Rgb(1, 2, 3) == Color.Rgb(1, 2, 3) && Color.Indexed(42) == Color.Indexed(42), "separately constructed payload equality")
}
func mapping(): Unit {
    for (i in 0..16) {
        let fg = esc + (if (i < 8) { 30 + i } else { 90 + i - 8 }).toString() + "m"
        let bg = esc + (if (i < 8) { 40 + i } else { 100 + i - 8 }).toString() + "m"
        for (mode in modes) {
            let code = if (mode == ColorMode.Monochrome) { "" } else { fg }
            color(named[i], mode, code, "named foreground ${i}")
            color(Color.Indexed(UInt8(i)), mode, code, "indexed alias ${i}")
            check(one(Style(background: named[i]), mode) == expected(if (mode == ColorMode.Monochrome) { "" } else { bg }), "named background ${i}")
            color(Color.Default, mode, "", "Default never selects a color")
        }
    }
    for (i in 16..256) {
        for (mode in [ColorMode.Indexed256, ColorMode.TrueColor]) {
            color(Color.Indexed(UInt8(i)), mode, esc + "38;5;${i}m", "indexed exact channel ${i}")
            check(one(Style(background: Color.Indexed(UInt8(i))), mode) == expected(esc + "48;5;${i}m"), "indexed background ${i}")
        }
    }
    // Independent nominal distances: red250 is 5^2 from index9 versus 122^2 from index1;
    // indexed17=(0,0,95) is 33^2 from Blue; RGB64 ties Black/Red at 64^2 -> index0.
    color(Color.Rgb(250, 0, 0), ColorMode.Basic16, esc + "91m", "near bright red Basic16")
    color(Color.Rgb(250, 0, 0), ColorMode.Indexed256, esc + "91m", "near bright red Indexed256 normalized alias")
    color(Color.Indexed(17), ColorMode.Basic16, esc + "34m", "cube index17 nominal Blue")
    color(Color.Rgb(64, 0, 0), ColorMode.Basic16, esc + "30m", "Basic16 squared-distance tie chooses index0")
    // cube33=(0,135,255): distance1+49+1=51; all other cube levels and palette entries farther.
    color(Color.Rgb(1, 128, 254), ColorMode.Indexed256, esc + "38;5;33m", "nearest cube33")
    color(Color.Rgb(128, 128, 128), ColorMode.Indexed256, esc + "90m", "exact gray128 chooses lower index8")
    color(Color.Rgb(238, 238, 238), ColorMode.Indexed256, esc + "38;5;255m", "last grayscale238")
    color(Color.Rgb(0, 0, 0), ColorMode.Indexed256, esc + "30m", "duplicate black index0 beats cube16")
    color(Color.Rgb(255, 255, 255), ColorMode.Indexed256, esc + "97m", "duplicate white index15 beats cube231")
    color(Color.Indexed(232), ColorMode.Basic16, esc + "30m", "gray8 nominal Black")
    color(Color.Indexed(255), ColorMode.Basic16, esc + "97m", "gray238 nominal BrightWhite")
    // Each channel's UInt8 endpoints are independently visible in exact truecolor bytes.
    for (c in [Color.Rgb(0, 0, 0), Color.Rgb(255, 0, 0), Color.Rgb(0, 255, 0), Color.Rgb(0, 0, 255), Color.Rgb(255, 255, 255)]) {
        color(c, ColorMode.Monochrome, "", "Monochrome removes all channel selections")
    }
    color(Color.Rgb(0, 0, 0), ColorMode.TrueColor, esc + "38;2;0;0;0m", "RGB lower endpoints")
    color(Color.Rgb(255, 0, 0), ColorMode.TrueColor, esc + "38;2;255;0;0m", "RGB red upper endpoint")
    color(Color.Rgb(0, 255, 0), ColorMode.TrueColor, esc + "38;2;0;255;0m", "RGB green upper endpoint")
    color(Color.Rgb(0, 0, 255), ColorMode.TrueColor, esc + "38;2;0;0;255m", "RGB blue upper endpoint")
    color(Color.Rgb(255, 255, 255), ColorMode.TrueColor, esc + "38;2;255;255;255m", "RGB all upper endpoints")
    check(one(Style(background: Color.Rgb(0, 255, 255)), ColorMode.TrueColor) == expected(esc + "48;2;0;255;255m"), "RGB background distinct exact channels")
}
func encodingAndCells(): Unit {
    let full = Style(foreground: Color.Rgb(1, 128, 254), background: Color.Indexed(17), bold: true,
        dim: true, italic: true, underline: true, inverse: true, strikethrough: true)
    let attributes = esc + "1m" + esc + "2m" + esc + "3m" + esc + "4m" + esc + "7m" + esc + "9m"
    check(one(full, ColorMode.TrueColor) == expected(esc + "38;2;1;128;254m" + esc + "48;5;17m" + attributes), "exact color then six-attribute order and reset bytes")
    check(one(full, ColorMode.Monochrome) == expected(attributes), "Monochrome preserves all six attributes")
    let f = Frame(4, 1)
    f.put(0, 0, "中", style: full)
    f.put(2, 0, "X", style: full)
    let plain = f.toPlainText()
    let saved = f.cellAt(0, 0).style
    let outputs = [f.toAnsi(colorMode: ColorMode.Basic16), f.toAnsi(colorMode: ColorMode.Indexed256),
        f.toAnsi(colorMode: ColorMode.TrueColor), f.toAnsi(colorMode: ColorMode.Monochrome)]
    check(outputs[0] != outputs[1] && outputs[1] != outputs[2] && outputs[2] != outputs[3], "same raw frame yields four distinguishable projections")
    check(f.toPlainText() == plain && f.cellAt(0, 0).style == saved && f.cellAt(1, 0).style == full &&
        f.cellAt(1, 0).continuation && f.cellAt(2, 0).style == full, "output never mutates raw leading/continuation Style")
    check(outputs[2] == reset + esc + "1;1H" + reset + esc + "38;2;1;128;254m" + esc + "48;5;17m" + attributes + "中X" + reset + " " + reset,
        "effective style run emitted once and default cell resets every attribute")
    let old = Frame(2, 1)
    old.put(0, 0, "X", style: Style(foreground: Color.Red, background: Color.Blue, bold: true))
    check(old.toAnsi(colorMode: ColorMode.Basic16) == reset + esc + "1;1H" + reset + esc + "31m" + esc + "44m" + esc + "1mX" + reset + " " + reset,
        "explicit Basic16 legacy 8color bold bytes unchanged")
    let snapshot = Frame(1, 1)
    snapshot.put(0, 0, "X", style: Style(foreground: Color.Rgb(1, 128, 254), bold: true))
    check(snapshot.toAnsi() == reset + esc + "1;1H" + reset + esc + "38;2;1;128;254m" + esc + "1mX" + reset + reset,
        "default snapshot is the pure TrueColor projection")
    for (mode in modes) { check(Frame(0, 1).toAnsi(colorMode: mode) == "" && Frame(1, 0).toAnsi(colorMode: mode) == "", "zero-area mode output empty") }
}
func componentAttributeCases(): Unit {
    let boldNode = Text("X")
    let boldReceiver = boldNode.bold()
    check(render(boldNode, 1, 1).cellAt(0, 0).style == Style(bold: true), "component bold default true changes only its own attribute")
    boldReceiver.bold(false)
    check(render(boldNode, 1, 1).cellAt(0, 0).style == Style(), "component bold explicit false and same receiver")
    let dimNode = Text("X")
    let dimReceiver = dimNode.dim()
    check(render(dimNode, 1, 1).cellAt(0, 0).style == Style(dim: true), "component dim default true changes only its own attribute")
    dimReceiver.dim(false)
    check(render(dimNode, 1, 1).cellAt(0, 0).style == Style(), "component dim explicit false and same receiver")
    let italicNode = Text("X")
    let italicReceiver = italicNode.italic()
    check(render(italicNode, 1, 1).cellAt(0, 0).style == Style(italic: true), "component italic default true changes only its own attribute")
    italicReceiver.italic(false)
    check(render(italicNode, 1, 1).cellAt(0, 0).style == Style(), "component italic explicit false and same receiver")
    let underlineNode = Text("X")
    let underlineReceiver = underlineNode.underline()
    check(render(underlineNode, 1, 1).cellAt(0, 0).style == Style(underline: true), "component underline default true changes only its own attribute")
    underlineReceiver.underline(false)
    check(render(underlineNode, 1, 1).cellAt(0, 0).style == Style(), "component underline explicit false and same receiver")
    let inverseNode = Text("X")
    let inverseReceiver = inverseNode.inverse()
    check(render(inverseNode, 1, 1).cellAt(0, 0).style == Style(inverse: true), "component inverse default true changes only its own attribute")
    inverseReceiver.inverse(false)
    check(render(inverseNode, 1, 1).cellAt(0, 0).style == Style(), "component inverse explicit false and same receiver")
    let strikethroughNode = Text("X")
    let strikethroughReceiver = strikethroughNode.strikethrough()
    check(render(strikethroughNode, 1, 1).cellAt(0, 0).style == Style(strikethrough: true), "component strikethrough default true changes only its own attribute")
    strikethroughReceiver.strikethrough(false)
    check(render(strikethroughNode, 1, 1).cellAt(0, 0).style == Style(), "component strikethrough explicit false and same receiver")
}
func components(): Unit {
    let full = Style(foreground: Color.Red, background: Color.Blue, bold: true, dim: true, italic: true,
        underline: true, inverse: true, strikethrough: true)
    let child = [Text("")]
    let root = Column { child[0] = Text("X").height(3).width(4).border(BorderStyle.Single).borderColor(Color.Green).background(Color.Blue) }
        .foreground(Color.Red).background(Color.Blue).bold().dim().italic().underline().inverse().strikethrough()
    let inherited = render(root, 4, 3)
    check(inherited.cellAt(1, 1).style == full && inherited.cellAt(2, 1).style == full, "all six attributes inherited by text and explicit background")
    let borderStyle = Style(foreground: Color.Green, background: Color.Blue, bold: true, dim: true, italic: true,
        underline: true, inverse: true, strikethrough: true)
    check(inherited.cellAt(0, 0).style == borderStyle, "borderColor replaces only foreground of complete inherited Style")
    let result = child[0].bold(false).dim(false).italic(false).underline(false).inverse(false).strikethrough(false)
    result.foreground(Color.Cyan)
    let off = render(root, 4, 3)
    check(off.cellAt(1, 1).style == Style(foreground: Color.Cyan, background: Color.Blue), "false overrides inherited six attributes; chain returns receiver")
    check(off.cellAt(0, 0).style == Style(foreground: Color.Green, background: Color.Blue), "explicit false reaches border")
    child[0].bold(true).dim(true).italic(true).underline(true).inverse(true).strikethrough(true).foreground(Color.Red)
    check(render(root, 4, 3).cellAt(1, 1).style == full, "explicit true re-enables six attributes")
    let shadow = render(Row { Text("X").width(2).height(1).shadow(style: full) }.foreground(Color.Cyan).bold(false), 4, 3)
    check(shadow.cellAt(1, 1).style == full, "shadow retains supplied full Style without ancestor override")
    let direct = Frame(3, 2)
    direct.drawBorder(Rect(0, 0, 1, 1), style: full)
    direct.drawShadow(Rect(0, 0, 1, 1), offsetX: 1, offsetY: 0, style: full)
    check(direct.cellAt(0, 0).style == full && direct.cellAt(1, 0).style == full, "public decoration primitives preserve complete Style")
    // An unchanged child remains inherited at each level; explicit false may itself be inherited.
    let nested = render(Column { Row { Text("X"); Text("Y").italic() }.italic(false) }.italic(), 2, 1)
    check(!nested.cellAt(0, 0).style.italic && nested.cellAt(1, 0).style.italic, "nested false inheritance and child true override")
}
main(): Int64 {
    models(); mapping(); encodingAndCells(); componentAttributeCases(); components()
    return 0
}

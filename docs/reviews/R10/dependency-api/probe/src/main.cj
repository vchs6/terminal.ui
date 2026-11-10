package color_probe

import ansies.api.{Color as AnsiColors, Style as AnsiStyles}
import ansies.core.{AnsiColor, AnsiStyle, AnsiColorConverter, SGR}

func dump(label: String, value: String): Unit {
    var out = label + "|"
    for (b in value.toArray()) {
        out += b.toString() + ","
    }
    println(out)
}

main(): Unit {
    let basic = [AnsiColor.Black, AnsiColor.Red, AnsiColor.Green, AnsiColor.Yellow,
        AnsiColor.Blue, AnsiColor.Magenta, AnsiColor.Cyan, AnsiColor.White,
        AnsiColor.BrightBlack, AnsiColor.BrightRed, AnsiColor.BrightGreen, AnsiColor.BrightYellow,
        AnsiColor.BrightBlue, AnsiColor.BrightMagenta, AnsiColor.BrightCyan, AnsiColor.BrightWhite,
        AnsiColor.Default]
    for (color in basic) {
        dump("fg." + color.toString(), AnsiColors.foreground(color))
        dump("bg." + color.toString(), AnsiColors.background(color))
    }
    for (i in 0..256) {
        let color = AnsiColor.IndexedColor(UInt8(i))
        dump("fg.index." + i.toString(), AnsiColors.foreground(color))
        dump("bg.index." + i.toString(), AnsiColors.background(color))
    }
    for (color in [AnsiColor.TrueColor(0, 0, 0), AnsiColor.TrueColor(255, 255, 255),
        AnsiColor.TrueColor(1, 128, 254), AnsiColor.TrueColor(255, 0, 128)]) {
        dump("fg.rgb." + color.toString(), AnsiColors.foreground(color))
        dump("bg.rgb." + color.toString(), AnsiColors.background(color))
    }
    for (style in [AnsiStyle.BOLD, AnsiStyle.DIM, AnsiStyle.ITALIC, AnsiStyle.UNDERLINE,
        AnsiStyle.REVERSE, AnsiStyle.STRIKETHROUGH]) {
        dump("set." + style.toString(), AnsiStyles.set(style))
        dump("reset." + style.toString(), AnsiStyles.reset(style))
    }
    dump("reset.all", SGR(["0"]))
    dump("reset.fg", AnsiColors.setDefaultForeground())
    dump("reset.bg", AnsiColors.setDefaultBackground())
    dump("reset.colors", AnsiColors.setDefault())
    dump("set.both", AnsiColors.setColor(AnsiColor.BrightBlue, AnsiColor.TrueColor(1, 2, 3)))
    let idx: UInt8 = 255
    let c1 = Color.Indexed(idx)
    let c2 = Color.RGB(0, 128, 255)
    let same = Color.RGB(UInt8(0), UInt8(128), UInt8(255))
    println("syntax.index.eq|" + (c1 == Color.Indexed(255)).toString())
    println("syntax.rgb.eq|" + (c2 == same).toString())
    println("syntax.rgb.ne|" + (c2 != Color.RGB(0, 128, 254)).toString())
    match (c2) {
        case Color.RGB(r, g, b) => println("syntax.rgb.payload|" + r.toString() + "," + g.toString() + "," + b.toString())
        case _ => throw Exception("wrong color")
    }
    let converter = AnsiColorConverter()
    for (color in [AnsiColor.TrueColor(1, 128, 254), AnsiColor.TrueColor(250, 0, 0),
        AnsiColor.TrueColor(255, 0, 0), AnsiColor.TrueColor(0, 0, 255),
        AnsiColor.TrueColor(128, 128, 128), AnsiColor.IndexedColor(17),
        AnsiColor.IndexedColor(196), AnsiColor.Default]) {
        println("map." + color.toString() + "|base=" + converter.toBaseColor(color).toString()
            + "|indexed=" + converter.toIndexedColor(color).toString()
            + "|rgb=" + converter.toTrueColor(color).toString())
    }
    let (r, g, b) = AnsiColorConverter.colorTable[196]
    println("palette.196|" + r.toString() + "," + g.toString() + "," + b.toString())
}

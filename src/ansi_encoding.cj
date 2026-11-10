package cjtui

import ansies.core.{CUP, SGR, AnsiColor, AnsiStyle}
import ansies.api.{Color as AnsiColors, Style as AnsiStyles}

func ansiColor(c: Color): AnsiColor {
    match (c) {
        case Color.Default => AnsiColor.Default
        case Color.Black => AnsiColor.Black
        case Color.Red => AnsiColor.Red
        case Color.Green => AnsiColor.Green
        case Color.Yellow => AnsiColor.Yellow
        case Color.Blue => AnsiColor.Blue
        case Color.Magenta => AnsiColor.Magenta
        case Color.Cyan => AnsiColor.Cyan
        case Color.White => AnsiColor.White
    }
}

func position(y: Int64, x: Int64): String {
    CUP([(y + 1).toString(), (x + 1).toString()])
}

func resetStyle(): String {
    SGR(["0"])
}

func encodeStyle(s: Style): String {
    var out = resetStyle()
    if (s.foreground != Color.Default) {
        out += AnsiColors.foreground(ansiColor(s.foreground))
    }
    if (s.background != Color.Default) {
        out += AnsiColors.background(ansiColor(s.background))
    }
    if (s.bold) {
        out += AnsiStyles.set(AnsiStyle.BOLD)
    }
    out
}

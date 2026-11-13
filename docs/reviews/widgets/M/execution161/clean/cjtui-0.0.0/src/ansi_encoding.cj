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
        case Color.BrightBlack => AnsiColor.BrightBlack
        case Color.BrightRed => AnsiColor.BrightRed
        case Color.BrightGreen => AnsiColor.BrightGreen
        case Color.BrightYellow => AnsiColor.BrightYellow
        case Color.BrightBlue => AnsiColor.BrightBlue
        case Color.BrightMagenta => AnsiColor.BrightMagenta
        case Color.BrightCyan => AnsiColor.BrightCyan
        case Color.BrightWhite => AnsiColor.BrightWhite
        case Color.Indexed(i) => AnsiColor.IndexedColor(i)
        case Color.Rgb(r, g, b) => AnsiColor.TrueColor(r, g, b)
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
    if (s.dim) {
        out += AnsiStyles.set(AnsiStyle.DIM)
    }
    if (s.italic) {
        out += AnsiStyles.set(AnsiStyle.ITALIC)
    }
    if (s.underline) {
        out += AnsiStyles.set(AnsiStyle.UNDERLINE)
    }
    if (s.inverse) {
        out += AnsiStyles.set(AnsiStyle.REVERSE)
    }
    if (s.strikethrough) {
        out += AnsiStyles.set(AnsiStyle.STRIKETHROUGH)
    }
    out
}

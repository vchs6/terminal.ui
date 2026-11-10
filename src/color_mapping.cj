package cjtui

func namedColor(index: Int64): Color {
    let colors = [Color.Black, Color.Red, Color.Green, Color.Yellow, Color.Blue, Color.Magenta, Color.Cyan, Color.White,
        Color.BrightBlack, Color.BrightRed, Color.BrightGreen, Color.BrightYellow, Color.BrightBlue, Color.BrightMagenta,
        Color.BrightCyan, Color.BrightWhite]
    colors[index]
}

func nominalRgb(index: Int64): (Int64, Int64, Int64) {
    if (index < 16) {
        let palette: Array<(Int64, Int64, Int64)> = [(0, 0, 0), (128, 0, 0), (0, 128, 0), (128, 128, 0), (0, 0, 128),
            (128, 0, 128), (0, 128, 128), (192, 192, 192), (128, 128, 128), (255, 0, 0), (0, 255, 0), (255, 255, 0),
            (0, 0, 255), (255, 0, 255), (0, 255, 255), (255, 255, 255)]
        return palette[index]
    }
    if (index < 232) {
        let levels: Array<Int64> = [0, 95, 135, 175, 215, 255]
        let i = index - 16
        return (levels[i / 36], levels[(i / 6) % 6], levels[i % 6])
    }
    let gray = 8 + 10 * (index - 232)
    (gray, gray, gray)
}

func nearestColor(r: Int64, g: Int64, b: Int64, count: Int64): Color {
    var best: Int64 = 0
    var distance: Int64 = Int64.Max
    for (i in 0..count) {
        let (x, y, z) = nominalRgb(i)
        let dr = r - x;
        let dg = g - y;
        let db = b - z
        let d = dr * dr + dg * dg + db * db
        if (d < distance) {
            distance = d
            best = i
        }
    }
    if (best < 16) {
        namedColor(best)
    } else {
        Color.Indexed(UInt8(best))
    }
}

func projectColor(color: Color, mode: ColorMode): Color {
    if (mode == ColorMode.Monochrome) {
        return Color.Default
    }
    match (color) {
        case Color.Indexed(i) =>
            if (i < 16) {
                return namedColor(Int64(i))
            }
            if (mode == ColorMode.Basic16) {
                let (r, g, b) = nominalRgb(Int64(i))
                return nearestColor(r, g, b, 16)
            }
            color
        case Color.Rgb(r, g, b) =>
            if (mode == ColorMode.TrueColor) {
                return color
            }
            nearestColor(Int64(r), Int64(g), Int64(b), if (mode == ColorMode.Basic16) {
                16
            } else {
                256
            })
        case _ => color
    }
}

func projectStyle(style: Style, mode: ColorMode): Style {
    Style(foreground: projectColor(style.foreground, mode), background: projectColor(style.background, mode),
        bold: style.bold, dim: style.dim, italic: style.italic, underline: style.underline, inverse: style.inverse,
        strikethrough: style.strikethrough)
}

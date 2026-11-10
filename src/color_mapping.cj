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
    if (mode == ColorMode.Basic8) {
        match (color) {
            case Color.Default => return color
            case Color.Black | Color.Red | Color.Green | Color.Yellow | Color.Blue | Color.Magenta | Color.Cyan
                | Color.White => return color
            case Color.BrightBlack => return nearestColor(128, 128, 128, 8)
            case Color.BrightRed => return nearestColor(255, 0, 0, 8)
            case Color.BrightGreen => return nearestColor(0, 255, 0, 8)
            case Color.BrightYellow => return nearestColor(255, 255, 0, 8)
            case Color.BrightBlue => return nearestColor(0, 0, 255, 8)
            case Color.BrightMagenta => return nearestColor(255, 0, 255, 8)
            case Color.BrightCyan => return nearestColor(0, 255, 255, 8)
            case Color.BrightWhite => return nearestColor(255, 255, 255, 8)
            case Color.Indexed(i) =>
                let (r, g, b) = nominalRgb(Int64(i))
                return nearestColor(r, g, b, 8)
            case Color.Rgb(r, g, b) => return nearestColor(Int64(r), Int64(g), Int64(b), 8)
        }
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

private let ncvUnderline: Int64 = 2
private let ncvInverse: Int64 = 4
private let ncvDim: Int64 = 16
private let ncvBold: Int64 = 32
private let ncvKnownMask: Int64 = ncvUnderline | ncvInverse | ncvDim | ncvBold

func projectTerminalStyle(style: Style, profile: TerminalRenderProfile): Style {
    let color = projectColor(style.foreground, profile.colorMode)
    let background = projectColor(style.background, profile.colorMode)
    let hasColor = color != Color.Default || background != Color.Default
    let unknownColorVideo = profile.noColorVideo > 0 && (profile.noColorVideo & ncvKnownMask) != profile.noColorVideo
    let video = if (hasColor && profile.noColorVideo >= 0 && !unknownColorVideo) {
        profile.noColorVideo
    } else {
        0
    }
    let attributesAllowed = !(hasColor && unknownColorVideo)
    Style(foreground: color, background: background,
        bold: attributesAllowed && style.bold && profile.supportsBold && (video & ncvBold) == 0,
        dim: attributesAllowed && style.dim && profile.supportsDim && (video & ncvDim) == 0,
        italic: attributesAllowed && style.italic && profile.supportsItalic,
        underline: attributesAllowed && style.underline && profile.supportsUnderline && (video & ncvUnderline) == 0,
        inverse: attributesAllowed && style.inverse && profile.supportsInverse && (video & ncvInverse) == 0,
        strikethrough: attributesAllowed && style.strikethrough && profile.supportsStrikethrough)
}

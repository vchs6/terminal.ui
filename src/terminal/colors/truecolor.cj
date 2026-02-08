package acnl.terminal.colors

import std.convert.Parsable
import std.math.abs

private func getNearestColor(color: TrueColor, palette: Array<(Byte, Byte, Byte)>): Byte {
    var minDiff = Int32.Max // cjlint-ignore !G.VAR.02 description
    var iv = 0u8
    for (idx in 0 .. palette.size) {
        let rr: Int32 = Int32(color.R) - Int32(palette[idx][0])
        let gg: Int32 = Int32(color.G) - Int32(palette[idx][1])
        let bb: Int32 = Int32(color.B) - Int32(palette[idx][2])
        let diff = rr * rr + gg * gg + bb * bb
        if (minDiff > diff) {
            minDiff = diff
            iv = UInt8(idx)
        }
    }
    iv
}

public func getNearestColor(color: TrueColor): Byte {
    var minDiff: Int32 = 255
    var idx = 0u8
    if (color.R == color.G && color.G == color.B) {
        let v: Byte = color.R
        if (v < 8) { return 16}
        if (v > 238) { return 231 }
        var i: Byte = 0
        while (i < 24u8) {
            let diff: Int32 = abs(Int32(v - i * 10 - 8))
            if (minDiff > diff) {
                minDiff = diff
                idx = 232 + i
            }
            i++
        }
        return idx
    }
    const CUBE_LEVELS: VArray<Byte, $6> = [0, 95, 135, 175, 215, 255]   // cjlint-ignore !G.VAR.02 description
    minDiff = 255 * 255 * 3
    idx = 0u8
    for (r in 0 .. 6) {
        let rr = CUBE_LEVELS[r] // cjlint-ignore !G.VAR.02 description
        for (g in 0 .. 6) {
            let gg = CUBE_LEVELS[g] // cjlint-ignore !G.VAR.02 description
            for (b in 0 .. 6) {
                let bb = CUBE_LEVELS[b]
                let (dr, dg, db): (Int32, Int32, Int32) = (Int32(color.R) - Int32(rr), Int32(color.G) - Int32(gg), Int32(color.B) - Int32(bb))
                let diff: Int32 = dr * dr + dg * dg + db * db
                if (minDiff > diff) {
                    minDiff = diff
                    idx = UInt8(16 + 36 * r + 6 * g + b)
                }
            }
        }
    }
    idx
}

public class TrueColor <: ToString & Parsable<TrueColor> & Equatable<TrueColor> {
    private var rgb: UInt32 = 0

    public init(value: UInt32) {
        rgb = value
    }

    public init(r: Byte, g: Byte, b: Byte) {
        rgb = UInt32(r) << 16 | UInt32(g) << 8 | UInt32(b)
    }

    public func toString(): String {
        "(${R}, ${G},${B})"
    }

    public operator func ==(that: TrueColor): Bool {
        rgb == that.rgb
    }

    // in class IllegalFormatException
    public static func parse(value: String): TrueColor {
        if(value.startsWith("(") && value.endsWith(")")) {
            let x = value[1 .. value.size - 1].split(",").map<UInt8>({c => UInt8.parse(c)})
            TrueColor(x[0], x[1], x[2])
        } else {
            throw IllegalFormatException("无效的格式，仅支持(xx, xx, xx)")
        }
    }

    public static func tryParse(value: String): ?TrueColor {
        try {
            parse(value)
        } catch(_) {
            None
        }
    }

    public mut prop R: Byte {
        get() { UInt8(rgb >> 16 & 0xff) }
        set(v) { rgb = UInt32(v) << 16 | (rgb & 0x0000FFFF)}
    }

    public mut prop G: Byte {
        get() { UInt8(rgb >> 8 & 0xff) }
        set(v) { rgb = UInt32(v) << 8 | (rgb & 0x00FF00FF)}
    }

    public mut prop B: Byte {
        get() { UInt8(rgb & 0xff) }
        set(v) { rgb = UInt32(v) | (rgb & 0x00FFFF00)}
    }

    // in class IllegalArgumentException
    public func toIndexedColor(colorDepth!: Byte = 8): UInt32  {
        let palette: Array<(Byte, Byte, Byte)> = [
            (0x00, 0x00, 0x00), (0x80, 0x00, 0x00), (0x00, 0x80, 0x00), (0x80, 0x80, 0x00),
            (0x00, 0x00, 0x80), (0x80, 0x00, 0x80), (0x00, 0x80, 0x80), (0xC0, 0xC0, 0xC0),
            (0x80, 0x80, 0x80), (0xFF, 0x00, 0x00), (0x00, 0xFF, 0x00), (0xFF, 0xFF, 0x00),
            (0x00, 0x00, 0xFF), (0xFF, 0x00, 0xFF), (0x00, 0xFF, 0xFF), (0xFF, 0xFF, 0xFF)
        ]
        match(colorDepth) {
            case 3  => UInt32(getNearestColor(this, palette[0 .. 8]))
            case 4  => UInt32(getNearestColor(this, palette))
            case 8  => UInt32(getNearestColor(this))
            case 24 => rgb
            case _  => throw IllegalArgumentException("颜色深度只能是3, 4, 8或24。")
        }
    }

    //标准色和高强度标准色
    public static let BLACK  : TrueColor = TrueColor(0x00, 0x00, 0x00) // 0 black
    public static let RED    : TrueColor = TrueColor(0x80, 0x00, 0x00) // 1 red
    public static let GREEN  : TrueColor = TrueColor(0x00, 0x80, 0x00) // 2 green
    public static let YELLOW : TrueColor = TrueColor(0x80, 0x80, 0x00) // 3 yellow
    public static let BLUE   : TrueColor = TrueColor(0x00, 0x00, 0x80) // 4 blue
    public static let MAGENTA: TrueColor = TrueColor(0x80, 0x00, 0x80) // 5 magenta
    public static let CYAN   : TrueColor = TrueColor(0x00, 0x80, 0x80) // 6 cyan
    public static let WHITE  : TrueColor = TrueColor(0xc0, 0xc0, 0xc0) // 7 white (light gray)
    public static let BRIGHTBLACK  : TrueColor = TrueColor(0x80, 0x80, 0x80) // 8 bright black (dark gray)
    public static let BRIGHTRED    : TrueColor = TrueColor(0xff, 0x00, 0x00) // 9 bright red
    public static let BRIGHTGREEN  : TrueColor = TrueColor(0x00, 0xff, 0x00) // 10 bright green
    public static let BRIGHTYELLOW : TrueColor = TrueColor(0xff, 0xff, 0x00) // 11 bright yellow
    public static let BRIGHTBLUE   : TrueColor = TrueColor(0x00, 0x00, 0xff) // 12 bright blue
    public static let BRIGHTMAGENTA: TrueColor = TrueColor(0xff, 0x00, 0xff) // 13 bright magenta
    public static let BRIGHTCYAN   : TrueColor = TrueColor(0x00, 0xff, 0xff) // 14 bright cyan
    public static let BRIGHTWHITE  : TrueColor = TrueColor(0xff, 0xff, 0xff) // 15 bright white
}
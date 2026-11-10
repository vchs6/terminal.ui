package cjtui

public class Frame {
    public let width: Int64
    public let height: Int64
    private let ambiguousWide: Bool
    private let cells: Array<Cell>
    public init(width: Int64, height: Int64, ambiguousWide!: Bool = false) {
        if (width < 0 || height < 0 || (height != 0 && width > Int64.Max / height)) {
            throw IllegalArgumentException("invalid frame size")
        }
        this.width = width
        this.height = height
        this.ambiguousWide = ambiguousWide
        cells = Array<Cell>(width * height, {_ => blankCell()})
    }
    private func index(x: Int64, y: Int64): Int64 {
        y * width + x
    }
    public func cellAt(x: Int64, y: Int64): Cell {
        if (x < 0 || x >= width || y < 0 || y >= height) {
            throw IllegalArgumentException("cell outside frame")
        }
        cells[index(x, y)]
    }
    private func clearAt(x: Int64, y: Int64): Unit {
        var start = x
        while (start > 0 && cells[index(start, y)].continuation) {
            start--
        }
        let span = cells[index(start, y)].width
        for (i in 0..span) {
            if (start + i < width) {
                cells[index(start + i, y)] = blankCell()
            }
        }
    }
    public func put(x: Int64, y: Int64, text: String, style!: Style = Style()): Unit {
        validateText(text)
        let clusters = graphemeClusters(text)
        var cx = x
        var cy = y
        for (cluster in clusters) {
            if (cluster == "\n" || cluster == "\r\n") {
                cx = x
                if (cy < Int64.Max) {
                    cy++
                };
                continue
            }
            let w = displayWidth(cluster, ambiguousWide: ambiguousWide)
            if (w <= 0) {
                continue
            }
            if (cy >= 0 && cy < height && cx >= 0 && cx < width && w <= width - cx) {
                for (i in 0..w) {
                    clearAt(cx + i, cy)
                }
                cells[index(cx, cy)] = Cell(cluster, w, false, style)
                for (i in 1..w) {
                    cells[index(cx + i, cy)] = Cell("", 0, true, style)
                }
            }
            if (cx > Int64.Max - w) {
                cx = Int64.Max
            } else {
                cx += w
            }
        }
    }
    public func fillRect(rect: Rect, style!: Style = Style()): Unit {
        fillClipped(rect, style, 0, 0, width, height)
    }
    func fillClipped(rect: Rect, style: Style, left: Int64, top: Int64, right: Int64, bottom: Int64): Unit {
        if (width == 0 || height == 0) {
            return
        }
        let x0 = greater(left, greater(0, rect.x));
        let y0 = greater(top, greater(0, rect.y))
        let x1 = lesser(right, lesser(width, signedAdd(rect.x, rect.width)))
        let y1 = lesser(bottom, lesser(height, signedAdd(rect.y, rect.height)))
        for (y in y0..greater(y0, y1)) {
            for (x in x0..greater(x0, x1)) {
                put(x, y, " ", style: style)
            }
        }
    }
    public func drawBorder(rect: Rect, border!: BorderStyle = BorderStyle.Single, style!: Style = Style()): Unit {
        borderClipped(rect, border, style, 0, 0, width, height)
    }
    func borderClipped(rect: Rect, border: BorderStyle, style: Style, left: Int64, top: Int64, right: Int64,
        bottom: Int64): Unit {
        if (border == BorderStyle.None || rect.width == 0 || rect.height == 0 || width == 0 || height == 0) {
            return
        }
        var tl = "┌";
        var tr = "┐";
        var bl = "└";
        var br = "┘";
        var horizontal = "─";
        var vertical = "│"
        if (border == BorderStyle.Rounded) {
            tl = "╭"
            tr = "╮"
            bl = "╰"
            br = "╯"
        }
        if (border == BorderStyle.Double) {
            tl = "╔"
            tr = "╗"
            bl = "╚"
            br = "╝"
            horizontal = "═"
            vertical = "║"
        }
        if (border == BorderStyle.Ascii || displayWidth(tl, ambiguousWide: ambiguousWide) != 1 ||
            displayWidth(tr, ambiguousWide: ambiguousWide) != 1 || displayWidth(bl, ambiguousWide: ambiguousWide) != 1 ||
            displayWidth(br, ambiguousWide: ambiguousWide) != 1 ||
            displayWidth(horizontal, ambiguousWide: ambiguousWide) != 1 ||
            displayWidth(vertical, ambiguousWide: ambiguousWide) != 1) {
            tl = "+"
            tr = "+"
            bl = "+"
            br = "+"
            horizontal = "-"
            vertical = "|"
        }
        let lastX = signedAdd(rect.x, rect.width - 1);
        let lastY = signedAdd(rect.y, rect.height - 1)
        let x0 = greater(left, greater(0, rect.x));
        let y0 = greater(top, greater(0, rect.y))
        let x1 = lesser(right, lesser(width, signedAdd(rect.x, rect.width)))
        let y1 = lesser(bottom, lesser(height, signedAdd(rect.y, rect.height)))
        for (y in y0..greater(y0, y1)) {
            for (x in x0..greater(x0, x1)) {
                var glyph = ""
                if (rect.width == 1 && rect.height == 1) {
                    glyph = "+"
                } else if (rect.width == 1) {
                    glyph = vertical
                } else if (rect.height == 1) {
                    glyph = horizontal
                } else if (y == rect.y) {
                    glyph = if (x == rect.x) {
                        tl
                    } else if (x == lastX) {
                        tr
                    } else {
                        horizontal
                    }
                } else if (y == lastY) {
                    glyph = if (x == rect.x) {
                        bl
                    } else if (x == lastX) {
                        br
                    } else {
                        horizontal
                    }
                } else if (x == rect.x || x == lastX) {
                    glyph = vertical
                }
                if (!glyph.isEmpty()) {
                    put(x, y, glyph, style: style)
                }
            }
        }
    }
    public func drawShadow(rect: Rect, offsetX!: Int64 = 1, offsetY!: Int64 = 1, style!: Style = Style()): Unit {
        shadowClipped(rect, offsetX, offsetY, style, 0, 0, width, height)
    }
    func shadowClipped(rect: Rect, dx: Int64, dy: Int64, style: Style, left: Int64, top: Int64, right: Int64,
        bottom: Int64): Unit {
        if (rect.width == 0 || rect.height == 0 || width == 0 || height == 0 || (dx == 0 && dy == 0)) {
            return
        }
        // A negatively overflowing origin plus any representable extent remains offscreen.
        if ((dx < 0 && rect.x < Int64.Min - dx) || (dy < 0 && rect.y < Int64.Min - dy)) {
            return
        }
        let sx = signedAdd(rect.x, dx);
        let sy = signedAdd(rect.y, dy)
        let x0 = greater(left, greater(0, sx));
        let y0 = greater(top, greater(0, sy))
        let x1 = lesser(right, lesser(width, signedAdd(sx, rect.width)))
        let y1 = lesser(bottom, lesser(height, signedAdd(sy, rect.height)))
        let glyph = if (displayWidth("░", ambiguousWide: ambiguousWide) == 1) {
            "░"
        } else {
            "."
        }
        for (y in y0..greater(y0, y1)) {
            for (x in x0..greater(x0, x1)) {
                if (!(containsAxis(rect.x, rect.width, x) && containsAxis(rect.y, rect.height, y))) {
                    put(x, y, glyph, style: style)
                }
            }
        }
    }
    public func toPlainText(): String {
        var out = ""
        for (y in 0..height) {
            if (y > 0) {
                out += "\n"
            }
            for (x in 0..width) {
                let c = cells[index(x, y)];
                if (!c.continuation) {
                    out += c.grapheme
                }
            }
        }
        out
    }
    func changesSince(old: Frame, oldMode: ColorMode, colorMode: ColorMode): String {
        changesSinceForTerminal(old, snapshotProfile(oldMode), snapshotProfile(colorMode))
    }
    func changesSinceForTerminal(old: Frame, oldProfile: TerminalRenderProfile, profile: TerminalRenderProfile): String {
        if (width != old.width || height != old.height) {
            return toAnsiForTerminal(profile)
        }
        var out = ""
        for (y in 0..height) {
            var changed = false
            var oldRaw = Style()
            var newRaw = Style()
            var oldProjected = projectTerminalStyle(oldRaw, oldProfile)
            var newProjected = projectTerminalStyle(newRaw, profile)
            for (x in 0..width) {
                let a = cellAt(x, y)
                let b = old.cellAt(x, y)
                if (a.grapheme != b.grapheme || a.width != b.width || a.continuation != b.continuation) {
                    changed = true
                    break
                }
                if (a.style == b.style && oldProfile.colorMode == profile.colorMode && oldProfile.supportsBold == profile
                    .supportsBold && oldProfile.supportsDim == profile.supportsDim && oldProfile.supportsItalic == profile
                    .supportsItalic && oldProfile.supportsUnderline == profile.supportsUnderline &&
                    oldProfile.supportsInverse == profile.supportsInverse && oldProfile.supportsStrikethrough == profile
                    .supportsStrikethrough && oldProfile.noColorVideo == profile.noColorVideo) {
                    continue
                }
                if (a.style != newRaw) {
                    newRaw = a.style
                    newProjected = projectTerminalStyle(newRaw, profile)
                }
                if (b.style != oldRaw) {
                    oldRaw = b.style
                    oldProjected = projectTerminalStyle(oldRaw, oldProfile)
                }
                if (newProjected != oldProjected) {
                    changed = true
                    break
                }
            }
            if (changed) {
                out += resetStyle() + position(y, 0)
                out += encodedRowForTerminal(y, profile)
                out += resetStyle()
            }
        }
        out
    }
    private func encodedRowForTerminal(y: Int64, profile: TerminalRenderProfile): String {
        var out = ""
        var previous = Style()
        var raw = Style()
        var projected = projectTerminalStyle(raw, profile)
        for (x in 0..width) {
            let c = cells[index(x, y)]
            if (!c.continuation) {
                if (c.style != raw) {
                    raw = c.style
                    projected = projectTerminalStyle(raw, profile)
                }
                if (projected != previous) {
                    out += encodeStyle(projected)
                    previous = projected
                }
                out += c.grapheme
            }
        }
        out
    }
    func toAnsiForTerminal(profile: TerminalRenderProfile): String {
        if (width == 0 || height == 0) {
            return ""
        }
        var out = resetStyle()
        for (y in 0..height) {
            out += position(y, 0)
            var previous = Style()
            var raw = Style()
            var projected = projectTerminalStyle(raw, profile)
            for (x in 0..width) {
                let c = cells[index(x, y)]
                if (!c.continuation) {
                    if (c.style != raw) {
                        raw = c.style
                        projected = projectTerminalStyle(raw, profile)
                    }
                    if (projected != previous) {
                        out += encodeStyle(projected)
                        previous = projected
                    }
                    out += c.grapheme
                }
            }
            if (previous != Style()) {
                out += resetStyle()
            }
        }
        out + resetStyle()
    }
    public func toAnsi(colorMode!: ColorMode = ColorMode.TrueColor): String {
        toAnsiForTerminal(snapshotProfile(colorMode))
    }
}

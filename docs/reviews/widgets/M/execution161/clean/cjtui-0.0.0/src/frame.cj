package cjtui

import std.fs.File

public class Frame {
    public let width: Int64
    public let height: Int64
    private let ambiguousWide: Bool
    private let cells: Array<Cell>
    private let transparent: Bool
    private let maxCells: Int64
    public init(width: Int64, height: Int64, ambiguousWide!: Bool = false, transparent!: Bool = false,
        maxCells!: Int64 = 1048576) {
        if (width < 0 || height < 0 || maxCells <= 0 ||
            (height != 0 && width > Int64.Max / height) ||
            (width > 0 && height > 0 && width > maxCells / height)) {
            throw IllegalArgumentException("invalid frame size")
        }
        this.width = width
        this.height = height
        this.ambiguousWide = ambiguousWide
        this.transparent = transparent
        this.maxCells = maxCells
        cells = Array<Cell>(width * height, {_ => blankCell(transparent)})
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
    private func clearAt(x: Int64, y: Int64, transparent: Bool): Unit {
        var start = x
        while (start > 0 && cells[index(start, y)].continuation) {
            start--
        }
        let span = cells[index(start, y)].width
        for (i in 0..span) {
            if (start + i < width) {
                cells[index(start + i, y)] = blankCell(transparent)
            }
        }
    }
    public func put(x: Int64, y: Int64, text: String, style!: Style = Style()): Unit {
        put(x, y, RichText(text), style: style)
    }
    public func put(x: Int64, y: Int64, value: RichText, style!: Style = Style()): Unit {
        let clusters = richTextClusters(value)
        var cx = x
        var cy = y
        for (span in clusters) {
            let cluster = span.text
            let resolved = span.style.resolve(style)
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
                    clearAt(cx + i, cy, transparent)
                }
                cells[index(cx, cy)] = Cell(cluster, w, false, resolved)
                for (i in 1..w) {
                    cells[index(cx + i, cy)] = Cell("", 0, true, resolved)
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
        var (tl, tr, bl, br, horizontal, vertical) = borderGlyphs(border)
        if (border == BorderStyle.Ascii || displayWidth(tl, ambiguousWide: ambiguousWide) != 1 ||
            displayWidth(tr, ambiguousWide: ambiguousWide) != 1 || displayWidth(bl, ambiguousWide: ambiguousWide) != 1 ||
            displayWidth(br, ambiguousWide: ambiguousWide) != 1 ||
            displayWidth(horizontal, ambiguousWide: ambiguousWide) != 1 ||
            displayWidth(vertical, ambiguousWide: ambiguousWide) != 1) {
            (tl, tr, bl, br, horizontal, vertical) = borderGlyphs(BorderStyle.Ascii)
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
    public func clear(rect: Rect, transparent!: Bool = false): Unit {
        if (width == 0 || height == 0) { return }
        let x0 = greater(0, rect.x)
        let y0 = greater(0, rect.y)
        let x1 = lesser(width, signedAdd(rect.x, rect.width))
        let y1 = lesser(height, signedAdd(rect.y, rect.height))
        for (y in y0..greater(y0, y1)) {
            for (x in x0..greater(x0, x1)) {
                clearAt(x, y, transparent)
            }
        }
    }
    public func copy(rect: Rect): Frame {
        let result = Frame(rect.width, rect.height, ambiguousWide: ambiguousWide, transparent: transparent,
            maxCells: maxCells)
        if (rect.x != Int64.Min && rect.y != Int64.Min) {
            result.transfer(this, -rect.x, -rect.y, false)
        }
        result
    }
    public func resized(width: Int64, height: Int64): Frame {
        let result = Frame(width, height, ambiguousWide: ambiguousWide, transparent: transparent, maxCells: maxCells)
        result.transfer(this, 0, 0, false)
        result
    }
    public func composite(layer: Frame, x!: Int64 = 0, y!: Int64 = 0): Unit {
        transfer(layer, x, y, true)
    }
    private func transfer(layer: Frame, x: Int64, y: Int64, skipTransparent: Bool): Unit {
        if (ambiguousWide != layer.ambiguousWide) {
            throw IllegalArgumentException("incompatible width policy")
        }
        if (width == 0 || height == 0 || layer.width == 0 || layer.height == 0 ||
            x >= width || y >= height || x <= -layer.width || y <= -layer.height) { return }
        let sx = if (x < 0) { -x } else { 0 }
        let sy = if (y < 0) { -y } else { 0 }
        let dx = if (x > 0) { x } else { 0 }
        let dy = if (y > 0) { y } else { 0 }
        let columns = lesser(width - dx, layer.width - sx)
        let rows = lesser(height - dy, layer.height - sy)
        // Snapshot only the intersecting cells, so overlapping self-composition reads the original.
        let source = Array<Cell>(columns * rows, {i =>
            layer.cells[layer.index(sx + i % columns, sy + i / columns)]
        })
        for (row in 0..rows) {
            var col = 0
            while (col < columns) {
                let cell = source[row * columns + col]
                if (cell.isTransparent) {
                    if (!skipTransparent) {
                        clearAt(dx + col, dy + row, transparent)
                        cells[index(dx + col, dy + row)] = cell
                    }
                    col++
                    continue
                }
                if (!cell.continuation && cell.width <= columns - col) {
                    for (i in 0..cell.width) { clearAt(dx + col + i, dy + row, transparent) }
                    for (i in 0..cell.width) {
                        cells[index(dx + col + i, dy + row)] = source[row * columns + col + i]
                    }
                    col += cell.width
                } else {
                    clearAt(dx + col, dy + row, transparent)
                    cells[index(dx + col, dy + row)] = Cell(" ", 1, false, cell.style)
                    col++
                }
            }
        }
    }
    public func writePlainText(path: String): Unit {
        File.writeTo(path, toPlainText().toArray())
    }
    public func writeAnsi(path: String, colorMode!: ColorMode = ColorMode.TrueColor): Unit {
        File.writeTo(path, toAnsi(colorMode: colorMode).toArray())
    }
    public func toPlainText(): String {
        if (width == 0 && height > 0 && height - 1 > maxCells) {
            throw IllegalArgumentException("frame text exceeds budget")
        }
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
    func changesSinceForTerminal(old: Frame, oldProfile: TerminalRenderProfile, profile: TerminalRenderProfile): String {
        if (width == 0 || height == 0) {
            return ""
        }
        if (width != old.width || height != old.height) {
            return toAnsiForTerminal(profile)
        }
        var out = ""
        for (y in 0..height) {
            let row = projectTerminalRow(this, y, profile)
            let oldRow = projectTerminalRow(old, y, oldProfile)
            if (!terminalRowsEqual(row, oldRow)) {
                out += resetStyle() + position(y, 0)
                out += encodeTerminalRow(row, false)
                out += resetStyle()
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
            out += encodeTerminalRow(projectTerminalRow(this, y, profile), true)
        }
        out + resetStyle()
    }
    public func toAnsi(colorMode!: ColorMode = ColorMode.TrueColor): String {
        toAnsiForTerminal(snapshotProfile(colorMode))
    }
}

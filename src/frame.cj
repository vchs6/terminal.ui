package cjtui

import ansies.core.{CUP, SGR, AnsiColor, AnsiStyle}
import ansies.api.{Color as AnsiColors, Style as AnsiStyles}

public enum Color <: Equatable<Color> {
    | Default | Black | Red | Green | Yellow | Blue | Magenta | Cyan | White
    public operator func ==(other: Color): Bool {
        match ((this, other)) {
            case (Default, Default) | (Black, Black) | (Red, Red) | (Green, Green) | (Yellow, Yellow) | (Blue, Blue) | (Magenta, Magenta) | (Cyan, Cyan) | (White, White) => true
            case _ => false
        }
    }
}
public struct Style <: Equatable<Style> {
    public let foreground: Color
    public let background: Color
    public let bold: Bool
    public init(foreground!: Color = Color.Default, background!: Color = Color.Default, bold!: Bool = false) {
        this.foreground = foreground; this.background = background; this.bold = bold
    }
    public operator func ==(other: Style): Bool {
        foreground == other.foreground && background == other.background && bold == other.bold
    }
}
public struct Cell {
    public let grapheme: String
    public let width: Int64
    public let continuation: Bool
    public let style: Style
    init(grapheme: String, width: Int64, continuation: Bool, style: Style) {
        this.grapheme = grapheme; this.width = width; this.continuation = continuation; this.style = style
    }
}
func blankCell(): Cell { Cell(" ", 1, false, Style()) }
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
func position(y: Int64, x: Int64): String { CUP([(y + 1).toString(), (x + 1).toString()]) }
func resetStyle(): String { SGR(["0"]) }
func encodeStyle(s: Style): String {
    var out = resetStyle()
    if (s.foreground != Color.Default) { out += AnsiColors.foreground(ansiColor(s.foreground)) }
    if (s.background != Color.Default) { out += AnsiColors.background(ansiColor(s.background)) }
    if (s.bold) { out += AnsiStyles.set(AnsiStyle.BOLD) }
    out
}
func validateText(text: String): Unit {
    for (cluster in graphemeClusters(text)) {
        if (cluster == "\n" || cluster == "\r\n") { continue }
        for (r in cluster.runes()) {
            let n = UInt32(r)
            if (n < 32 || (n >= 127 && n < 160)) { throw IllegalArgumentException("control character in text") }
        }
    }
}
public class Frame {
    public let width: Int64
    public let height: Int64
    private let ambiguousWide: Bool
    private let cells: Array<Cell>
    public init(width: Int64, height: Int64, ambiguousWide!: Bool = false) {
        if (width < 0 || height < 0 || (height != 0 && width > Int64.Max / height)) { throw IllegalArgumentException("invalid frame size") }
        this.width = width; this.height = height; this.ambiguousWide = ambiguousWide
        cells = Array<Cell>(width * height, { _ => blankCell() })
    }
    private func index(x: Int64, y: Int64): Int64 { y * width + x }
    public func cellAt(x: Int64, y: Int64): Cell {
        if (x < 0 || x >= width || y < 0 || y >= height) { throw IllegalArgumentException("cell outside frame") }
        cells[index(x, y)]
    }
    private func clearAt(x: Int64, y: Int64): Unit {
        var start = x
        while (start > 0 && cells[index(start, y)].continuation) { start-- }
        let span = cells[index(start, y)].width
        for (i in 0..span) { if (start + i < width) { cells[index(start + i, y)] = blankCell() } }
    }
    public func put(x: Int64, y: Int64, text: String, style!: Style = Style()): Unit {
        validateText(text)
        let clusters = graphemeClusters(text)
        var cx = x
        var cy = y
        for (cluster in clusters) {
            if (cluster == "\n" || cluster == "\r\n") { cx = x; cy++; continue }
            let w = displayWidth(cluster, ambiguousWide: ambiguousWide)
            if (w <= 0) { continue }
            if (cy >= 0 && cy < height && cx >= 0 && cx < width && w <= width - cx) {
                for (i in 0..w) { clearAt(cx + i, cy) }
                cells[index(cx, cy)] = Cell(cluster, w, false, style)
                for (i in 1..w) { cells[index(cx + i, cy)] = Cell("", 0, true, style) }
            }
            cx += w
        }
    }
    public func toPlainText(): String {
        var out = ""
        for (y in 0..height) {
            if (y > 0) { out += "\n" }
            for (x in 0..width) { let c = cells[index(x, y)]; if (!c.continuation) { out += c.grapheme } }
        }
        out
    }
    func changesSince(old: Frame): String {
        if (width != old.width || height != old.height) { return toAnsi() }
        var out = ""
        for (y in 0..height) {
            var changed = false
            for (x in 0..width) {
                let a = cellAt(x, y); let b = old.cellAt(x, y)
                if (a.grapheme != b.grapheme || a.width != b.width || a.continuation != b.continuation || a.style != b.style) { changed = true }
            }
            if (changed) {
                out += resetStyle() + position(y, 0)
                var previous = Style()
                for (x in 0..width) {
                    let c = cellAt(x, y)
                    if (!c.continuation) {
                        if (c.style != previous) { out += encodeStyle(c.style); previous = c.style }
                        out += c.grapheme
                    }
                }
                out += resetStyle()
            }
        }
        out
    }
    public func toAnsi(): String {
        if (width == 0 || height == 0) { return "" }
        var out = resetStyle()
        for (y in 0..height) {
            out += position(y, 0)
            var previous = Style()
            for (x in 0..width) {
                let c = cells[index(x, y)]
                if (!c.continuation) {
                    if (c.style != previous) { out += encodeStyle(c.style); previous = c.style }
                    out += c.grapheme
                }
            }
            if (previous != Style()) { out += resetStyle() }
        }
        out + resetStyle()
    }
}

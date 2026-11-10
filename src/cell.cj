package cjtui

public struct Cell {
    public let grapheme: String
    public let width: Int64
    public let continuation: Bool
    public let style: Style
    public let isTransparent: Bool
    init(grapheme: String, width: Int64, continuation: Bool, style: Style) {
        this.grapheme = grapheme
        this.width = width
        this.continuation = continuation
        this.style = style
        this.isTransparent = false
    }
    init(grapheme: String, width: Int64, continuation: Bool, style: Style, transparent: Bool) {
        this.grapheme = grapheme
        this.width = width
        this.continuation = continuation
        this.style = style
        this.isTransparent = transparent
    }
}

func blankCell(transparent: Bool): Cell {
    Cell(" ", 1, false, Style(), transparent)
}

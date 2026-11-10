package cjtui

public struct Cell {
    public let grapheme: String
    public let width: Int64
    public let continuation: Bool
    public let style: Style
    init(grapheme: String, width: Int64, continuation: Bool, style: Style) {
        this.grapheme = grapheme
        this.width = width
        this.continuation = continuation
        this.style = style
    }
}

func blankCell(): Cell {
    Cell(" ", 1, false, Style())
}

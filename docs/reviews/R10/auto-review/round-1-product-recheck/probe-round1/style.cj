package cjtui

public struct Style <: Equatable<Style> {
    public let foreground: Color
    public let background: Color
    public let bold: Bool
    public let dim: Bool
    public let italic: Bool
    public let underline: Bool
    public let inverse: Bool
    public let strikethrough: Bool
    public init(foreground!: Color = Color.Default, background!: Color = Color.Default, bold!: Bool = false,
        dim!: Bool = false, italic!: Bool = false, underline!: Bool = false, inverse!: Bool = false,
        strikethrough!: Bool = false) {
        this.foreground = foreground
        this.background = background
        this.bold = bold
        this.dim = dim
        this.italic = italic
        this.underline = underline
        this.inverse = inverse
        this.strikethrough = strikethrough
    }
    public operator func ==(other: Style): Bool {
        foreground == other.foreground && background == other.background && bold == other.bold && dim == other.dim &&
            italic == other.italic && underline == other.underline && inverse == other.inverse && strikethrough == other
            .strikethrough
    }
}

package cjtui.style

public struct TextStylePatch <: Equatable<TextStylePatch> {
    public let foreground: ?Color
    public let background: ?Color
    public let bold: ?Bool
    public let dim: ?Bool
    public let italic: ?Bool
    public let underline: ?Bool
    public let inverse: ?Bool
    public let strikethrough: ?Bool
    public init(foreground!: ?Color = None, background!: ?Color = None, bold!: ?Bool = None, dim!: ?Bool = None,
        italic!: ?Bool = None, underline!: ?Bool = None, inverse!: ?Bool = None, strikethrough!: ?Bool = None) {
        this.foreground = foreground
        this.background = background
        this.bold = bold
        this.dim = dim
        this.italic = italic
        this.underline = underline
        this.inverse = inverse
        this.strikethrough = strikethrough
    }
    public func resolve(base: Style): Style {
        Style(foreground: foreground ?? base.foreground, background: background ?? base.background,
            bold: bold ?? base.bold, dim: dim ?? base.dim, italic: italic ?? base.italic,
            underline: underline ?? base.underline, inverse: inverse ?? base.inverse,
            strikethrough: strikethrough ?? base.strikethrough)
    }
    public operator func ==(other: TextStylePatch): Bool {
        foreground == other.foreground && background == other.background && bold == other.bold && dim == other.dim &&
            italic == other.italic && underline == other.underline && inverse == other.inverse && strikethrough == other
            .strikethrough
    }
}

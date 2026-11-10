package cjtui.style

public struct Style <: Equatable<Style> {
    public let foreground: Color
    public let background: Color
    public let bold: Bool
    public init(foreground!: Color = Color.Default, background!: Color = Color.Default, bold!: Bool = false) {
        this.foreground = foreground
        this.background = background
        this.bold = bold
    }
    public operator func ==(other: Style): Bool {
        foreground == other.foreground && background == other.background && bold == other.bold
    }
}

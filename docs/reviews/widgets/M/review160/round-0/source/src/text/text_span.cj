package cjtui.text

import cjtui.style.TextStylePatch

public struct TextSpan <: Equatable<TextSpan> {
    public let text: String
    public let style: TextStylePatch
    public init(text: String, style!: TextStylePatch = TextStylePatch()) {
        this.text = text
        this.style = style
    }
    public operator func ==(other: TextSpan): Bool {
        text == other.text && style == other.style
    }
}

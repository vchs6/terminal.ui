package cjtui

public struct TextSelection <: Equatable<TextSelection> {
    public let anchor: Int64
    public let caret: Int64
    public init(anchor: Int64, caret: Int64) {
        if (anchor < 0 || caret < 0) {
            throw IllegalArgumentException("negative selection")
        }
        this.anchor = anchor
        this.caret = caret
    }
    public operator func ==(other: TextSelection): Bool {
        anchor == other.anchor && caret == other.caret
    }
}

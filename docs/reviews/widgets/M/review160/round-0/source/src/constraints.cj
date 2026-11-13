package cjtui

public struct Constraints {
    public let minWidth: Int64
    public let minHeight: Int64
    public let maxWidth: ?Int64
    public let maxHeight: ?Int64
    public let ambiguousWide: Bool
    public init(minWidth!: Int64 = 0, minHeight!: Int64 = 0, maxWidth!: ?Int64 = None,
        maxHeight!: ?Int64 = None, ambiguousWide!: Bool = false) {
        if (minWidth < 0 || minHeight < 0) { throw IllegalArgumentException("negative constraint") }
        if (let Some(value) <- maxWidth) {
            if (value < minWidth) { throw IllegalArgumentException("invalid width constraint") }
        }
        if (let Some(value) <- maxHeight) {
            if (value < minHeight) { throw IllegalArgumentException("invalid height constraint") }
        }
        this.minWidth = minWidth; this.minHeight = minHeight
        this.maxWidth = maxWidth; this.maxHeight = maxHeight; this.ambiguousWide = ambiguousWide
    }
    public func textWidth(text: String): Int64 { displayWidth(text, ambiguousWide: ambiguousWide) }
    public func constrain(size: Size): Size {
        var width = greater(size.width, minWidth)
        var height = greater(size.height, minHeight)
        if (let Some(value) <- maxWidth) { width = lesser(width, value) }
        if (let Some(value) <- maxHeight) { height = lesser(height, value) }
        Size(width, height)
    }
}

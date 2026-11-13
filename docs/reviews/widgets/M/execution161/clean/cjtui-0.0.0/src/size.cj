package cjtui

public struct Size {
    public let width: Int64
    public let height: Int64
    public init(width: Int64, height: Int64) {
        if (width < 0 || height < 0) { throw IllegalArgumentException("negative size") }
        this.width = width
        this.height = height
    }
}

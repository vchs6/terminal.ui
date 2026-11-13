package cjtui.geometry

public struct Rect {
    public let x: Int64
    public let y: Int64
    public let width: Int64
    public let height: Int64
    public init(x: Int64, y: Int64, width: Int64, height: Int64) {
        if (width < 0 || height < 0) {
            throw IllegalArgumentException("negative rectangle size")
        }
        this.x = x
        this.y = y
        this.width = width
        this.height = height
    }
}

package cjtui

public struct ViewportSnapshot {
    public let width: Int64
    public let height: Int64
    public let contentWidth: Int64
    public let contentHeight: Int64
    public let offsetX: Int64
    public let offsetY: Int64
    public let axes: ScrollAxes
    init(width: Int64, height: Int64, contentWidth: Int64, contentHeight: Int64,
        offsetX: Int64, offsetY: Int64, axes: ScrollAxes) {
        this.width = width; this.height = height; this.contentWidth = contentWidth; this.contentHeight = contentHeight
        this.offsetX = offsetX; this.offsetY = offsetY; this.axes = axes
    }
}

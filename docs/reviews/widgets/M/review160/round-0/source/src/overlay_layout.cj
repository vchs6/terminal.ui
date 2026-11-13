package cjtui

// Per-frame geometry for the same mounted layer node and the common layout path.
class OverlayLayout {
    let node: LayoutNode
    let x: Int64
    let y: Int64
    let width: Int64
    let height: Int64
    let left: Int64
    let top: Int64
    let right: Int64
    let bottom: Int64
    init(node: LayoutNode, x: Int64, y: Int64, width: Int64, height: Int64,
        left: Int64, top: Int64, right: Int64, bottom: Int64) {
        this.node = node; this.x = x; this.y = y; this.width = width; this.height = height
        this.left = left; this.top = top; this.right = right; this.bottom = bottom
    }
}

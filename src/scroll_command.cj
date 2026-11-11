package cjtui

import std.collection.ArrayList

// A bounded command owned by one mounted node generation.
class ScrollCommand {
    let target: NodeRef
    let kind: Int64 // 0 scroll, 1 ensure
    var order: Int64 = 0
    let x: Int64
    let y: Int64
    let rect: ?Rect
    let horizontal: ScrollAlign
    let vertical: ScrollAlign
    let zeroWidth = ArrayList<Int64>()
    let zeroHeight = ArrayList<Int64>()
    init(target: NodeRef, kind: Int64, x: Int64, y: Int64, rect: ?Rect,
        horizontal: ScrollAlign, vertical: ScrollAlign) {
        this.target = target; this.kind = kind; this.x = x; this.y = y; this.rect = rect
        this.horizontal = horizontal; this.vertical = vertical
    }
}

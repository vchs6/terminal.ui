package cjtui

// The mounted node generation is the sole owner of committed viewport geometry.
class ViewportState <: ObservableSource {
    var width: Int64 = 0
    var height: Int64 = 0
    var contentWidth: Int64 = 0
    var contentHeight: Int64 = 0
    var offsetX: Int64 = 0
    var offsetY: Int64 = 0
    var axes = ScrollAxes.Off
    var queuedX: ?Int64 = None
    var queuedY: ?Int64 = None
    func update(width: Int64, height: Int64, contentWidth: Int64, contentHeight: Int64, axes: ScrollAxes): Unit {
        var notify = false
        lock.lock()
        try {
            let x = if (axes.horizontal()) { lesser(offsetX,greater(0,contentWidth-width)) } else { 0 }
            let y = if (axes.vertical()) { lesser(offsetY,greater(0,contentHeight-height)) } else { 0 }
            if (this.width != width || this.height != height || this.contentWidth != contentWidth ||
                this.contentHeight != contentHeight || this.axes != axes || offsetX != x || offsetY != y) {
                this.width = width; this.height = height; this.contentWidth = contentWidth; this.contentHeight = contentHeight
                this.axes = axes; offsetX = x; offsetY = y; version++; notify = true
            }
        } finally { lock.unlock() }
        if (notify) { emit() }
    }
    func setOffset(x: Int64, y: Int64): Bool {
        var changed = false
        lock.lock()
        try {
            let nx = if (axes.horizontal()) { lesser(greater(0,x),greater(0,contentWidth-width)) } else { 0 }
            let ny = if (axes.vertical()) { lesser(greater(0,y),greater(0,contentHeight-height)) } else { 0 }
            if (nx != offsetX || ny != offsetY) { offsetX = nx; offsetY = ny; version++; changed = true }
        } finally { lock.unlock() }
        if (changed) { emit() }
        changed
    }
    func snapshot(): ViewportSnapshot {
        lock.lock()
        let result: ViewportSnapshot
        let observed: Int64
        try {
            result = ViewportSnapshot(width,height,contentWidth,contentHeight,offsetX,offsetY,axes)
            observed = version
        } finally { lock.unlock() }
        if (let Some(binding) <- evaluating.get()) { binding.read(this,observed) }
        result
    }
}

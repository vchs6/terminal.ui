package cjtui

import std.collection.ArrayList

class RuntimeNode {
    let component: Component
    let session: RuntimeSession
    let id: Int64
    let parent: ?RuntimeNode
    var overlayRoot = false
    var overlayModal = false
    var screenX: Int64 = 0
    var screenY: Int64 = 0
    var clipLeft: Int64 = 0
    var clipTop: Int64 = 0
    var clipRight: Int64 = 0
    var clipBottom: Int64 = 0
    let sequence = ArrayList<ChildEntry>()
    var layout: ?LayoutNode = None
    let viewportState = ViewportState()
    // Geometry is in the parent's logical content coordinates.
    var layoutX: Int64 = 0
    var layoutY: Int64 = 0
    var layoutWidth: Int64 = 0
    var layoutHeight: Int64 = 0
    var contentX: Int64 = 0
    var contentY: Int64 = 0
    var logicalWidth: Int64 = 0
    var logicalHeight: Int64 = 0
    // Last root-layout measurements remain valid facts across layout invalidation.
    var canvasNatural: ?Size = None
    var canvasConstrained: ?Size = None
    let depth: Int64
    var groupId: Int64 = 0
    var groupKey = ""
    var effectStarted = false
    var bindingCount: Int64 = 0
    // Retained separately so later incremental rendering can distinguish effects.
    var contentDirty = true
    var styleDirty = true
    var layoutDirty = true
    var pendingChange: ?PendingNodeChange = None
    var valid = true
    var committed = false
    var cleanup: ?() -> Unit = None
    var intrinsicCleanup: ?() -> Unit = None
    init(component: Component, session: RuntimeSession, id: Int64, parent: ?RuntimeNode) {
        this.component = component
        this.session = session
        this.id = id
        this.parent = parent
        viewportState.axes = if (component.viewportDeclared) { component.viewportAxes }
            else if (parent.isNone() && !session.temporary) { ScrollAxes.Vertical } else { ScrollAxes.Off }
        depth = match (parent) {
            case Some(node) => node.depth + 1;
            case None => 0
        }
    }
    func reference(): NodeRef {
        NodeRef(this)
    }
}

package cjtui

import std.collection.ArrayList

class RuntimeNode {
    let component: Component
    let session: RuntimeSession
    let id: Int64
    let parent: ?RuntimeNode
    let sequence = ArrayList<ChildEntry>()
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
    init(component: Component, session: RuntimeSession, id: Int64, parent: ?RuntimeNode) {
        this.component = component
        this.session = session
        this.id = id
        this.parent = parent
        depth = match (parent) {
            case Some(node) => node.depth + 1;
            case None => 0
        }
    }
    func reference(): NodeRef {
        NodeRef(this)
    }
}

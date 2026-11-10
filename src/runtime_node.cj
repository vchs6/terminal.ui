package cjtui

import std.collection.ArrayList

class RuntimeNode {
    let component: Component
    let session: RuntimeSession
    let id: Int64
    let parent: ?RuntimeNode
    let children = ArrayList<RuntimeNode>()
    var valid = true
    var cleanup: ?() -> Unit = None
    init(component: Component, session: RuntimeSession, id: Int64, parent: ?RuntimeNode) {
        this.component = component; this.session = session; this.id = id; this.parent = parent
    }
    func reference(): NodeRef { NodeRef(this) }
}

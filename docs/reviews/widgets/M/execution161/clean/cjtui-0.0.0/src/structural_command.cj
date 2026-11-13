package cjtui

class StructuralCommand {
    // insert, move, remove; absent anchor means the physical end.
    let kind: Int64
    let parent: NodeRef
    let child: ?NodeRef
    let description: ?Component
    let anchor: ?NodeRef
    init(kind: Int64, parent: NodeRef, child: ?NodeRef, description: ?Component, anchor: ?NodeRef) {
        this.kind = kind
        this.parent = parent
        this.child = child
        this.description = description
        this.anchor = anchor
    }
}

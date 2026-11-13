package cjtui

// Queue metadata only; applied to the mounted node on its owning UI thread.
class PendingNodeChange {
    let node: RuntimeNode
    var sequence: Int64
    var content = false
    var style = false
    var layout = false
    init(node: RuntimeNode, sequence: Int64) { this.node = node; this.sequence = sequence }
    func include(change: ChangeKind): Unit {
        if (change == ChangeKind.Content || change == ChangeKind.All) { content = true }
        if (change == ChangeKind.Style || change == ChangeKind.All) { style = true }
        if (change == ChangeKind.Layout || change == ChangeKind.Structure || change == ChangeKind.All) { layout = true }
    }
}

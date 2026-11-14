package cjtui

// One bounded record per node. Each category retains its earliest and latest
// generation so consumption at a UI cutoff cannot erase a later notification.
class PendingNodeChange {
    let node: RuntimeNode
    var sequence: Int64 = -1
    var content: Int64 = -1
    var contentLast: Int64 = -1
    var style: Int64 = -1
    var styleLast: Int64 = -1
    var layout: Int64 = -1
    var layoutLast: Int64 = -1
    var structure: Int64 = -1
    var structureLast: Int64 = -1
    init(node: RuntimeNode) { this.node = node }
    func include(change: ChangeKind, generation: Int64): Unit {
        if (change == ChangeKind.Content || change == ChangeKind.All) {
            if (content < 0 || generation < content) { content = generation }
            if (generation > contentLast) { contentLast = generation }
        }
        if (change == ChangeKind.Style || change == ChangeKind.All) {
            if (style < 0 || generation < style) { style = generation }
            if (generation > styleLast) { styleLast = generation }
        }
        if (change == ChangeKind.Layout || change == ChangeKind.All) {
            if (layout < 0 || generation < layout) { layout = generation }
            if (generation > layoutLast) { layoutLast = generation }
        }
        if (change == ChangeKind.Structure || change == ChangeKind.All) {
            if (structure < 0 || generation < structure) { structure = generation }
            if (generation > structureLast) { structureLast = generation }
        }
        updateSequence()
    }
    func updateSequence(): Unit {
        sequence = content
        if (style >= 0 && (sequence < 0 || style < sequence)) { sequence = style }
        if (layout >= 0 && (sequence < 0 || layout < sequence)) { sequence = layout }
        if (structure >= 0 && (sequence < 0 || structure < sequence)) { sequence = structure }
    }
    func consume(cutoff: Int64): Unit {
        if (content >= 0 && content <= cutoff) {
            node.session.markNodeDirtyLocked(node,ChangeKind.Content)
            content = if (contentLast > cutoff) { contentLast } else { -1 }
            if (content < 0) { contentLast = -1 }
        }
        if (style >= 0 && style <= cutoff) {
            node.session.markNodeDirtyLocked(node,ChangeKind.Style)
            style = if (styleLast > cutoff) { styleLast } else { -1 }
            if (style < 0) { styleLast = -1 }
        }
        if (layout >= 0 && layout <= cutoff) {
            node.session.markNodeDirtyLocked(node,ChangeKind.Layout)
            layout = if (layoutLast > cutoff) { layoutLast } else { -1 }
            if (layout < 0) { layoutLast = -1 }
        }
        if (structure >= 0 && structure <= cutoff) {
            node.session.markNodeDirtyLocked(node,ChangeKind.Structure)
            structure = if (structureLast > cutoff) { structureLast } else { -1 }
            if (structure < 0) { structureLast = -1 }
        }
        updateSequence()
    }
}

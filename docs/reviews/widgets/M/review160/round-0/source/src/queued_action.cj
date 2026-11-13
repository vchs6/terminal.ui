package cjtui

class QueuedAction {
    let owner: ?NodeRef
    let action: () -> Unit
    init(owner: ?NodeRef, action: () -> Unit) { this.owner = owner; this.action = action }
}

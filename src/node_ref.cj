package cjtui

import std.ref.{WeakRef, CleanupPolicy}

public class NodeRef {
    private let node: WeakRef<RuntimeNode>
    private let sessionId: Int64
    private let nodeId: Int64
    init(node: RuntimeNode) {
        this.node = WeakRef<RuntimeNode>(node, CleanupPolicy.EAGER)
        sessionId = node.session.id
        nodeId = node.id
    }
    public func isValid(): Bool {
        match (node.value) { case Some(value) => value.session.isValid(value); case None => false }
    }
    public func sameNode(other: NodeRef): Bool { sessionId == other.sessionId && nodeId == other.nodeId }
    func belongsTo(session: RuntimeSession): Bool { sessionId == session.id }
    func resolve(): RuntimeNode {
        match (node.value) {
            case Some(value) => if (value.session.isValid(value)) { return value }
            case None => ()
        }
        throw UIException("StaleReference", "node is no longer mounted")
    }
    public func notify(change: ChangeKind): Unit {
        if (evaluating.get().isSome()) { throw UIException("ReentrantEvaluation", "node notification during evaluation") }
        let value = resolve()
        value.session.notify(value, change)
    }
}

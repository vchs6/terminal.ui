package cjtui

import std.collection.ArrayList
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
        match (node.value) {
            case Some(value) => value.session.isValid(value);
            case None => false
        }
    }
    public func sameNode(other: NodeRef): Bool {
        sessionId == other.sessionId && nodeId == other.nodeId
    }
    func belongsTo(session: RuntimeSession): Bool {
        sessionId == session.id
    }
    func resolve(): RuntimeNode {
        match (node.value) {
            case Some(value) =>
                if (value.session.isValid(value)) {
                    return value
                }
            case None => ()
        }
        throw UIException("StaleReference", "node is no longer mounted")
    }
    public func notify(change: ChangeKind): Unit {
        if (structureEvaluation.get().isSome()) {
            throw UIException("ReentrantStructure", "node notification during structure evaluation")
        }
        if (evaluating.get().isSome()) {
            throw UIException("ReentrantEvaluation", "node notification during evaluation")
        }
        let value = resolve()
        value.session.notify(value, change)
    }
    private func structureSession(): RuntimeSession {
        match (node.value) {
            case Some(value) =>
                value.session.requireStructure();
                value.session
            case None => throw UIException("StaleReference", "node is no longer mounted")
        }
    }
    public func children(): Array<NodeRef> {
        let value = resolve()
        value.session.requireContext()
        let result = ArrayList<NodeRef>()
        for (entry in value.sequence) {
            if (let ChildEntry.MountedChild(child) <- entry) {
                result.add(child.reference())
            }
        }
        result.toArray()
    }
    public func insertBefore(anchor: NodeRef, child: Component): Unit {
        structureSession().enqueue(StructuralCommand(0, this, Option<NodeRef>.None, Some(child), Some(anchor)))
    }
    public func append(child: Component): Unit {
        structureSession().enqueue(StructuralCommand(0, this, Option<NodeRef>.None, Some(child), Option<NodeRef>.None))
    }
    public func moveBefore(child: NodeRef, anchor: NodeRef): Unit {
        structureSession().enqueue(StructuralCommand(1, this, Some(child), Option<Component>.None, Some(anchor)))
    }
    public func moveToEnd(child: NodeRef): Unit {
        structureSession().enqueue(StructuralCommand(1, this, Some(child), Option<Component>.None, Option<NodeRef>.None))
    }
    public func remove(child: NodeRef): Unit {
        structureSession().enqueue(StructuralCommand(2, this, Some(child), Option<Component>.None, Option<NodeRef>.None))
    }
}

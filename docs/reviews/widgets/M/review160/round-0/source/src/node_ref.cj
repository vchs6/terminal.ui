package cjtui

import std.collection.ArrayList

public class NodeRef {
    private let sessionId: Int64
    private let nodeId: Int64
    init(node: RuntimeNode) {
        sessionId = node.session.id
        nodeId = node.id
    }
    public func isValid(): Bool {
        match (activeNodeIndex.get(nodeId)) {
            case Some(value) => value.session.id == sessionId && value.session.isValid(value);
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
        match (activeNodeIndex.get(nodeId)) {
            case Some(value) =>
                if (value.session.id == sessionId && value.session.isValid(value)) {
                    return value
                }
            case None => ()
        }
        throw UIException("StaleReference", "node is no longer mounted")
    }
    public func isFocused(): Bool {
        let value = resolve(); value.session.requireReadContext(); value.session.focusManager.observe()
        if (let Some(focused) <- value.session.focusManager.focused) { focused.id == value.id } else { false }
    }
    public func isEnabled(): Bool {
        let value = resolve(); value.session.requireReadContext(); value.session.focusManager.observe()
        value.session.focusManager.effective(value,true)
    }
    public func isVisible(): Bool {
        let value = resolve(); value.session.requireReadContext(); value.session.focusManager.observe()
        value.session.focusManager.effective(value,false)
    }
    public func application(): Application {
        let value = resolve(); value.session.requireReadContext()
        if (let Some(app) <- value.session.application) { return app }
        throw UIException("SessionInactive", "node has no application")
    }
    public func requestFocus(): Unit {
        let value = resolve(); value.session.requireContext()
        if (value.session.inLifecycle) { throw UIException("LifecycleReentry", "focus during lifecycle") }
        if (!value.session.inOverlayDomain(value)) { throw UIException("FocusOutsideDomain", "focus outside modal domain") }
        value.session.enqueueFocus(this)
    }
    public func openOverlay(content: Component, options!: OverlayOptions = OverlayOptions()): OverlayHandle {
        let value = resolve()
        value.session.requireStructure()
        value.session.openOverlay(value,content,options)
    }
    public func viewportSnapshot(): ViewportSnapshot {
        let value = resolve(); value.session.requireReadContext()
        if (value.session.viewportAxes(value).isNone()) { throw UIException("InvalidProperty", "node has no viewport") }
        value.viewportState.snapshot()
    }
    public func scrollTo(x: Int64, y: Int64): Bool {
        let value = resolve(); value.session.requireContext()
        if (value.session.inLifecycle) { throw UIException("LifecycleReentry", "scroll during lifecycle") }
        if (x < 0 || y < 0) { throw IllegalArgumentException("negative scroll position") }
        let axes = match (value.session.viewportAxes(value)) {
            case Some(current) => current
            case None => throw UIException("InvalidProperty", "node has no viewport")
        }
        let state = value.viewportState; let snap = state.snapshot()
        let oldX = state.queuedX ?? snap.offsetX; let oldY = state.queuedY ?? snap.offsetY
        let nextX = if (axes.horizontal()) { lesser(x,greater(0,snap.contentWidth-snap.width)) } else { 0 }
        let nextY = if (axes.vertical()) { lesser(y,greater(0,snap.contentHeight-snap.height)) } else { 0 }
        if (nextX == oldX && nextY == oldY) { return false }
        value.session.enqueueViewport(ScrollCommand(this,0,nextX,nextY,Option<Rect>.None,ScrollAlign.Nearest,ScrollAlign.Nearest))
        true
    }
    public func scrollBy(dx: Int64, dy: Int64): Bool {
        let value = resolve(); value.session.requireContext()
        if (value.session.inLifecycle) { throw UIException("LifecycleReentry", "scroll during lifecycle") }
        if (value.session.viewportAxes(value).isNone()) { throw UIException("InvalidProperty", "node has no viewport") }
        let state = value.viewportState; let snap = state.snapshot()
        scrollTo(greater(0,signedAdd(state.queuedX ?? snap.offsetX,dx)),greater(0,signedAdd(state.queuedY ?? snap.offsetY,dy)))
    }
    public func ensureVisible(rect!: ?Rect = None, horizontal!: ScrollAlign = ScrollAlign.Nearest,
        vertical!: ScrollAlign = ScrollAlign.Nearest): Unit {
        let value = resolve(); value.session.requireContext()
        if (value.session.inLifecycle) { throw UIException("LifecycleReentry", "ensure during lifecycle") }
        if (!value.session.focusManager.effective(value,false)) { throw UIException("InvalidProperty", "hidden target") }
        if (let Some(area) <- rect) {
            if (area.x < 0 || area.y < 0) {
                throw UIException("InvalidProperty", "rectangle outside content")
            }
            if (!value.session.geometryMayChange()) {
                if (area.x > value.logicalWidth || area.y > value.logicalHeight ||
                    area.width > value.logicalWidth-area.x || area.height > value.logicalHeight-area.y) {
                    throw UIException("InvalidProperty", "rectangle outside content")
                }
            }
            if (area.width == 0 || area.height == 0) { return }
        }
        let command = ScrollCommand(this,1,0,0,rect,horizontal,vertical)
        command.explicitEnsure = true
        value.session.enqueueViewport(command)
    }
    // Caret geometry may become stale if a source changes before layout.
    // Preserve public validation but discard a stale framework-owned request.
    // Call only from an event, post or batch: before stabilization the newly
    // enqueued command is still the tail of the existing viewport queue.
    func ensureEditingCaret(rect: Rect): Unit {
        ensureVisible(rect: Some(rect))
        let session = resolve().session
        if (!session.viewportCommands.isEmpty()) {
            let command = session.viewportCommands[session.viewportCommands.size - 1]
            if (command.target.sameNode(this) && command.kind == 1) { command.explicitEnsure = false }
        }
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
        match (activeNodeIndex.get(nodeId)) {
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

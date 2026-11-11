package cjtui

import std.collection.ArrayList

// One session owns both focus identity and read-dependency invalidation.
class FocusManager <: ObservableSource {
    var session: ?RuntimeSession = None
    var focused: ?RuntimeNode = None
    var previous = Array<RuntimeNode>()
    let requested = ArrayList<NodeRef>()
    let requestedOrders = ArrayList<Int64>()
    init() {}
    func observe(): Unit {
        lock.lock(); let observed = version; lock.unlock()
        if (let Some(binding) <- evaluating.get()) { binding.read(this,observed) }
    }
    func changed(): Unit {
        lock.lock(); version++; lock.unlock()
        emit()
    }
    func effective(node: RuntimeNode, enabled: Bool): Bool {
        var cursor: ?RuntimeNode = Some(node)
        while (let Some(current) <- cursor) {
            if (!current.valid || !current.committed) { return false }
            if (enabled && !current.component.isEnabled) { return false }
            if (!enabled && !current.component.isVisible) { return false }
            if (enabled && current.overlayRoot) { break }
            cursor = current.parent
        }
        true
    }
    func eligible(node: RuntimeNode): Bool {
        if (!node.component.isFocusable) { return false }
        if (!effective(node,true)) { return false }
        effective(node,false)
    }
    func collect(node: RuntimeNode, result: ArrayList<RuntimeNode>): Unit {
        if (eligible(node)) { result.add(node) }
        for (entry in node.sequence) {
            if (let ChildEntry.MountedChild(child) <- entry) { collect(child,result) }
        }
    }
    func candidates(): Array<RuntimeNode> {
        let result = ArrayList<RuntimeNode>()
        let owner = session.getOrThrow()
        if (owner.topModal().isNone()) {
            if (let Some(root) <- owner.root.readMount()) { collect(root,result) }
        }
        for (record in owner.overlayRecords) {
            if (record.terminal.isSome() || record.options.mode == OverlayMode.Passive) { continue }
            if (let Some(rootRef) <- record.root) {
                if (rootRef.isValid()) {
                    let root = rootRef.resolve()
                    if (owner.inOverlayDomain(root)) { collect(root,result) }
                }
            }
        }
        result.toArray()
    }
    func set(next: ?RuntimeNode, order!: Int64 = 0): Unit {
        let oldId = if (let Some(old) <- focused) { old.id } else { -1 }
        let newId = if (let Some(value) <- next) { value.id } else { -1 }
        if (oldId == newId) { return }
        if (let Some(target) <- next) {
            if (let Some(reserved) <- session.getOrThrow().reservedLayer) {
                if (let Some(rootRef) <- reserved.root) {
                    if (rootRef.isValid()) {
                        if (!session.getOrThrow().overlayAncestor(rootRef.resolve(),target)) { session.getOrThrow().reservedLayer = None }
                    }
                }
            }
        }
        let old = focused
        focused = next
        session.getOrThrow().lastCaret = None
        if (let Some(target) <- next) {
            if (!session.getOrThrow().temporary) { session.getOrThrow().queueFocusEnsure(target.reference(),order) }
        } else { session.getOrThrow().pendingFocusEnsure = None }
        if (let Some(previousNode) <- old) { session.getOrThrow().markChanged(previousNode,ChangeKind.Style) }
        session.getOrThrow().invalidateBehaviorStyle()
        changed()
    }
    func cancelInvalidRequests(): Unit {
        var i: Int64 = 0
        while (i < requested.size) {
            if (!requested[i].isValid()) { requested.remove(at:i); requestedOrders.remove(at:i) } else { i++ }
        }
    }
    func repair(): Unit {
        let current = candidates()
        if (let Some(old) <- focused) {
            if (!eligible(old) || !session.getOrThrow().inOverlayDomain(old)) {
                var index: Int64 = -1
                for (i in 0..previous.size) { if (previous[i].id == old.id) { index = i; break } }
                var replacement: ?RuntimeNode = None
                if (index >= 0) {
                    var i = index + 1
                    while (i < previous.size && replacement.isNone()) {
                        if (eligible(previous[i]) && session.getOrThrow().inOverlayDomain(previous[i])) { replacement = Some(previous[i]) }; i++
                    }
                    i = index - 1
                    while (i >= 0 && replacement.isNone()) {
                        if (eligible(previous[i]) && session.getOrThrow().inOverlayDomain(previous[i])) { replacement = Some(previous[i]) }; i--
                    }
                }
                if (replacement.isNone() && !current.isEmpty()) { replacement = Some(current[0]) }
                set(replacement)
            }
        } else if (!session.getOrThrow().isStopping()) {
            if (let Some(reserved) <- session.getOrThrow().reservedLayer) {
                if (let Some(rootRef) <- reserved.root) {
                    if (rootRef.isValid()) {
                        let choices = ArrayList<RuntimeNode>(); collect(rootRef.resolve(),choices)
                        if (!choices.isEmpty()) { set(Some(choices[0])) }
                    }
                }
            } else if (!current.isEmpty()) { set(Some(current[0])) }
        }
        for (i in 0..requested.size) {
            session.getOrThrow().useStructuralOps(1)
            let node = requested[i].resolve()
            if (!session.getOrThrow().inOverlayDomain(node)) { throw UIException("FocusOutsideDomain","focus outside modal domain") }
            if (!eligible(node)) { throw UIException("InvalidFocusTarget","node cannot receive focus") }
            set(Some(node),order:requestedOrders[i])
        }
        requested.clear(); requestedOrders.clear()
        previous = current
    }
    func move(backward: Bool): Bool {
        let current = candidates()
        if (current.isEmpty()) { return false }
        var index: Int64 = if (backward) { 0 } else { -1 }
        if (let Some(old) <- focused) {
            for (i in 0..current.size) { if (current[i].id == old.id) { index = i; break } }
        }
        let next = if (backward) { (index + current.size - 1) % current.size } else { (index + 1) % current.size }
        set(Some(current[next])); previous = current
        true
    }
}

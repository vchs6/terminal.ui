package cjtui

import std.collection.ArrayList

// One session owns both focus identity and read-dependency invalidation.
class FocusManager <: ObservableSource {
    var session: ?RuntimeSession = None
    var focused: ?RuntimeNode = None
    var previous = Array<RuntimeNode>()
    let requested = ArrayList<NodeRef>()
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
            if (!current.valid || !current.committed || !current.component.isVisible) { return false }
            if (enabled && !current.component.isEnabled) { return false }
            cursor = current.parent
        }
        true
    }
    func eligible(node: RuntimeNode): Bool { node.component.isFocusable && effective(node,true) }
    func collect(node: RuntimeNode, result: ArrayList<RuntimeNode>): Unit {
        if (eligible(node)) { result.add(node) }
        for (entry in node.sequence) {
            if (let ChildEntry.MountedChild(child) <- entry) { collect(child,result) }
        }
    }
    func candidates(): Array<RuntimeNode> {
        let result = ArrayList<RuntimeNode>()
        if (let Some(root) <- session.getOrThrow().root.readMount()) { collect(root,result) }
        result.toArray()
    }
    func set(next: ?RuntimeNode): Unit {
        let oldId = if (let Some(old) <- focused) { old.id } else { -1 }
        let newId = if (let Some(value) <- next) { value.id } else { -1 }
        if (oldId == newId) { return }
        let old = focused
        focused = next
        if (let Some(previousNode) <- old) { session.getOrThrow().markChanged(previousNode,ChangeKind.Style) }
        if (let Some(root) <- session.getOrThrow().root.readMount()) { session.getOrThrow().markChanged(root,ChangeKind.Style) }
        changed()
    }
    func repair(): Unit {
        let current = candidates()
        if (let Some(old) <- focused) {
            if (!eligible(old)) {
                var index: Int64 = -1
                for (i in 0..previous.size) { if (previous[i].id == old.id) { index = i; break } }
                var replacement: ?RuntimeNode = None
                if (index >= 0) {
                    var i = index + 1
                    while (i < previous.size && replacement.isNone()) {
                        if (eligible(previous[i])) { replacement = Some(previous[i]) }; i++
                    }
                    i = index - 1
                    while (i >= 0 && replacement.isNone()) {
                        if (eligible(previous[i])) { replacement = Some(previous[i]) }; i--
                    }
                }
                if (replacement.isNone() && !current.isEmpty()) { replacement = Some(current[0]) }
                set(replacement)
            }
        } else if (!current.isEmpty() && !session.getOrThrow().isStopping()) { set(Some(current[0])) }
        for (ref in requested) {
            let node = ref.resolve()
            if (!eligible(node)) { throw UIException("InvalidFocusTarget","node cannot receive focus") }
            set(Some(node))
        }
        requested.clear()
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

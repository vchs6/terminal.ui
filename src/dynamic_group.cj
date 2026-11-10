package cjtui

import std.collection.{ArrayList, HashSet}

abstract class DynamicGroup {
    let id = uniqueRuntimeId()
    let parent: RuntimeNode
    var plan: ?() -> Unit = None
    init(parent: RuntimeNode) {
        this.parent = parent
    }
    public func prepare(): Unit
    public open func forget(_: String): Unit {}
    func owned(): Array<RuntimeNode> {
        let result = ArrayList<RuntimeNode>()
        for (entry in parent.sequence) {
            if (let ChildEntry.MountedChild(node) <- entry) {
                if (node.groupId == id) {
                    result.add(node)
                }
            }
        }
        result.toArray()
    }
    func commit(): Unit {
        if (let Some(action) <- plan) {
            plan = None
            action()
        }
    }
    // Replace owned slots in their current physical order. Other entries stay in order,
    // including markers and nodes moved from other groups.
    func replace(next: Array<RuntimeNode>): Unit {
        let old = owned()
        var changed = old.size != next.size
        for (i in 0..old.size) {
            if (i < next.size && old[i].id != next[i].id) {
                changed = true
            }
        }
        if (!changed) {
            return
        }
        let result = ArrayList<ChildEntry>()
        var slot: Int64 = 0
        var last: Int64 = -1
        for (i in 0..parent.sequence.size) {
            if (let ChildEntry.MountedChild(node) <- parent.sequence[i]) {
                if (node.groupId == id) {
                    last = i
                }
            }
        }
        for (i in 0..parent.sequence.size) {
            let entry = parent.sequence[i]
            var own = false
            if (let ChildEntry.MountedChild(node) <- entry) {
                own = node.groupId == id
            }
            if (own) {
                if (slot < next.size) {
                    result.add(ChildEntry.MountedChild(next[slot]));
                    slot++
                }
                if (i == last) {
                    while (slot < next.size) {
                        result.add(ChildEntry.MountedChild(next[slot]));
                        slot++
                    }
                }
            } else {
                if (last < 0) {
                    if (let ChildEntry.GroupMarker(group) <- entry) {
                        if (group.id == id) {
                            while (slot < next.size) {
                                result.add(ChildEntry.MountedChild(next[slot]));
                                slot++
                            }
                        }
                    }
                }
                result.add(entry)
            }
        }
        parent.sequence.clear()
        parent.sequence.add(all: result)
        let removed = ArrayList<RuntimeNode>()
        let retained = HashSet<Int64>()
        for (node in next) {
            retained.add(node.id)
        }
        for (node in old) {
            if (!retained.contains(node.id)) {
                forget(node.groupKey);
                removed.add(node)
            }
        }
        parent.session.publish(next, removed.toArray())
        parent.session.markChanged(parent, ChangeKind.Structure)
        parent.session.unmount(removed.toArray())
    }
}

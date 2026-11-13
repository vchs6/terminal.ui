package cjtui

import std.collection.ArrayList

class MenuRefs {
    let entries = ArrayList<NodeRef>()
    func add(ref: NodeRef): Unit {
        entries.add(ref)
    }
    func remove(ref: NodeRef): Unit {
        var i = 0
        while (i < entries.size) {
            if (entries[i].sameNode(ref)) {
                entries.remove(at: i);
                return
            }
            i++
        }
    }
    func contains(ref: NodeRef): Bool {
        for (entry in entries) {
            if (entry.sameNode(ref)) {
                return true
            }
        }
        false
    }
}

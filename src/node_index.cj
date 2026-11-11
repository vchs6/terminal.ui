package cjtui

import std.collection.HashMap
import std.sync.Mutex

// Active generations are indexed independently of public handle lifetimes.
class NodeIndex {
    private let lock = Mutex()
    private let nodes = HashMap<Int64, RuntimeNode>()
    func add(node: RuntimeNode): Unit {
        lock.lock()
        try { nodes[node.id] = node } finally { lock.unlock() }
    }
    func remove(node: RuntimeNode): Unit {
        lock.lock()
        try { nodes.remove(node.id) } finally { lock.unlock() }
    }
    func get(id: Int64): ?RuntimeNode {
        lock.lock()
        try { nodes.get(id) } finally { lock.unlock() }
    }
}

let activeNodeIndex = NodeIndex()

package cjtui

import std.collection.ArrayList
import std.sync.Mutex

let evaluating = ThreadLocal<Binding>()

class Binding {
    let id = uniqueRuntimeId()
    let component: Component
    let name: String
    let category: ChangeKind
    let getter: () -> Unit
    let dependencies = ArrayList<BindingDependency>()
    let ownerLock = Mutex()
    var owner: ?RuntimeSession = None
    var publishedDependencies: Int64 = 0
    var dirty = true
    var dirtySequence: Int64 = 0
    var active = false
    init(component: Component, name: String, category: ChangeKind, getter: () -> Unit) {
        this.component = component; this.name = name; this.category = category; this.getter = getter
    }
    func read(source: ObservableSource, version: Int64): Unit {
        for (entry in dependencies) { if (entry.source.id == source.id) { return } }
        if (let Some(node) <- component.readMount()) {
            if (dependencies.size >= node.session.limits.dependenciesPerBinding) {
                throw UIException("CapacityExceeded", "dependency limit exceeded")
            }
        }
        dependencies.add(BindingDependency(source, version))
    }
    func invalidate(deferred!: Bool = false): Unit {
        ownerLock.lock()
        try { if (let Some(session) <- owner) { session.invalidate(this, deferred: deferred) } } finally { ownerLock.unlock() }
    }
    func evaluate(): Unit {
        for (entry in dependencies) { entry.source.unsubscribe(this) }
        dependencies.clear()
        let previous = evaluating.get()
        evaluating.set(Some(this))
        try { getter() } finally { evaluating.set(previous) }
        for (entry in dependencies) { entry.source.subscribe(this, entry.version) }
        ownerLock.lock()
        try {
            if (let Some(session) <- owner) {
                session.publishDependencyCount(this, dependencies.size)
            }
        } finally { ownerLock.unlock() }
    }
    func dispose(): Unit {
        ownerLock.lock()
        try {
            if (let Some(session) <- owner) {
                session.deactivateBinding(this)
                owner = None
            } else { active = false }
        } finally { ownerLock.unlock() }
        for (entry in dependencies) { entry.source.unsubscribe(this) }
        dependencies.clear()
    }
}

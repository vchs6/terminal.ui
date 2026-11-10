package cjtui

import std.collection.ArrayList
import std.sync.Mutex

let runtimeIdLock = Mutex()
var nextRuntimeId: Int64 = 1
func uniqueRuntimeId(): Int64 {
    runtimeIdLock.lock()
    try { let result = nextRuntimeId; nextRuntimeId++; result } finally { runtimeIdLock.unlock() }
}
let activeSession = ThreadLocal<RuntimeSession>()

class RuntimeSession {
    let root: Component
    let limits: RuntimeLimits
    let id: Int64
    let threadId: Int64
    let temporary: Bool
    let lock = Mutex()
    let nodes = ArrayList<RuntimeNode>()
    let bindings = ArrayList<Binding>()
    let posts = ArrayList<QueuedAction>()
    var active = true
    var acceptingPosts = false
    var changed = true
    var stopping = false
    var invalidationSequence: Int64 = 0
    var batchDepth: Int64 = 0
    var inLifecycle = false
    var inCallback = false
    var builds: Int64 = 0
    var measures: Int64 = 0
    var paints: Int64 = 0
    var frames: Int64 = 0
    var cached: ?Frame = None
    var cachedWidth: Int64 = -1
    var cachedHeight: Int64 = -1
    init(root: Component, limits: RuntimeLimits, temporary!: Bool = false) {
        this.root = root; this.limits = limits; this.temporary = temporary
        threadId = Thread.currentThread.id
        id = uniqueRuntimeId()
    }
    func requireContext(): Unit {
        if (evaluating.get().isSome()) { throw UIException("ReentrantEvaluation", "cannot enter UI during getter") }
        if (!active) { throw UIException("SessionInactive", "session is inactive") }
        if (Thread.currentThread.id != threadId) { throw UIException("WrongUIContext", "wrong UI thread") }
        if (let Some(other) <- activeSession.get()) {
            if (other.id != id) { throw UIException("WrongUIContext", "another session owns the active callback") }
        }
    }
    func requireBoundary(): Unit {
        requireContext()
        if (inLifecycle || inCallback || batchDepth > 0) {
            throw UIException("LifecycleReentry", "operation requires an outer UI boundary")
        }
    }
    func enter<T>(action: () -> T): T {
        requireContext()
        let previous = activeSession.get()
        activeSession.set(Some(this))
        try { action() } finally { activeSession.set(previous) }
    }
    func isValid(node: RuntimeNode): Bool {
        lock.lock()
        try { active && node.valid } finally { lock.unlock() }
    }
    func markChanged(): Unit { lock.lock(); try { changed = true } finally { lock.unlock() } }
    func recordBuild(): Unit { lock.lock(); try { builds++ } finally { lock.unlock() } }
    func recordMeasure(): Unit { lock.lock(); try { measures++ } finally { lock.unlock() } }
    func recordPaint(): Unit { lock.lock(); try { paints++ } finally { lock.unlock() } }
    func recordFrame(): Unit { lock.lock(); try { frames++ } finally { lock.unlock() } }
    func addNode(node: RuntimeNode): Unit { lock.lock(); try { nodes.add(node) } finally { lock.unlock() } }
    func inActiveDomain(): Bool {
        if (Thread.currentThread.id != threadId) { return false }
        match (activeSession.get()) { case Some(session) => session.id == id; case None => false }
    }
    func markDirtyLocked(binding: Binding, deferred: Bool): Unit {
        var sequence: Int64 = 0
        if (deferred) { invalidationSequence++; sequence = invalidationSequence }
        if (!binding.dirty || sequence < binding.dirtySequence) { binding.dirtySequence = sequence }
        binding.dirty = true
    }
    func cutoff(): Int64 {
        lock.lock()
        try { invalidationSequence } finally { lock.unlock() }
    }
    func invalidate(binding: Binding, deferred!: Bool = false): Unit {
        let later = deferred || !inActiveDomain()
        lock.lock()
        try { if (active && binding.active) { markDirtyLocked(binding, later) } } finally { lock.unlock() }
    }
    func publishDependencyCount(binding: Binding, count: Int64): Unit {
        lock.lock()
        try { binding.publishedDependencies = count } finally { lock.unlock() }
    }
    func deactivateBinding(binding: Binding): Unit {
        lock.lock()
        try { binding.active = false; binding.publishedDependencies = 0 } finally { lock.unlock() }
    }
    func addBinding(binding: Binding): Unit {
        requireContext()
        if (binding.component.bindings.size > limits.bindingsPerNode) { throw UIException("CapacityExceeded", "binding limit exceeded") }
        binding.ownerLock.lock()
        try {
            lock.lock()
            try { binding.owner = Some(this); binding.active = true; binding.dirty = true; binding.dirtySequence = 0 } finally { lock.unlock() }
        } finally { binding.ownerLock.unlock() }
        lock.lock()
        try { bindings.add(binding) } finally { lock.unlock() }
    }
    func removeBinding(binding: Binding): Unit {
        binding.dispose()
        lock.lock()
        try {
            var index: Int64 = 0
            while (index < bindings.size) {
                if (bindings[index].id == binding.id) { bindings.remove(at: index) } else { index++ }
            }
        } finally { lock.unlock() }
    }
    func notify(node: RuntimeNode, change: ChangeKind): Unit {
        let later = !inActiveDomain()
        lock.lock()
        try {
            if (!active || !node.valid) { throw UIException("StaleReference", "node is no longer mounted") }
            for (binding in node.component.bindings) {
                if (change == ChangeKind.All || change == ChangeKind.Bindings || binding.category == change) { markDirtyLocked(binding, later) }
            }
        } finally { lock.unlock() }
    }
    func mount(component: Component, parent: ?RuntimeNode, depth: Int64): RuntimeNode {
        if (depth > limits.treeDepth || nodes.size >= limits.mountedNodes) { throw UIException("CapacityExceeded", "node limit exceeded") }
        component.reserveMount()
        var node: ?RuntimeNode = None
        try {
            if (!component.built) {
                try {
                    collectChildren(component, { => component.build() })
                    component.built = true
                    recordBuild()
                } catch (error: Exception) { component.failed = true; throw error }
            }
            let created = RuntimeNode(component, this, nodes.size + 1, parent)
            addNode(created)
            component.publishMount(created, temporary)
            node = Some(created)
        } finally { component.releaseMount() }
        let mountedNode = node.getOrThrow()
        if (component.bindings.size > limits.bindingsPerNode) { throw UIException("CapacityExceeded", "binding limit exceeded") }
        for (binding in component.bindings) { addBinding(binding) }
        let keys = ArrayList<String>()
        for (child in component.children) {
            if (let Some(key) <- child.explicitKey) {
                for (previous in keys) { if (previous == key) { throw UIException("DuplicateKey", "duplicate sibling key") } }
                keys.add(key)
            }
            mountedNode.children.add(mount(child, Some(mountedNode), depth + 1))
        }
        mountedNode
    }
    func stabilize(cutoff: Int64): Unit {
        let dirty = ArrayList<Binding>()
        lock.lock()
        try {
            for (binding in bindings) {
                if (binding.active && binding.dirty && binding.dirtySequence <= cutoff) { binding.dirty = false; dirty.add(binding) }
            }
        } finally { lock.unlock() }
        for (binding in dirty) { if (binding.active) { binding.evaluate() } }
    }
    func start(): Unit {
        enter({ =>
            let turnCutoff = cutoff()
            mount(root, Option<RuntimeNode>.None, 0)
            stabilize(turnCutoff)
            if (!temporary) {
                lock.lock()
                try { acceptingPosts = true } finally { lock.unlock() }
                for (node in nodes) {
                    if (let Some(effect) <- node.component.mountEffect) {
                        inLifecycle = true
                        try { node.cleanup = Some(effect(node.reference())) } finally { inLifecycle = false }
                    }
                }
            }
        })
    }
    func post(owner: ?NodeRef, action: () -> Unit): Bool {
        if (evaluating.get().isSome()) { throw UIException("ReentrantEvaluation", "post during evaluation") }
        if (let Some(ref) <- owner) {
            if (!ref.belongsTo(this) || !ref.isValid()) { return false }
        }
        lock.lock()
        try {
            if (!active || !acceptingPosts || stopping || posts.size >= limits.pendingPosts) { return false }
            if (let Some(ref) <- owner) { if (!ref.isValid()) { return false } }
            posts.add(QueuedAction(owner, action)); true
        } finally { lock.unlock() }
    }
    func requestStop(): Unit { lock.lock(); try { stopping = true } finally { lock.unlock() } }
    func isStopping(): Bool { lock.lock(); try { stopping } finally { lock.unlock() } }
    func pump(): Unit {
        let turn = ArrayList<QueuedAction>()
        var turnCutoff: Int64 = 0
        lock.lock()
        try {
            turnCutoff = invalidationSequence
            for (post in posts) { turn.add(post) }
            posts.clear()
        } finally { lock.unlock() }
        for (item in turn) {
            var run = true
            if (let Some(owner) <- item.owner) { run = owner.isValid() }
            if (run) {
                inCallback = true; batchDepth++
                try { item.action() } finally { batchDepth--; inCallback = false }
            }
        }
        stabilize(turnCutoff)
    }
    func produce(width: Int64, height: Int64, force: Bool): Frame {
        if (force || changed || width != cachedWidth || height != cachedHeight || cached.isNone()) {
            let frame = renderLayout(root, width, height, this)
            recordFrame(); cached = Some(frame); cachedWidth = width; cachedHeight = height; changed = false
        }
        cached.getOrThrow().copy(Rect(0, 0, width, height))
    }
    func stats(): RuntimeStats {
        lock.lock()
        try {
            var activeBindings: Int64 = 0
            var subscriptions: Int64 = 0
            for (binding in bindings) { if (binding.active) { activeBindings++; subscriptions += binding.publishedDependencies } }
            RuntimeStats(if (active) { nodes.size } else { 0 }, activeBindings, subscriptions, posts.size,
                builds, measures, paints, frames)
        } finally { lock.unlock() }
    }
    func close(): Unit {
        if (!active) { return }
        lock.lock()
        try {
            active = false
            acceptingPosts = false
            posts.clear()
            for (node in nodes) { node.valid = false }
        } finally { lock.unlock() }
        for (node in nodes) { node.component.clearMount() }
        for (binding in bindings) { binding.dispose() }
        var failure: ?Exception = None
        var i = nodes.size
        while (i > 0) {
            i--
            if (let Some(cleanup) <- nodes[i].cleanup) {
                nodes[i].cleanup = None
                inLifecycle = true
                try { cleanup() } catch (error: Exception) {
                    match (failure) {
                        case None => failure = Some(error)
                        case Some(first) => failure = Some(aggregateCleanup(first, error))
                    }
                } finally { inLifecycle = false }
            }
        }
        for (node in nodes) { node.component.releaseMount() }
        if (let Some(error) <- failure) { throw error }
    }
}

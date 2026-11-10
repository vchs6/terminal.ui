package cjtui

import std.collection.ArrayList
import std.sync.Mutex
import std.ref.{WeakRef, CleanupPolicy}

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
    let threadNonce: Int64
    let temporary: Bool
    let application: ?WeakRef<Application>
    let lock = Mutex()
    let nodes = ArrayList<RuntimeNode>()
    let bindings = ArrayList<Binding>()
    let pendingBindings = ArrayList<Binding>()
    let pendingNodes = ArrayList<PendingNodeChange>()
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
    init(root: Component, limits: RuntimeLimits, temporary!: Bool = false,
        application!: ?Application = Option<Application>.None) {
        this.root = root; this.limits = limits; this.temporary = temporary
        this.application = match (application) {
            case Some(app) => Some(WeakRef<Application>(app, CleanupPolicy.EAGER))
            case None => None
        }
        threadId = Thread.currentThread.id
        threadNonce = uiThreadIdentity().nonce
        id = uniqueRuntimeId()
    }
    func requireOwner(): Unit {
        if (let Some(current) <- activeSession.get()) {
            if (current.id != id) { throw UIException("WrongUIContext", "another session owns the active callback") }
        }
        if (Thread.currentThread.id != threadId) { throw UIException("WrongUIContext", "wrong UI thread") }
        if (uiThreadIdentity().nonce != threadNonce) { throw UIException("WrongUIContext", "wrong UI thread") }
    }
    func requireContext(): Unit {
        requireOwner()
        if (evaluating.get().isSome()) { throw UIException("ReentrantEvaluation", "cannot enter UI during getter") }
        if (!active) {
            if (inLifecycle) { throw UIException("LifecycleReentry", "operation during cleanup") }
            throw UIException("SessionInactive", "session is inactive")
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
    func markNodeDirtyLocked(node: RuntimeNode, change: ChangeKind): Unit {
        if (change == ChangeKind.Content || change == ChangeKind.All) { node.contentDirty = true }
        if (change == ChangeKind.Style || change == ChangeKind.All) { node.styleDirty = true }
        if (change == ChangeKind.Content || change == ChangeKind.Layout || change == ChangeKind.Structure || change == ChangeKind.All) {
            node.layoutDirty = true
            var parent = node.parent
            while (let Some(ancestor) <- parent) { ancestor.layoutDirty = true; parent = ancestor.parent }
        }
    }
    func markChanged(node: RuntimeNode, change: ChangeKind): Unit {
        lock.lock()
        try { if (active && node.valid) { markNodeDirtyLocked(node, change); changed = true } } finally { lock.unlock() }
    }
    func recordBuild(): Unit { lock.lock(); try { builds++ } finally { lock.unlock() } }
    func recordMeasure(): Unit { lock.lock(); try { measures++ } finally { lock.unlock() } }
    func recordPaint(): Unit { lock.lock(); try { paints++ } finally { lock.unlock() } }
    func recordFrame(): Unit { lock.lock(); try { frames++ } finally { lock.unlock() } }
    func addNode(node: RuntimeNode): Unit { lock.lock(); try { nodes.add(node) } finally { lock.unlock() } }
    func inActiveDomain(): Bool {
        if (Thread.currentThread.id != threadId) { return false }
        if (uiThreadIdentity().nonce != threadNonce) { return false }
        match (activeSession.get()) { case Some(session) => session.id == id; case None => false }
    }
    func markDirtyLocked(binding: Binding, deferred: Bool): Unit {
        var sequence: Int64 = 0
        if (deferred) { invalidationSequence++; sequence = invalidationSequence }
        if (!binding.dirty) { binding.dirtySequence = sequence; binding.dirty = true; pendingBindings.add(binding) }
        else if (sequence < binding.dirtySequence) { binding.dirtySequence = sequence }
    }
    func cutoff(): Int64 {
        lock.lock()
        try { invalidationSequence } finally { lock.unlock() }
    }
    func invalidate(binding: Binding, deferred!: Bool = false): Unit {
        var later = deferred
        if (!later) { later = !inActiveDomain() }
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
            try {
                binding.owner = Some(this); binding.node = binding.component.readMount()
                binding.active = true; binding.dirty = true; binding.dirtySequence = 0
                pendingBindings.add(binding)
            } finally { lock.unlock() }
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
            index = 0
            while (index < pendingBindings.size) {
                if (pendingBindings[index].id == binding.id) { pendingBindings.remove(at: index) } else { index++ }
            }
        } finally { lock.unlock() }
    }
    func notify(node: RuntimeNode, change: ChangeKind): Unit {
        let later = !inActiveDomain()
        lock.lock()
        try {
            if (!active || !node.valid) { throw UIException("StaleReference", "node is no longer mounted") }
            if (change != ChangeKind.Bindings) {
                var sequence: Int64 = 0
                if (later) { invalidationSequence++; sequence = invalidationSequence }
                match (node.pendingChange) {
                    case Some(pending) =>
                        if (sequence < pending.sequence) { pending.sequence = sequence }
                        pending.include(change)
                    case None =>
                        let pending = PendingNodeChange(node, sequence)
                        pending.include(change); node.pendingChange = Some(pending); pendingNodes.add(pending)
                }
            }
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
        let ready = ArrayList<Binding>()
        let laterBindings = ArrayList<Binding>()
        let laterNodes = ArrayList<PendingNodeChange>()
        lock.lock()
        try {
            for (pending in pendingNodes) {
                if (pending.sequence <= cutoff) {
                    pending.node.pendingChange = None
                    if (pending.node.valid) {
                        if (pending.content) { markNodeDirtyLocked(pending.node, ChangeKind.Content) }
                        if (pending.style) { markNodeDirtyLocked(pending.node, ChangeKind.Style) }
                        if (pending.layout) { markNodeDirtyLocked(pending.node, ChangeKind.Layout) }
                        changed = true
                    }
                } else { laterNodes.add(pending) }
            }
            pendingNodes.clear()
            for (pending in laterNodes) { pendingNodes.add(pending) }
            for (binding in pendingBindings) {
                if (binding.active && binding.dirty && binding.dirtySequence <= cutoff) {
                    binding.dirty = false
                    if (let Some(node) <- binding.node) { markNodeDirtyLocked(node, binding.category) }
                    ready.add(binding)
                } else if (binding.active && binding.dirty) { laterBindings.add(binding) }
            }
            pendingBindings.clear()
            for (binding in laterBindings) { pendingBindings.add(binding) }
        } finally { lock.unlock() }
        for (binding in ready) { if (binding.active) { binding.evaluate() } }
    }
    func needsWork(): Bool {
        lock.lock()
        try { changed || !posts.isEmpty() || !pendingBindings.isEmpty() || !pendingNodes.isEmpty() || stopping }
        finally { lock.unlock() }
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
        lock.lock()
        var dirtyFrame = false
        try { dirtyFrame = changed } finally { lock.unlock() }
        if (force || dirtyFrame || width != cachedWidth || height != cachedHeight || cached.isNone()) {
            lock.lock()
            try {
                for (node in nodes) { node.contentDirty = false; node.styleDirty = false; node.layoutDirty = false }
            } finally { lock.unlock() }
            let frame = renderLayout(root, width, height, this)
            recordFrame(); cached = Some(frame); cachedWidth = width; cachedHeight = height
            lock.lock()
            try { changed = false } finally { lock.unlock() }
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
    func notifyClosed(): Unit {
        if (let Some(weak) <- application) {
            if (let Some(app) <- weak.value) { app.sessionClosed(this) }
        }
    }
    func closeFailure(primary: Exception): Exception {
        var result = primary
        try { close() } catch (cleanup: Exception) { result = aggregateCleanup(result, cleanup) }
        notifyClosed()
        result
    }
    func closeStopped(): Unit {
        try { close() } finally { notifyClosed() }
    }
    func close(): Unit {
        if (!active) { return }
        lock.lock()
        try {
            active = false
            acceptingPosts = false
            posts.clear(); pendingBindings.clear(); pendingNodes.clear()
            for (node in nodes) { node.valid = false; node.pendingChange = None }
        } finally { lock.unlock() }
        for (node in nodes) { node.component.clearMount() }
        for (binding in bindings) { binding.dispose() }
        var failure: ?Exception = None
        let previousSession = activeSession.get()
        activeSession.set(Some(this))
        try {
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
        } finally { activeSession.set(previousSession) }
        for (node in nodes) { node.component.releaseMount() }
        if (let Some(error) <- failure) { throw error }
    }
}

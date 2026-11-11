package cjtui

import std.collection.{ArrayList, HashSet}
import std.sync.Mutex
import std.ref.{WeakRef, CleanupPolicy}

let runtimeIdLock = Mutex()
var nextRuntimeId: Int64 = 1

func uniqueRuntimeId(): Int64 {
    runtimeIdLock.lock()
    try {
        let result = nextRuntimeId;
        nextRuntimeId++;
        result
    } finally {
        runtimeIdLock.unlock()
    }
}

let activeSession = ThreadLocal<RuntimeSession>()

class RuntimeSession {
    let focusManager: FocusManager
    let root: Component
    let limits: RuntimeLimits
    var theme: Theme
    let id: Int64
    let threadId: Int64
    let threadNonce: Int64
    let temporary: Bool
    let extensions: SessionExtensionState
    private var firstDeviceFailure: ?Exception = None
    let application: ?WeakRef<Application>
    let lock = Mutex()
    let nodes = ArrayList<RuntimeNode>()
    let bindings = ArrayList<Binding>()
    let pendingBindings = ArrayList<Binding>()
    let pendingNodes = ArrayList<PendingNodeChange>()
    let posts = ArrayList<QueuedAction>()
    let commands = ArrayList<StructuralCommand>()
    let viewportCommands = ArrayList<ScrollCommand>()
    let pendingEnsures = ArrayList<ScrollCommand>()
    var pendingFocusEnsure: ?ScrollCommand = None
    var viewportIntentSequence: Int64 = 0
    var structuralOps: Int64 = 0
    var committing = false
    var mountingCredit: Int64 = 0
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
    var trackCaret = false
    var pendingCaret: ?CaretRequest = None
    var lastCaret: ?CaretRequest = None
    var caret = CaretSnapshot(Option<NodeRef>.None,0,0,false)
    var cached: ?Frame = None
    var measuredLayout: ?LayoutNode = None
    var layoutGlyphPolicy = GlyphRenderPolicy.unicode()
    var cachedGlyphMarker = ""
    var measuredGlyphMarker = ""
    var validationWidth: Int64 = -1
    var validationHeight: Int64 = -1
    var cachedWidth: Int64 = -1
    var cachedHeight: Int64 = -1
    init(root: Component, limits: RuntimeLimits, temporary!: Bool = false,
        application!: ?Application = Option<Application>.None, sessionOptions!: SessionOptions = SessionOptions(),
        device!: Bool = false, theme!: Theme = Theme.preset(ThemePreset.Classic)) {
        this.root = root
        this.focusManager = FocusManager()
        this.theme = theme
        this.limits = limits
        this.temporary = temporary
        this.application = match (application) {
            case Some(app) => Some(WeakRef<Application>(app, CleanupPolicy.EAGER))
            case None => None
        }
        threadId = Thread.currentThread.id
        threadNonce = uiThreadIdentity().nonce
        id = uniqueRuntimeId()
        extensions = SessionExtensionState(id, sessionOptions, device)
        focusManager.session = Some(this)
    }
    func requireOwner(): Unit {
        if (let Some(current) <- activeSession.get()) {
            if (current.id != id) {
                throw UIException("WrongUIContext", "another session owns the active callback")
            }
        }
        if (Thread.currentThread.id != threadId) {
            throw UIException("WrongUIContext", "wrong UI thread")
        }
        if (uiThreadIdentity().nonce != threadNonce) {
            throw UIException("WrongUIContext", "wrong UI thread")
        }
    }
    func requireReadContext(): Unit {
        requireOwner()
        if (!active) { throw UIException("SessionInactive", "session is inactive") }
    }
    func requireContext(): Unit {
        requireOwner()
        if (structureEvaluation.get().isSome()) {
            throw UIException("ReentrantStructure", "cannot enter UI during structure evaluation")
        }
        if (evaluating.get().isSome()) {
            throw UIException("ReentrantEvaluation", "cannot enter UI during getter")
        }
        if (!active) {
            if (inLifecycle) {
                throw UIException("LifecycleReentry", "operation during cleanup")
            }
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
        try {
            action()
        } finally {
            activeSession.set(previous)
        }
    }
    func isValid(node: RuntimeNode): Bool {
        lock.lock()
        try {
            active && node.valid && node.committed
        } finally {
            lock.unlock()
        }
    }
    func markNodeDirtyLocked(node: RuntimeNode, change: ChangeKind): Unit {
        if (change == ChangeKind.Content || change == ChangeKind.All) {
            node.contentDirty = true
        }
        if (change == ChangeKind.Style || change == ChangeKind.All) {
            node.styleDirty = true
        }
        if (change == ChangeKind.Content || change == ChangeKind.Layout || change == ChangeKind.Structure || change == ChangeKind
            .All) {
            measuredLayout = None
            node.layoutDirty = true
            var parent = node.parent
            while (let Some(ancestor) <- parent) {
                ancestor.layoutDirty = true
                parent = ancestor.parent
            }
        }
    }
    func invalidateBehaviorStyle(): Unit {
        let rootNode = root.readMount()
        if (rootNode.isNone()) { return }
        var change = ChangeKind.Style
        if (let Some(layout) <- measuredLayout) {
            if (layout.behaviorChangesLayout(themeSeed(theme),true)) { change = ChangeKind.Layout }
        }
        markChanged(rootNode.getOrThrow(),change)
    }
    func markChanged(node: RuntimeNode, change: ChangeKind): Unit {
        lock.lock()
        try {
            if (active && node.valid) {
                markNodeDirtyLocked(node, change);
                changed = true
            }
        } finally {
            lock.unlock()
        }
    }
    func recordBuild(): Unit {
        lock.lock();
        try {
            builds++
        } finally {
            lock.unlock()
        }
    }
    func recordMeasure(): Unit {
        lock.lock();
        try {
            measures++
        } finally {
            lock.unlock()
        }
    }
    func recordPaint(): Unit {
        lock.lock();
        try {
            paints++
        } finally {
            lock.unlock()
        }
    }
    func recordFrame(): Unit {
        lock.lock();
        try {
            frames++
        } finally {
            lock.unlock()
        }
    }
    func addNode(node: RuntimeNode): Unit {
        lock.lock();
        try {
            nodes.add(node)
        } finally {
            lock.unlock()
        }
    }
    func inActiveDomain(): Bool {
        if (Thread.currentThread.id != threadId) {
            return false
        }
        if (uiThreadIdentity().nonce != threadNonce) {
            return false
        }
        match (activeSession.get()) {
            case Some(session) => session.id == id;
            case None => false
        }
    }
    func markDirtyLocked(binding: Binding, deferred: Bool): Unit {
        var sequence: Int64 = 0
        if (deferred) {
            invalidationSequence++;
            sequence = invalidationSequence
        }
        if (!binding.dirty) {
            binding.dirtySequence = sequence
            binding.dirty = true
            pendingBindings.add(binding)
        } else if (sequence < binding.dirtySequence) {
            binding.dirtySequence = sequence
        }
    }
    func cutoff(): Int64 {
        lock.lock()
        try {
            invalidationSequence
        } finally {
            lock.unlock()
        }
    }
    func invalidate(binding: Binding, deferred!: Bool = false): Unit {
        var later = deferred
        if (!later) {
            later = !inActiveDomain()
        }
        lock.lock()
        try {
            if (active && binding.active) {
                markDirtyLocked(binding, later)
            }
        } finally {
            lock.unlock()
        }
    }
    func publishDependencyCount(binding: Binding, count: Int64): Unit {
        lock.lock()
        try {
            binding.publishedDependencies = count
        } finally {
            lock.unlock()
        }
    }
    func deactivateBinding(binding: Binding): Unit {
        lock.lock()
        try {
            if (binding.active) {
                if (let Some(node) <- binding.node) {
                    node.bindingCount--
                }
            }
            binding.active = false
            binding.publishedDependencies = 0
        } finally {
            lock.unlock()
        }
    }
    func addBinding(binding: Binding, initiallyDirty!: Bool = true): Unit {
        requireContext()
        let ownerNode = binding.component.readMount().getOrThrow()
        if (ownerNode.bindingCount >= limits.bindingsPerNode) {
            throw UIException("CapacityExceeded", "binding limit exceeded")
        }
        ownerNode.bindingCount++
        binding.ownerLock.lock()
        try {
            lock.lock()
            try {
                binding.owner = Some(this)
                binding.node = binding.component.readMount()
                binding.active = true
                binding.dirty = initiallyDirty
                binding.dirtySequence = 0
                if (initiallyDirty) {
                    pendingBindings.add(binding)
                }
            } finally {
                lock.unlock()
            }
        } finally {
            binding.ownerLock.unlock()
        }
        lock.lock()
        try {
            bindings.add(binding)
        } finally {
            lock.unlock()
        }
    }
    func removeBinding(binding: Binding): Unit {
        binding.dispose()
        lock.lock()
        try {
            var index: Int64 = 0
            while (index < bindings.size) {
                if (bindings[index].id == binding.id) {
                    bindings.remove(at: index)
                } else {
                    index++
                }
            }
            index = 0
            while (index < pendingBindings.size) {
                if (pendingBindings[index].id == binding.id) {
                    pendingBindings.remove(at: index)
                } else {
                    index++
                }
            }
        } finally {
            lock.unlock()
        }
    }
    func notify(node: RuntimeNode, change: ChangeKind): Unit {
        let later = !inActiveDomain()
        lock.lock()
        try {
            if (!active || !node.valid) {
                throw UIException("StaleReference", "node is no longer mounted")
            }
            if (change != ChangeKind.Bindings) {
                var sequence: Int64 = 0
                if (later) {
                    invalidationSequence++;
                    sequence = invalidationSequence
                }
                match (node.pendingChange) {
                    case Some(pending) =>
                        if (sequence < pending.sequence) {
                            pending.sequence = sequence
                        }
                        pending.include(change)
                    case None =>
                        let pending = PendingNodeChange(node, sequence)
                        pending.include(change);
                        node.pendingChange = Some(pending)
                        pendingNodes.add(pending)
                }
            }
            for (binding in bindings) {
                if (binding.component.descriptionId != node.component.descriptionId) {
                    continue
                }
                if (change == ChangeKind.All || change == ChangeKind.Bindings || binding.category == change) {
                    markDirtyLocked(binding, later)
                }
            }
        } finally {
            lock.unlock()
        }
    }
    // Build static declarations before staging. mount also initializes every nested dynamic
    // group before the outer insertion can publish this subtree or retire old nodes.
    func preflight(components: Array<Component>, parent: ?RuntimeNode, retiring!: Array<RuntimeNode> = []): Unit {
        let seen = HashSet<Int64>()
        let depth = match (parent) {
            case Some(node) => node.depth + 1;
            case None => 0
        }
        inStructure({
            => for (component in components) {
                prepareTree(component, depth, seen)
            }
        })
        if (nodes.size - mountingCredit + seen.size - subtreeCount(retiring) > limits.mountedNodes) {
            throw UIException("CapacityExceeded", "node limit exceeded")
        }
    }
    func subtreeCount(roots: Array<RuntimeNode>): Int64 {
        let descendants = ArrayList<RuntimeNode>()
        for (root in roots) {
            collectSubtree(root, descendants)
        }
        descendants.size
    }
    // Staged additions are not in the parent's sequence yet. Retiring nodes provide
    // capacity until the atomic sequence replacement, before any lifecycle callbacks.
    func replacing<T>(retiring: Array<RuntimeNode>, action: () -> T): T {
        let previous = mountingCredit
        mountingCredit += subtreeCount(retiring)
        try {
            action()
        } finally {
            mountingCredit = previous
        }
    }
    func prepareTree(component: Component, depth: Int64, seen: HashSet<Int64>): Unit {
        if (depth > limits.treeDepth) {
            throw UIException("CapacityExceeded", "tree depth exceeded")
        }
        if (component.readMount().isSome() || component.mounting) {
            throw UIException("AlreadyMounted", "component already mounted or reserved")
        }
        if (component.failed) {
            throw UIException("ConstructionFailed", "component construction failed")
        }
        if (!seen.add(component.descriptionId)) {
            throw UIException("AlreadyMounted", "duplicate component or construction cycle")
        }
        if (!component.built) {
            try {
                collectChildren(component, {=> component.build()})
                component.built = true
                recordBuild()
            } catch (error: Exception) {
                component.failed = true
                throw error
            }
        }
        let keys = HashSet<String>()
        for (entry in component.declarations) {
            if (let ChildDeclaration.DeclaredComponent(child) <- entry) {
                if (let Some(key) <- child.explicitKey) {
                    if (!keys.add(key)) {
                        throw UIException("DuplicateKey", "duplicate sibling key")
                    }
                }
                prepareTree(child, depth + 1, seen)
            }
        }
    }
    func mount(component: Component, parent: ?RuntimeNode, depth: Int64): RuntimeNode {
        if (depth > limits.treeDepth || nodes.size - mountingCredit >= limits.mountedNodes) {
            throw UIException("CapacityExceeded", "node limit exceeded")
        }
        component.reserveMount()
        let created = RuntimeNode(component, this, uniqueRuntimeId(), parent)
        try {
            addNode(created)
            component.publishMount(created, temporary)
        } finally {
            component.releaseMount()
        }
        for (binding in component.bindings) {
            addBinding(binding)
        }
        for (entry in component.declarations) {
            match (entry) {
                case ChildDeclaration.DeclaredComponent(child) => created
                    .sequence
                    .add(ChildEntry.MountedChild(mount(child, Some(created), depth + 1)))
                case ChildDeclaration.DeclaredGroup(declaration) =>
                    let group = declaration.create(created)
                    created.sequence.add(ChildEntry.GroupMarker(group))
                    initializeGroup(component, group)
            }
        }
        created
    }
    // The new node's sequence is still private to its enclosing staged subtree.
    // Evaluate initial structure with its own dependency tracker, then commit only
    // after restoring evaluation guards. Descendant mounts recurse through here.
    func initializeGroup(component: Component, group: DynamicGroup): Unit {
        let binding = Binding(component, "group${group.id}", ChangeKind.Structure, {=> group.prepare()})
        addBinding(binding, initiallyDirty: false)
        binding.evaluate()
        group.commit()
    }
    func requireStructure(): Unit {
        requireOwner()
        if (inLifecycle) {
            throw UIException("LifecycleReentry", "structure operation during lifecycle")
        }
        if (structureEvaluation.get().isSome() || evaluating.get().isSome() || committing) {
            throw UIException("ReentrantStructure", "structure operation during evaluation or commit")
        }
        if (!active) {
            throw UIException("StaleReference", "node session is inactive")
        }
    }
    func enqueue(command: StructuralCommand): Unit {
        requireStructure()
        if (batchDepth == 0) {
            try {
                enter(
                    {
                        =>
                            recordCommand(command);
                            stabilize(cutoff())
                    }
                )
            } catch (error: Exception) {
                throw closeFailure(error)
            }
        } else {
            recordCommand(command)
        }
    }
    func recordCommand(command: StructuralCommand): Unit {
        let parent = command.parent.resolve()
        if (parent.component.kind == 0 || parent.component.kind == 3) {
            throw UIException("InvalidParent", "leaf cannot own children")
        }
        if (let Some(component) <- command.description) {
            if (component.readMount().isSome() || component.mounting) {
                throw UIException("AlreadyMounted", "component already mounted")
            }
            for (pending in commands) {
                if (let Some(reserved) <- pending.description) {
                    if (reserved.descriptionId == component.descriptionId) {
                        throw UIException("AlreadyMounted", "description already reserved")
                    }
                }
            }
        }
        if (commands.size + focusManager.requested.size + viewportCommands.size >= limits.structuralOpsPerBatch) {
            throw UIException("CapacityExceeded", "command limit exceeded")
        }
        commands.add(command)
    }
    func nextViewportIntent(): Int64 {
        if (viewportIntentSequence == Int64.Max) { throw UIException("CapacityExceeded", "viewport intent sequence exhausted") }
        viewportIntentSequence++; viewportIntentSequence
    }
    func enqueueFocus(ref: NodeRef): Unit {
        if (commands.size + focusManager.requested.size + viewportCommands.size >= limits.structuralOpsPerBatch) {
            throw UIException("CapacityExceeded", "command limit exceeded")
        }
        let order = nextViewportIntent()
        focusManager.requested.add(ref); focusManager.requestedOrders.add(order)
    }
    func syncViewportAxes(): Unit {
        for (node in nodes) {
            if (!node.valid || !node.committed) { continue }
            if (let Some(axes) <- viewportAxes(node)) {
                let state = node.viewportState
                if (state.axes != axes) {
                    state.update(state.width,state.height,state.contentWidth,state.contentHeight,axes)
                }
            }
        }
    }
    func viewportAxes(node: RuntimeNode): ?ScrollAxes {
        if (node.component.viewportDeclared) { return Some(node.component.viewportAxes) }
        if (node.parent.isNone() && !temporary) { return Some(ScrollAxes.Vertical) }
        None
    }
    func enqueueViewport(command: ScrollCommand): Unit {
        requireContext()
        if (inLifecycle) { throw UIException("LifecycleReentry", "viewport command during lifecycle") }
        if (commands.size + focusManager.requested.size + viewportCommands.size >= limits.structuralOpsPerBatch) {
            throw UIException("CapacityExceeded", "command limit exceeded")
        }
        command.order = nextViewportIntent()
        if (command.kind == 1) {
            let target = command.target.resolve()
            var current: ?RuntimeNode = if (command.rect.isSome()) { Some(target) } else { target.parent }
            while (let Some(node) <- current) {
                if (viewportAxes(node).isSome()) {
                    let snap = node.viewportState.snapshot()
                    if (snap.width == 0) { command.zeroWidth.add(node.id) }
                    if (snap.height == 0) { command.zeroHeight.add(node.id) }
                }
                current = node.parent
            }
        }
        viewportCommands.add(command)
        if (command.kind == 0) {
            let state = command.target.resolve().viewportState
            state.queuedX = Some(command.x); state.queuedY = Some(command.y)
        }
        if (batchDepth == 0 && !inCallback) {
            enter({=> stabilize(cutoff()) })
        }
    }
    func queueFocusEnsure(ref: NodeRef, order: Int64): Unit {
        let command = ScrollCommand(ref,1,0,0,Option<Rect>.None,ScrollAlign.Nearest,ScrollAlign.Nearest)
        command.order = if (order == 0) { nextViewportIntent() } else { order }
        pendingFocusEnsure = Some(command)
    }
    func viewportContains(ancestor: RuntimeNode, target: NodeRef): Bool {
        if (!target.isValid()) { return false }
        var current: ?RuntimeNode = Some(target.resolve())
        while (let Some(node) <- current) {
            if (node.id == ancestor.id) { return true }
            current = node.parent
        }
        false
    }
    func commitViewportCommands(): Unit {
        let ready = viewportCommands.toArray(); viewportCommands.clear()
        for (command in ready) {
            useStructuralOps(1)
            if (!command.target.isValid()) { continue }
            let node = command.target.resolve()
            if (command.kind == 0) {
                var pendingIndex: Int64 = 0
                while (pendingIndex < pendingEnsures.size) {
                    let earlier = pendingEnsures[pendingIndex]
                    if (earlier.order < command.order) {
                        if (viewportContains(node,earlier.target)) {
                            pendingEnsures.remove(at:pendingIndex)
                        } else { pendingIndex++ }
                    } else { pendingIndex++ }
                }
                if (let Some(focus) <- pendingFocusEnsure) {
                    if (focus.order < command.order) {
                        if (viewportContains(node,focus.target)) { pendingFocusEnsure = None }
                    }
                }
                let state = node.viewportState
                state.queuedX = None; state.queuedY = None
                if (state.setOffset(command.x,command.y)) { markChanged(node,ChangeKind.Style) }
            } else {
                // A later ensure for the same generation supersedes the earlier one.
                var i: Int64 = 0
                while (i < pendingEnsures.size) {
                    if (pendingEnsures[i].target.sameNode(command.target)) { pendingEnsures.remove(at:i) } else { i++ }
                }
                if (pendingEnsures.size >= limits.structuralOpsPerBatch) { throw UIException("CapacityExceeded", "ensure limit exceeded") }
                pendingEnsures.add(command); markChanged(node,ChangeKind.Style)
            }
        }
    }
    func useStructuralOps(count: Int64): Unit {
        if (count > limits.structuralOpsPerBatch - structuralOps) {
            throw UIException("CapacityExceeded", "structural operation limit exceeded")
        }
        structuralOps += count
    }
    func groupCost(old: Array<RuntimeNode>, keys: Array<String>): Int64 {
        var cost: Int64 = 0
        for (i in 0..old.size) {
            if (i >= keys.size || old[i].groupKey != keys[i]) {
                cost++
            }
        }
        if (keys.size > old.size) {
            cost += keys.size - old.size
        }
        cost
    }
    func indexOf(parent: RuntimeNode, child: RuntimeNode): Int64 {
        for (i in 0..parent.sequence.size) {
            if (let ChildEntry.MountedChild(node) <- parent.sequence[i]) {
                if (node.id == child.id) {
                    return i
                }
            }
        }
        -1
    }
    func commandAnchor(parent: RuntimeNode, anchor: ?NodeRef): Int64 {
        if (let Some(reference) <- anchor) {
            if (!reference.isValid() || !reference.belongsTo(this)) {
                throw UIException("StaleAnchor", "anchor is no longer a direct child")
            }
            let index = indexOf(parent, reference.resolve())
            if (index < 0) {
                throw UIException("StaleAnchor", "anchor is not a direct child")
            }
            return index
        }
        parent.sequence.size
    }
    func commitCommand(command: StructuralCommand): Unit {
        let parent = command.parent.resolve()
        if (parent.session.id != id) {
            throw UIException("WrongUIContext", "parent belongs to another session")
        }
        if (parent.component.kind == 0 || parent.component.kind == 3) {
            throw UIException("InvalidParent", "leaf cannot own children")
        }
        if (command.kind == 0) {
            let index = commandAnchor(parent, command.anchor)
            let component = command.description.getOrThrow()
            preflight([component], Some(parent))
            useStructuralOps(1)
            let node = mount(component, Some(parent), parent.depth + 1)
            parent.sequence.add(ChildEntry.MountedChild(node), at: index)
            publish([node], [])
        } else {
            let child = command.child.getOrThrow().resolve()
            let index = indexOf(parent, child)
            if (index < 0) {
                throw UIException(if (command.kind == 1) {
                    "CrossParentMove"
                } else {
                    "InvalidParent"
                }, "node is not a direct child of parent")
            }
            if (command.kind == 1) {
                let anchor = commandAnchor(parent, command.anchor)
                if (index == anchor || index + 1 == anchor) {
                    return
                }
                useStructuralOps(1)
                let entry = parent.sequence.remove(at: index)
                parent.sequence.add(entry, at: if (index < anchor) {
                    anchor - 1
                } else {
                    anchor
                })
            } else {
                useStructuralOps(1)
                parent.sequence.remove(at: index)
                for (entry in parent.sequence) {
                    if (let ChildEntry.GroupMarker(group) <- entry) {
                        if (group.id == child.groupId) {
                            group.forget(child.groupKey)
                        }
                    }
                }
                unmount([child])
            }
        }
        markChanged(parent, ChangeKind.Structure)
    }
    // Publish generation validity at the sequence commit point. Background stats and
    // isValid never expose staged additions or count retiring and replacement nodes twice.
    func publish(added: Array<RuntimeNode>, retiring: Array<RuntimeNode>): Unit {
        let newNodes = ArrayList<RuntimeNode>()
        let oldNodes = ArrayList<RuntimeNode>()
        for (node in added) {
            collectSubtree(node, newNodes)
        }
        for (node in retiring) {
            collectSubtree(node, oldNodes)
        }
        lock.lock()
        try {
            for (node in oldNodes) {
                node.valid = false
                node.pendingChange = None
            }
            for (node in newNodes) {
                node.committed = true
            }
        } finally {
            lock.unlock()
        }
    }
    func collectSubtree(node: RuntimeNode, result: ArrayList<RuntimeNode>): Unit {
        result.add(node)
        for (entry in node.sequence) {
            if (let ChildEntry.MountedChild(child) <- entry) {
                collectSubtree(child, result)
            }
        }
    }
    func unmount(roots: Array<RuntimeNode>): Unit {
        let removed = ArrayList<RuntimeNode>()
        for (node in roots) {
            collectSubtree(node, removed)
        }
        lock.lock()
        try {
            for (node in removed) {
                node.valid = false
                node.pendingChange = None
            }
        } finally {
            lock.unlock()
        }
        focusManager.cancelInvalidRequests()
        var pendingIndex: Int64 = 0
        while (pendingIndex < viewportCommands.size) {
            if (!viewportCommands[pendingIndex].target.isValid()) { viewportCommands.remove(at:pendingIndex) } else { pendingIndex++ }
        }
        pendingIndex = 0
        while (pendingIndex < pendingEnsures.size) {
            if (!pendingEnsures[pendingIndex].target.isValid()) { pendingEnsures.remove(at:pendingIndex) } else { pendingIndex++ }
        }
        if (let Some(focus) <- pendingFocusEnsure) { if (!focus.target.isValid()) { pendingFocusEnsure = None } }
        for (node in removed) {
            node.component.clearMount()
        }
        let removedBindings = ArrayList<Binding>()
        for (binding in bindings) {
            if (let Some(owner) <- binding.node) {
                if (!owner.valid) {
                    removedBindings.add(binding)
                }
            }
        }
        for (binding in removedBindings) {
            removeBinding(binding)
        }
        lock.lock()
        try {
            var i: Int64 = 0
            while (i < nodes.size) {
                if (!nodes[i].valid) {
                    nodes.remove(at: i)
                } else {
                    i++
                }
            }
            i = 0
            while (i < posts.size) {
                var cancelled = false
                if (let Some(owner) <- posts[i].owner) {
                    cancelled = !owner.isValid()
                }
                if (cancelled) {
                    posts.remove(at: i)
                } else {
                    i++
                }
            }
            i = 0
            while (i < pendingNodes.size) {
                if (!pendingNodes[i].node.valid) {
                    pendingNodes.remove(at: i)
                } else {
                    i++
                }
            }
        } finally {
            lock.unlock()
        }
        var failure: ?Exception = None
        var i = removed.size
        while (i > 0) {
            i--
            let node = removed[i]
            if (let Some(cleanup) <- node.cleanup) {
                node.cleanup = None
                inLifecycle = true
                try {
                    cleanup()
                } catch (error: Exception) {
                    match (failure) {
                        case None => failure = Some(error)
                        case Some(first) => failure = Some(aggregateCleanup(first, error))
                    }
                } finally {
                    inLifecycle = false
                }
            }
        }
        for (node in removed) {
            node.component.releaseMount();
            node.sequence.clear()
        }
        if (let Some(error) <- failure) {
            throw error
        }
    }
    func hasReady(cutoff: Int64): Bool {
        lock.lock()
        try {
            for (binding in pendingBindings) {
                if (binding.active && binding.dirty && binding.dirtySequence <= cutoff) {
                    return true
                }
            }
            for (pending in pendingNodes) {
                if (pending.sequence <= cutoff) {
                    return true
                }
            }
            false
        } finally {
            lock.unlock()
        }
    }
    func stabilize(cutoff: Int64, resetStructuralOps!: Bool = true): Unit {
        throwDeviceFailure()
        if (resetStructuralOps) {
            structuralOps = 0
        }
        var passes: Int64 = 0
        while (true) {
            if (passes >= limits.stabilizationPasses) {
                throw UIException("UnstableUpdate", "synchronous update failed to stabilize")
            }
            passes++
            committing = true
            try {
                let readyCommands = commands.toArray()
                commands.clear()
                for (command in readyCommands) {
                    commitCommand(command)
                }
            } finally {
                committing = false
            }
            evaluateReady(cutoff)
            // Plans are prepared under dependency tracking, committed after evaluation has
            // restored its guards. Lifecycle writes can therefore schedule the next pass.
            let groups = ArrayList<DynamicGroup>()
            for (node in nodes) {
                for (entry in node.sequence) {
                    if (let ChildEntry.GroupMarker(group) <- entry) {
                        if (group.plan.isSome()) {
                            groups.add(group)
                        }
                    }
                }
            }
            committing = true
            try {
                for (group in groups) {
                    if (group.parent.valid) {
                        group.commit()
                    }
                }
            } finally {
                committing = false
            }
            if (hasReady(cutoff)) {
                continue
            }
            if (!temporary) {
                let pendingEffects = ArrayList<RuntimeNode>()
                for (node in nodes) {
                    if (!node.effectStarted) {
                        pendingEffects.add(node)
                    }
                }
                for (node in pendingEffects) {
                    if (!node.valid) {
                        continue
                    }
                    node.effectStarted = true
                    if (let Some(effect) <- node.component.mountEffect) {
                        inLifecycle = true
                        try {
                            node.cleanup = Some(effect(node.reference()))
                        } finally {
                            inLifecycle = false
                        }
                    }
                }
            }
            if (!hasReady(cutoff) && commands.isEmpty()) {
                syncViewportAxes()
                if (!temporary) { focusManager.repair() }
                commitViewportCommands()
                if (hasReady(cutoff)) { continue }
                return
            }
        }
    }
    func evaluateReady(cutoff: Int64): Unit {
        let ready = ArrayList<Binding>()
        let laterBindings = ArrayList<Binding>()
        let laterNodes = ArrayList<PendingNodeChange>()
        lock.lock()
        try {
            for (pending in pendingNodes) {
                if (pending.sequence <= cutoff) {
                    pending.node.pendingChange = None
                    if (pending.node.valid) {
                        if (pending.content) {
                            markNodeDirtyLocked(pending.node, ChangeKind.Content)
                        }
                        if (pending.style) {
                            markNodeDirtyLocked(pending.node, ChangeKind.Style)
                        }
                        if (pending.layout) {
                            markNodeDirtyLocked(pending.node, ChangeKind.Layout)
                        }
                        changed = true
                    }
                } else {
                    laterNodes.add(pending)
                }
            }
            pendingNodes.clear()
            for (pending in laterNodes) {
                pendingNodes.add(pending)
            }
            for (binding in pendingBindings) {
                if (binding.active && binding.dirty && binding.dirtySequence <= cutoff) {
                    binding.dirty = false
                    // The property setter owns actual invalidation after evaluating.
                    // Explicit NodeRef notifications are handled above.
                    ready.add(binding)
                } else if (binding.active && binding.dirty) {
                    laterBindings.add(binding)
                }
            }
            pendingBindings.clear()
            for (binding in laterBindings) {
                pendingBindings.add(binding)
            }
        } finally {
            lock.unlock()
        }
        for (binding in ready) {
            if (binding.active) {
                binding.evaluate()
            }
        }
    }
    func needsWork(): Bool {
        lock.lock()
        try {
            changed || !posts.isEmpty() || !pendingBindings.isEmpty() || !pendingNodes.isEmpty() || stopping
        } finally {
            lock.unlock()
        }
    }
    func start(): Unit {
        enter(
            {
                =>
                    let turnCutoff = cutoff()
                    structuralOps = 0
                    preflight([root], Option<RuntimeNode>.None)
                    let mounted = mount(root, Option<RuntimeNode>.None, 0)
                    publish([mounted], [])
                    if (!temporary) {
                        lock.lock()
                        try {
                            acceptingPosts = true
                        } finally {
                            lock.unlock()
                        }
                    }
                    stabilize(turnCutoff, resetStructuralOps: false)
            }
        )
    }
    func post(owner: ?NodeRef, action: () -> Unit): Bool {
        if (evaluating.get().isSome()) {
            throw UIException("ReentrantEvaluation", "post during evaluation")
        }
        if (let Some(ref) <- owner) {
            if (!ref.belongsTo(this) || !ref.isValid()) {
                return false
            }
        }
        lock.lock()
        try {
            if (!active || !acceptingPosts || stopping || posts.size >= limits.pendingPosts) {
                return false
            }
            if (let Some(ref) <- owner) {
                if (!ref.isValid()) {
                    return false
                }
            }
            posts.add(QueuedAction(owner, action));
            true
        } finally {
            lock.unlock()
        }
    }
    func requestStop(): Unit {
        lock.lock();
        try {
            stopping = true
        } finally {
            lock.unlock()
        }
    }
    func recordDeviceFailure(): Unit {
        if (firstDeviceFailure.isNone()) {
            firstDeviceFailure = Some(SessionDeviceException(unsafe { cjt_output_unsafe() } != 0))
        }
        requestStop()
    }
    func prioritizeFailure(error: Exception): Exception {
        if (let Some(first) <- firstDeviceFailure) {
            if ((cleanupPrimary(error) as SessionDeviceException).isSome()) {
                return error
            }
            return aggregateCleanup(first, error)
        }
        error
    }
    func throwDeviceFailure(): Unit {
        if (let Some(error) <- firstDeviceFailure) {
            throw error
        }
    }
    func isStopping(): Bool {
        lock.lock();
        try {
            stopping
        } finally {
            lock.unlock()
        }
    }
    func pump(): Unit {
        let turn = ArrayList<QueuedAction>()
        var turnCutoff: Int64 = 0
        lock.lock()
        try {
            turnCutoff = invalidationSequence
            for (post in posts) {
                turn.add(post)
            }
            posts.clear()
        } finally {
            lock.unlock()
        }
        for (item in turn) {
            if (isStopping()) {
                break
            }
            var run = true
            if (let Some(owner) <- item.owner) {
                run = owner.isValid()
            }
            if (run) {
                inCallback = true
                batchDepth++
                try {
                    item.action()
                } finally {
                    batchDepth--;
                    inCallback = false
                }
                stabilize(turnCutoff)
            }
        }
        stabilize(turnCutoff)
        applyPendingTheme()
    }
    func applyPendingTheme(): Unit {
        if (let Some(weak) <- application) {
            if (let Some(app) <- weak.value) { app.applyThemeCandidate(this) }
        }
    }
    func acceptTheme(value: Theme, layoutChanged: Bool): Unit {
        lock.lock()
        try {
            theme = value; changed = true
            if (layoutChanged) { measuredLayout = None }
            for (node in nodes) {
                if (layoutChanged) { node.layoutDirty = true }
                node.styleDirty = true
            }
        } finally { lock.unlock() }
    }
    func glyphPolicyChanged(): Unit {
        lock.lock()
        try {
            changed = true
            measuredLayout = None
            for (node in nodes) { node.layoutDirty = true }
        } finally { lock.unlock() }
    }
    func selectLayoutGlyphPolicy(policy: GlyphRenderPolicy): String {
        let marker = generatedEllipsis(policy, 3, ambiguousWide: false)
        if (marker != measuredGlyphMarker) { measuredLayout = None }
        measuredGlyphMarker = marker
        layoutGlyphPolicy = policy
        marker
    }
    func produce(width: Int64, height: Int64, force: Bool, glyphPolicy!: GlyphRenderPolicy = GlyphRenderPolicy.unicode()): Frame {
        let marker = selectLayoutGlyphPolicy(glyphPolicy)
        lock.lock()
        var dirtyFrame = false
        try {
            dirtyFrame = changed
        } finally {
            lock.unlock()
        }
        if (force || dirtyFrame || width != cachedWidth || height != cachedHeight || marker != cachedGlyphMarker || cached.isNone()) {
            lock.lock()
            try {
                for (node in nodes) {
                    node.contentDirty = false
                    node.styleDirty = false
                    node.layoutDirty = false
                }
            } finally {
                lock.unlock()
            }
            if ((width != cachedWidth || height != cachedHeight) && cachedWidth >= 0 && cachedHeight >= 0) {
                if (let Some(previousCaret) <- lastCaret) {
                    var hasExplicit = false
                    for (command in pendingEnsures) {
                        if (command.target.sameNode(previousCaret.owner)) { hasExplicit = true }
                    }
                    if (!hasExplicit && previousCaret.owner.isValid()) {
                        let ensure = ScrollCommand(previousCaret.owner,1,0,0,
                            Some(Rect(previousCaret.localX,previousCaret.localY,1,1)),ScrollAlign.Nearest,ScrollAlign.Nearest)
                        ensure.order = nextViewportIntent(); pendingEnsures.add(ensure)
                    }
                }
            }
            pendingCaret = None; trackCaret = true
            let frame: Frame
            try { frame = renderLayout(root, width, height, this) } finally { trackCaret = false }
            var nextCaret = CaretSnapshot(Option<NodeRef>.None,0,0,false)
            if (let Some(request) <- pendingCaret) {
                if (request.x >= 0 && request.x < frame.width && request.y >= 0 && request.y < frame.height) {
                    if (!frame.cellAt(request.x,request.y).continuation) {
                        nextCaret = CaretSnapshot(Some(request.owner),request.x,request.y,true)
                        lastCaret = Some(request)
                    }
                }
            }
            if (!nextCaret.visible) { lastCaret = None }
            caret = nextCaret
            recordFrame();
            cached = Some(frame)
            cachedGlyphMarker = marker
            cachedWidth = width
            cachedHeight = height
            lock.lock()
            try {
                changed = false
            } finally {
                lock.unlock()
            }
        }
        cached.getOrThrow().copy(Rect(0, 0, width, height))
    }
    func stats(): RuntimeStats {
        lock.lock()
        try {
            var mountedCount: Int64 = 0
            for (node in nodes) {
                if (node.valid && node.committed) {
                    mountedCount++
                }
            }
            var activeBindings: Int64 = 0
            var subscriptions: Int64 = 0
            for (binding in bindings) {
                if (binding.active) {
                    if (let Some(node) <- binding.node) {
                        if (node.valid && node.committed) {
                            activeBindings++
                            subscriptions += binding.publishedDependencies
                        }
                    }
                }
            }
            RuntimeStats(if (active) {
                mountedCount
            } else {
                0
            }, activeBindings, subscriptions, posts.size, builds, measures, paints, frames)
        } finally {
            lock.unlock()
        }
    }
    func notifyClosed(): Unit {
        if (let Some(weak) <- application) {
            if (let Some(app) <- weak.value) {
                app.sessionClosed(this)
            }
        }
    }
    func closeFailure(primary: Exception): Exception {
        var result = prioritizeFailure(primary)
        try {
            close()
        } catch (cleanup: Exception) {
            result = aggregateCleanup(result, cleanup)
        }
        notifyClosed()
        result
    }
    func closeStopped(): Unit {
        try {
            close()
        } finally {
            notifyClosed()
        }
    }
    func close(): Unit {
        if (!active) {
            return
        }
        lock.lock()
        try {
            active = false
            acceptingPosts = false
            posts.clear();
            pendingBindings.clear();
            pendingNodes.clear();
            commands.clear()
            for (node in nodes) {
                node.valid = false
                node.pendingChange = None
            }
        } finally {
            lock.unlock()
        }
        if (let Some(weak) <- application) {
            if (let Some(app) <- weak.value) { app.closeThemeSession(id) }
        }
        for (node in nodes) {
            node.component.clearMount()
        }
        for (binding in bindings) {
            binding.dispose()
        }
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
                    try {
                        cleanup()
                    } catch (error: Exception) {
                        match (failure) {
                            case None => failure = Some(error)
                            case Some(first) => failure = Some(aggregateCleanup(first, error))
                        }
                    } finally {
                        inLifecycle = false
                    }
                }
            }
        } finally {
            activeSession.set(previousSession)
        }
        for (node in nodes) {
            node.component.releaseMount()
        }
        try {
            extensions.close(this)
        } catch (error: Exception) {
            match (failure) {
                case None => failure = Some(error)
                case Some(first) => failure = Some(aggregateCleanup(first, error))
            }
        }
        if (let Some(error) <- failure) {
            throw error
        }
    }
}

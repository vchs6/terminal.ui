package cjtui

import std.collection.ArrayList
import std.sync.Mutex

public class Application {
    private let root: Component
    private var handler: (KeyEvent) -> Unit = {_ =>}
    private var running = false
    private let limits: RuntimeLimits
    private let sessionLock = Mutex()
    private var session: ?RuntimeSession = None
    private var latestStats = RuntimeStats(0, 0, 0, 0, 0, 0, 0, 0)
    private var eventHandler: ?(UIKeyEvent) -> Unit = None
    private var colorOverride: ?ColorMode = None
    private var lastCapabilities: ?TerminalCapabilities = None
    public init(root: Component, limits!: RuntimeLimits = RuntimeLimits()) {
        this.root = root
        this.limits = limits
    }
    public init(root: Component, colorMode!: ColorMode, limits!: RuntimeLimits = RuntimeLimits()) {
        this.root = root
        this.limits = limits
        colorOverride = Some(colorMode)
    }
    public func colorMode(value: ColorMode): Application {
        colorOverride = Some(value)
        this
    }
    public func colorModeAuto(): Application {
        colorOverride = None
        this
    }
    public func terminalCapabilities(): ?TerminalCapabilities {
        lastCapabilities
    }
    public func onKey(handler: (KeyEvent) -> Unit): Application {
        this.handler = handler
        this
    }
    public func stop(): Unit {
        if (let Some(value) <- readSession()) { value.requestStop() }
    }
    private func readSession(): ?RuntimeSession {
        sessionLock.lock()
        try { session } finally { sessionLock.unlock() }
    }
    public func onKeyEvent(handler: (UIKeyEvent) -> Unit): Application { eventHandler = Some(handler); this }
    func current(): RuntimeSession {
        match (readSession()) { case Some(value) => return value; case None => throw UIException("SessionInactive", "session is inactive") }
    }
    func sessionClosed(value: RuntimeSession): Unit {
        let snapshot = value.stats()
        sessionLock.lock()
        try {
            if (let Some(current) <- session) {
                if (current.id == value.id) { latestStats = snapshot; session = None }
            }
        } finally { sessionLock.unlock() }
    }
    public func stats(): RuntimeStats {
        sessionLock.lock()
        try { match (session) { case Some(value) => value.stats(); case None => latestStats } }
        finally { sessionLock.unlock() }
    }
    public func post(action: () -> Unit): Bool { match (readSession()) { case Some(value) => value.post(Option<NodeRef>.None, action); case None => false } }
    public func post(owner: NodeRef, action: () -> Unit): Bool {
        match (readSession()) { case Some(value) => value.post(Some(owner), action); case None => false }
    }
    public func startHeadless(): Unit {
        let value = RuntimeSession(root, limits, application: Some(this))
        sessionLock.lock()
        try {
            if (session.isSome()) { throw UIException("LifecycleReentry", "session already active") }
            session = Some(value)
        } finally { sessionLock.unlock() }
        try {
            value.start()
            if (value.isStopping()) { dispose() }
        } catch (error: Exception) {
            var failure: Exception = error
            try { value.close() } catch (cleanup: Exception) { failure = aggregateCleanup(failure, cleanup) }
            sessionClosed(value); throw failure
        }
    }
    public func dispose(): Unit {
        if (let Some(value) <- readSession()) {
            value.requireOwner()
            if (value.inLifecycle || value.inCallback || value.batchDepth > 0) {
                throw UIException("LifecycleReentry", "dispose requires an outer UI boundary")
            }
            value.requireContext()
            try { value.close() } finally { sessionClosed(value) }
        }
    }
    public func batch(action: () -> Unit): Unit {
        let value = current()
        value.requireContext()
        if (value.inLifecycle) { throw UIException("LifecycleReentry", "batch during lifecycle") }
        if (value.isStopping()) { dispose(); throw UIException("SessionInactive", "session stopped") }
        let turnCutoff = value.cutoff()
        try { value.enter({ =>
            value.batchDepth++
            try { action() } finally { value.batchDepth-- }
            if (value.batchDepth == 0) { value.stabilize(turnCutoff) }
        })
        if (value.batchDepth == 0 && value.isStopping()) { running = false; dispose() }
        } catch (error: Exception) {
            var failure: Exception = error
            try { value.close() } catch (cleanup: Exception) { failure = aggregateCleanup(failure, cleanup) }
            sessionClosed(value); throw failure
        }
    }
    public func snapshot(width: Int64, height: Int64): Frame {
        let value = current()
        value.requireBoundary()
        if (value.isStopping()) { dispose(); throw UIException("SessionInactive", "session stopped") }
        try {
            let frame = value.enter({ => value.pump(); value.produce(width, height, false) })
            if (value.isStopping()) { running = false; dispose() }
            return frame
        } catch (error: Exception) { throw value.closeFailure(error) }
    }
    public func dispatch(target: NodeRef, key: KeyEvent): Unit {
        let value = current()
        value.requireBoundary()
        if (value.isStopping()) { dispose(); throw UIException("SessionInactive", "session stopped") }
        let targetNode = target.resolve()
            if (targetNode.session.id != value.id) { throw UIException("WrongUIContext", "target belongs to another session") }
            let path = ArrayList<RuntimeNode>()
            var cursor: ?RuntimeNode = Some(targetNode)
            while (let Some(node) <- cursor) {
                if (!node.component.isVisible) { throw UIException("InvalidProperty", "hidden target") }
                path.add(node); cursor = node.parent
            }
        let event = UIKeyEvent(key, target)
        let turnCutoff = value.cutoff()
        try {
            value.enter({ =>
            value.inCallback = true; value.batchDepth++
            try {
                var i = path.size
                while (i > 0 && !event.stopped) {
                    i--; event.setCurrent(path[i].reference())
                    if (let Some(callback) <- path[i].component.captureHandler) { callback(event) }
                }
                i = 0
                while (i < path.size && !event.stopped) {
                    event.setCurrent(path[i].reference())
                    if (let Some(callback) <- path[i].component.keyHandler) { callback(event) }
                    i++
                }
                if (!event.stopped) { if (let Some(callback) <- eventHandler) { callback(event) } }
                if (!event.stopped && key.code != "interrupt") { handler(key) }
                if (key.code == "interrupt" && !event.defaultPrevented) { value.requestStop(); running = false }
            } finally { event.active = false; value.batchDepth--; value.inCallback = false }
            value.stabilize(turnCutoff)
            })
        } catch (error: Exception) {
            var failure: Exception = error
            try { value.close() } catch (cleanup: Exception) { failure = aggregateCleanup(failure, cleanup) }
            sessionClosed(value); throw failure
        }
        if (value.isStopping()) { running = false; dispose() }
    }
    private func dispatchHiddenKey(key: KeyEvent): Unit {
        let value = current()
        value.requireBoundary()
        let turnCutoff = value.cutoff()
        try {
            value.enter({ =>
                value.inCallback = true; value.batchDepth++
                try { handler(key) } finally { value.batchDepth--; value.inCallback = false }
                value.stabilize(turnCutoff)
            })
        } catch (error: Exception) { throw value.closeFailure(error) }
        if (value.isStopping()) { running = false; dispose() }
    }
    public func run(): Unit {
        if (unsafe { cjt_open() } != 0) {
            throw Exception("Linux ANSI TTY required")
        }
        var failure: ?Exception = None
        var restoreFailed = false
        try {
            startHeadless()
            running = readSession().isSome()
            let capabilities = detectTerminalCapabilities()
            lastCapabilities = Some(capabilities)
            let initialMode = match (colorOverride) {
                case Some(value) => value
                case None => capabilities.colorMode
            }
            let decoder = InputDecoder()
            var baseline: ?Frame = None
            var baselineProfile = terminalRenderProfile(capabilities, initialMode)
            var previousWidth: Int64 = -1
            var previousHeight: Int64 = -1
            while (running && !current().isStopping()) {
                let width = Int64(unsafe { cjt_size(0) })
                let height = Int64(unsafe { cjt_size(1) })
                if (width < 0 || height < 0) {
                    throw Exception("terminal size unavailable")
                }
                let mode = match (colorOverride) {
                    case Some(value) => value
                    case None => capabilities.colorMode
                }
                let profile = terminalRenderProfile(capabilities, mode)
                let work = current()
                if (work.needsWork() || width != previousWidth || height != previousHeight ||
                    mode != baselineProfile.colorMode || baseline.isNone()) {
                    let frame = snapshot(width, height)
                    var output = ""
                    if (width != previousWidth || height != previousHeight) { baseline = None }
                    match (baseline) {
                        case None => output = frame.toAnsiForTerminal(profile)
                        case Some(old) => output = frame.changesSinceForTerminal(old, baselineProfile, profile)
                    }
                    if (!output.isEmpty()) { writeScreen(output) }
                    baseline = Some(frame)
                    baselineProfile = profile
                    previousWidth = width
                    previousHeight = height
                }
                let value = readByte(100)
                if (value == -2) {
                    running = false
                    continue
                }
                if (value == -3) {
                    throw Exception("terminal input failed")
                }
                let event = if (value >= 0) {
                    decoder.feed(value)
                } else {
                    decoder.timeout()
                }
                match (event) {
                    case Some(key) =>
                        if (root.isVisible) { dispatch(root.reference().getOrThrow(), key) }
                        else if (key.code == "interrupt") { running = false }
                        else { dispatchHiddenKey(key) }
                    case None => ()
                }
            }
        } catch (error: Exception) {
            failure = Some(error)
        }
        try { dispose() } catch (error: Exception) {
            match (failure) {
                case None => failure = Some(error)
                case Some(first) => failure = Some(aggregateCleanup(first, error))
            }
        }
        try {} finally {
            running = false
            restoreFailed = unsafe { cjt_close() } != 0
        }
        match (failure) {
            case Some(error) =>
                if (restoreFailed) {
                    throw aggregateCleanup(error, Exception("terminal restore failed"))
                }
                throw error
            case None => ()
        }
        if (restoreFailed) {
            throw Exception("terminal restore failed")
        }
    }
}

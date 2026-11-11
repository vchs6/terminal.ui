package cjtui

import std.collection.ArrayList
import std.sync.Mutex

public class Application {
    private let root: Component
    private var handler: (KeyEvent) -> Unit = {_ =>}
    private var running = false
    private let limits: RuntimeLimits
    private let initialTheme: Theme
    private let sessionLock = Mutex()
    private var session: ?RuntimeSession = None
    private var latestStats = RuntimeStats(0, 0, 0, 0, 0, 0, 0, 0)
    private var eventHandler: ?(UIKeyEvent) -> Unit = None
    private var colorOverride: ?ColorMode = None
    private var lastCapabilities: ?TerminalCapabilities = None
    private var configuredGlyphMode = GlyphMode.Auto
    private var lastGlyphCapabilities: ?TerminalGlyphCapabilities = None
    private var configuredSessionOptions = SessionOptions()
    private var lastSessionCapabilities: ?SessionCapabilities = None
    private var lastSessionCleanup = Array<SessionResult>()
    public init(root: Component, limits!: RuntimeLimits = RuntimeLimits(), glyphMode!: GlyphMode = GlyphMode.Auto, theme!: Theme = Theme.preset(ThemePreset.Classic)) {
        this.root = root
        this.initialTheme = theme
        this.limits = limits
        this.configuredGlyphMode = glyphMode
    }
    public init(root: Component, colorMode!: ColorMode, limits!: RuntimeLimits = RuntimeLimits(), glyphMode!: GlyphMode = GlyphMode.Auto, theme!: Theme = Theme.preset(ThemePreset.Classic)) {
        this.root = root
        this.initialTheme = theme
        this.limits = limits
        this.configuredGlyphMode = glyphMode
        colorOverride = Some(colorMode)
    }
    public func glyphMode(value: GlyphMode): Application {
        if (configuredGlyphMode != value) {
            configuredGlyphMode = value
            if (let Some(active) <- readSession()) { active.glyphPolicyChanged() }
        }
        this
    }
    public func glyphMode(): GlyphMode { configuredGlyphMode }
    public func terminalGlyphCapabilities(): ?TerminalGlyphCapabilities { lastGlyphCapabilities }
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
    public func sessionOptions(options: SessionOptions): Application {
        sessionLock.lock()
        try {
            if (session.isSome()) {
                throw UIException("LifecycleReentry", "session options during active session")
            }
            configuredSessionOptions = options
        } finally {
            sessionLock.unlock()
        }
        this
    }
    public func sessionCapabilities(): ?SessionCapabilities {
        sessionLock.lock()
        try {
            lastSessionCapabilities
        } finally {
            sessionLock.unlock()
        }
    }
    public func sessionCleanupResults(): Array<SessionResult> {
        sessionLock.lock()
        try {
            Array<SessionResult>(lastSessionCleanup.size, {i => lastSessionCleanup[i].copy()})
        } finally {
            sessionLock.unlock()
        }
    }
    private func sessionOperation(operation: SessionOperation, action: (RuntimeSession) -> SessionResult): SessionResult {
        if (let Some(value) <- readSession()) {
            try {
                value.requireContext()
                if (value.inLifecycle) {
                    return value.extensions.failure(operation, SessionIssue.InvalidContext)
                }
            } catch (_: UIException) {
                return value.extensions.failure(operation, SessionIssue.InvalidContext)
            }
            if (value.isStopping()) {
                return value.extensions.failure(operation, SessionIssue.Cancelled)
            }
            return action(value)
        }
        sessionLock.lock()
        let options = try {
            configuredSessionOptions
        } finally {
            sessionLock.unlock()
        }
        SessionExtensionState(0, options, false).failure(operation, SessionIssue.SessionInactive)
    }
    public func copyLocalText(text: String): SessionResult {
        sessionOperation(SessionOperation.CopyLocalText, {value => value.extensions.copyText(value, text)})
    }
    public func setHostTitle(title: String): SessionResult {
        sessionOperation(SessionOperation.SetHostTitle, {value => value.extensions.setTitle(value, title)})
    }
    public func restoreHostTitle(): SessionResult {
        sessionOperation(SessionOperation.RestoreHostTitle, {value => value.extensions.restoreTitle(value)})
    }
    public func setHostImageIcon(png: Array<UInt8>): SessionResult {
        sessionOperation(SessionOperation.SetHostImageIcon, {value => value.extensions.setIcon(png)})
    }
    public func onKey(handler: (KeyEvent) -> Unit): Application {
        this.handler = handler
        this
    }
    public func stop(): Unit {
        if (let Some(value) <- readSession()) {
            value.requestStop()
        }
    }
    private func readSession(): ?RuntimeSession {
        sessionLock.lock()
        try {
            session
        } finally {
            sessionLock.unlock()
        }
    }
    public func onKeyEvent(handler: (UIKeyEvent) -> Unit): Application {
        eventHandler = Some(handler)
        this
    }
    func current(): RuntimeSession {
        match (readSession()) {
            case Some(value) => return value;
            case None => throw UIException("SessionInactive", "session is inactive")
        }
    }
    func sessionClosed(value: RuntimeSession): Unit {
        let snapshot = value.stats()
        sessionLock.lock()
        try {
            if (let Some(current) <- session) {
                if (current.id == value.id) {
                    latestStats = snapshot
                    lastSessionCleanup = value.extensions.cleanupSnapshot()
                    session = None
                }
            }
        } finally {
            sessionLock.unlock()
        }
    }
    public func stats(): RuntimeStats {
        sessionLock.lock()
        try {
            match (session) {
                case Some(value) => value.stats();
                case None => latestStats
            }
        } finally {
            sessionLock.unlock()
        }
    }
    public func post(action: () -> Unit): Bool {
        match (readSession()) {
            case Some(value) => value.post(Option<NodeRef>.None, action);
            case None => false
        }
    }
    public func post(owner: NodeRef, action: () -> Unit): Bool {
        match (readSession()) {
            case Some(value) => value.post(Some(owner), action);
            case None => false
        }
    }
    public func startHeadless(): Unit {
        startSession(false)
    }
    private func startSession(device: Bool): Unit {
        sessionLock.lock()
        let value: RuntimeSession
        try {
            if (session.isSome()) {
                throw UIException("LifecycleReentry", "session already active")
            }
            value = RuntimeSession(root, limits, application: Some(this), sessionOptions: configuredSessionOptions,
                device: device, theme: initialTheme)
            session = Some(value)
            lastSessionCapabilities = Some(value.extensions.capabilities)
            lastSessionCleanup = []
        } finally {
            sessionLock.unlock()
        }
        try {
            value.start()
            if (value.isStopping()) {
                dispose()
            }
        } catch (error: Exception) {
            var failure: Exception = value.prioritizeFailure(error)
            try {
                value.close()
            } catch (cleanup: Exception) {
                failure = aggregateCleanup(failure, cleanup)
            }
            sessionClosed(value);
            throw failure
        }
    }
    public func dispose(): Unit {
        if (let Some(value) <- readSession()) {
            value.requireOwner()
            if (value.inLifecycle || value.inCallback || value.batchDepth > 0) {
                throw UIException("LifecycleReentry", "dispose requires an outer UI boundary")
            }
            value.requireContext()
            try {
                value.close()
            } finally {
                sessionClosed(value)
            }
        }
    }
    public func batch(action: () -> Unit): Unit {
        let value = current()
        value.requireContext()
        if (value.inLifecycle) {
            throw UIException("LifecycleReentry", "batch during lifecycle")
        }
        if (value.isStopping()) {
            dispose();
            throw UIException("SessionInactive", "session stopped")
        }
        let turnCutoff = value.cutoff()
        try {
            value.enter(
                {
                    =>
                        value.batchDepth++
                        try {
                            action()
                        } finally {
                            value.batchDepth--
                        }
                        if (value.batchDepth == 0) {
                            value.stabilize(turnCutoff)
                        }
                }
            )
            if (value.batchDepth == 0 && value.isStopping()) {
                running = false
                dispose()
            }
        } catch (error: Exception) {
            var failure: Exception = value.prioritizeFailure(error)
            try {
                value.close()
            } catch (cleanup: Exception) {
                failure = aggregateCleanup(failure, cleanup)
            }
            sessionClosed(value);
            throw failure
        }
    }
    public func snapshot(width: Int64, height: Int64, glyphMode!: GlyphMode = GlyphMode.Unicode): Frame {
        snapshotWithPolicy(width, height, offlineGlyphPolicy(glyphMode))
    }
    private func snapshotWithPolicy(width: Int64, height: Int64, policy: GlyphRenderPolicy): Frame {
        let value = current()
        value.requireBoundary()
        if (value.isStopping()) {
            dispose();
            throw UIException("SessionInactive", "session stopped")
        }
        try {
            let frame = value.enter(
                {
                    =>
                        value.pump();
                        value.produce(width, height, false, glyphPolicy: policy)
                }
            )
            if (value.isStopping()) {
                running = false
                dispose()
            }
            return frame
        } catch (error: Exception) {
            throw value.closeFailure(error)
        }
    }
    public func dispatch(target: NodeRef, key: KeyEvent): Unit {
        let value = current()
        value.requireBoundary()
        if (value.isStopping()) {
            dispose();
            throw UIException("SessionInactive", "session stopped")
        }
        let targetNode = target.resolve()
        if (targetNode.session.id != value.id) {
            throw UIException("WrongUIContext", "target belongs to another session")
        }
        let path = ArrayList<RuntimeNode>()
        var cursor: ?RuntimeNode = Some(targetNode)
        while (let Some(node) <- cursor) {
            if (!node.component.isVisible) {
                throw UIException("InvalidProperty", "hidden target")
            }
            path.add(node);
            cursor = node.parent
        }
        let event = UIKeyEvent(key, target)
        let turnCutoff = value.cutoff()
        try {
            value.enter(
                {
                    =>
                        value.inCallback = true
                        value.batchDepth++
                        try {
                            var i = path.size
                            while (i > 0 && !event.stopped) {
                                i--;
                                event.setCurrent(path[i].reference())
                                if (let Some(callback) <- path[i].component.captureHandler) {
                                    callback(event)
                                }
                            }
                            i = 0
                            while (i < path.size && !event.stopped) {
                                event.setCurrent(path[i].reference())
                                if (let Some(callback) <- path[i].component.keyHandler) {
                                    callback(event)
                                }
                                i++
                            }
                            if (!event.stopped) {
                                if (let Some(callback) <- eventHandler) {
                                    callback(event)
                                }
                            }
                            if (!event.stopped && key.code != "interrupt") {
                                handler(key)
                            }
                            if (key.code == "interrupt" && !event.defaultPrevented) {
                                value.requestStop();
                                running = false
                            }
                        } finally {
                            event.active = false
                            value.batchDepth--;
                            value.inCallback = false
                        }
                        value.stabilize(turnCutoff)
                }
            )
        } catch (error: Exception) {
            var failure: Exception = value.prioritizeFailure(error)
            try {
                value.close()
            } catch (cleanup: Exception) {
                failure = aggregateCleanup(failure, cleanup)
            }
            sessionClosed(value);
            throw failure
        }
        if (value.isStopping()) {
            running = false
            dispose()
        }
    }
    private func dispatchHiddenKey(key: KeyEvent): Unit {
        let value = current()
        value.requireBoundary()
        let turnCutoff = value.cutoff()
        try {
            value.enter(
                {
                    =>
                        value.inCallback = true
                        value.batchDepth++
                        try {
                            handler(key)
                        } finally {
                            value.batchDepth--;
                            value.inCallback = false
                        }
                        value.stabilize(turnCutoff)
                }
            )
        } catch (error: Exception) {
            throw value.closeFailure(error)
        }
        if (value.isStopping()) {
            running = false
            dispose()
        }
    }
    public func run(): Unit {
        if (readSession().isSome()) {
            throw UIException("LifecycleReentry", "session already active")
        }
        if (unsafe { cjt_open() } != 0) {
            if (unsafe { cjt_output_unsafe() } != 0) {
                throw Exception("ParserUnsynchronized; terminal connection must be restored before restart")
            }
            throw Exception("Linux ANSI TTY required")
        }
        var failure: ?Exception = None
        var restoreFailed = false
        try {
            startSession(true)
            running = readSession().isSome()
            let capabilities = detectTerminalCapabilities()
            lastCapabilities = Some(capabilities)
            let (glyphCapabilities, detectedGlyphPolicy) = detectTerminalGlyphs()
            lastGlyphCapabilities = Some(glyphCapabilities)
            let initialMode = match (colorOverride) {
                case Some(value) => value
                case None => capabilities.colorMode
            }
            let decoder = InputDecoder()
            var baseline: ?Frame = None
            var baselineProfile = terminalRenderProfile(capabilities, initialMode)
            var baselineGlyphMode = configuredGlyphMode
            var previousWidth: Int64 = -1
            var previousHeight: Int64 = -1
            while (running && readSession().isSome()) {
                if (current().isStopping()) {
                    break
                }
                let (width, height) = readTerminalSize()
                if (width < 0 || height < 0) {
                    throw Exception("terminal size unavailable")
                }
                let mode = match (colorOverride) {
                    case Some(value) => value
                    case None => capabilities.colorMode
                }
                let requestGlyphMode = configuredGlyphMode
                let glyphPolicy = if (requestGlyphMode == GlyphMode.Auto) { detectedGlyphPolicy } else {
                    offlineGlyphPolicy(requestGlyphMode)
                }
                let profile = terminalRenderProfile(capabilities, mode, glyphPolicy: glyphPolicy)
                let work = current()
                if (work.needsWork() || width != previousWidth || height != previousHeight || mode != baselineProfile
                    .colorMode || requestGlyphMode != baselineGlyphMode || baseline.isNone()) {
                    let frame = snapshotWithPolicy(width, height, glyphPolicy)
                    if (readSession().isNone() || work.isStopping()) {
                        break
                    }
                    var output = ""
                    if (width != previousWidth || height != previousHeight) {
                        baseline = None
                    }
                    match (baseline) {
                        case None => output = frame.toAnsiForTerminal(profile)
                        case Some(old) => output = frame.changesSinceForTerminal(old, baselineProfile, profile)
                    }
                    var committed = true
                    if (!output.isEmpty()) {
                        let written = writeTerminal(output, work, true)
                        if (written.issue == SessionIssue.Cancelled) {
                            break
                        }
                        if (written.issue == SessionIssue.AllocationFailed) {
                            // No bytes reached the terminal: retry a full frame on a later turn.
                            committed = false
                        } else if (written.issue != SessionIssue.NoIssue) {
                            work.recordDeviceFailure()
                            work.throwDeviceFailure()
                        }
                    }
                    if (committed) {
                        baseline = Some(frame)
                        baselineProfile = profile
                        baselineGlyphMode = requestGlyphMode
                        previousWidth = width
                        previousHeight = height
                    } else {
                        baseline = None
                    }
                }
                if (readSession().isNone() || work.isStopping()) {
                    break
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
                        if (root.isVisible) {
                            dispatch(root.reference().getOrThrow(), key)
                        } else if (key.code == "interrupt") {
                            running = false
                        } else {
                            dispatchHiddenKey(key)
                        }
                    case None => ()
                }
            }
        } catch (error: Exception) {
            failure = Some(error)
        }
        try {
            dispose()
        } catch (error: Exception) {
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

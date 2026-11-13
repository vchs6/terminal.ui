package cjtui

import std.collection.ArrayList
import std.sync.Mutex

public class Application {
    private let root: Component
    private var handler: (KeyEvent) -> Unit = {_ =>}
    private var running = false
    private let limits: RuntimeLimits
    private let themeLoader: ThemeLoader
    private let sessionLock = Mutex()
    private var session: ?RuntimeSession = None
    private var latestStats = RuntimeStats(0, 0, 0, 0, 0, 0, 0, 0)
    private var eventHandler: ?(UIKeyEvent) -> Unit = None
    private var keyboardIssueHandler: ?(KeyboardDiagnostic) -> Unit = None
    private let keyboardLimits: KeyboardLimits
    private var colorOverride: ?ColorMode = None
    private var lastCapabilities: ?TerminalCapabilities = None
    private var configuredGlyphMode = GlyphMode.Auto
    private var lastGlyphCapabilities: ?TerminalGlyphCapabilities = None
    private var configuredSessionOptions = SessionOptions()
    private var lastSessionCapabilities: ?SessionCapabilities = None
    private var lastSessionCleanup = Array<SessionResult>()
    public init(root: Component, limits!: RuntimeLimits = RuntimeLimits(), glyphMode!: GlyphMode = GlyphMode.Auto, theme!: Theme = Theme.preset(ThemePreset.Classic), keyboardLimits!: KeyboardLimits = KeyboardLimits()) {
        this.root = root
        this.keyboardLimits = keyboardLimits
        this.themeLoader = ThemeLoader(theme)
        this.limits = limits
        this.configuredGlyphMode = glyphMode
    }
    public init(root: Component, colorMode!: ColorMode, limits!: RuntimeLimits = RuntimeLimits(), glyphMode!: GlyphMode = GlyphMode.Auto, theme!: Theme = Theme.preset(ThemePreset.Classic), keyboardLimits!: KeyboardLimits = KeyboardLimits()) {
        this.root = root
        this.keyboardLimits = keyboardLimits
        this.themeLoader = ThemeLoader(theme)
        this.limits = limits
        this.configuredGlyphMode = glyphMode
        colorOverride = Some(colorMode)
    }
    public func loadTheme(source: ThemeSource): ThemeRequest { themeLoader.submit(source,false) }
    public func reloadTheme(): ThemeRequest { themeLoader.submit(ThemeSource.Prepared(themeLoader.currentTheme()),true) }
    public func themeInfo(): ThemeInfo { themeLoader.info() }
    func closeThemeSession(id: Int64): Unit { themeLoader.closeSession(id) }
    func applyThemeCandidate(session: RuntimeSession): Unit {
        if (let Some(candidate) <- themeLoader.candidate(session.id)) {
            if (candidate.fault.isSome()) {
                if (let Some(fault) <- themeLoader.claimFault(session.id,candidate)) { throw fault }
                return
            }
            let (error, layoutChanged) = if (let Some(d) <- candidate.diagnostic) { (Some(d), false) }
                else { validateThemeCandidate(session,candidate.theme.getOrThrow()) }
            themeLoader.finish(session,candidate,error,layoutChanged)
        }
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
    public func onKeyboardIssue(handler: (KeyboardDiagnostic) -> Unit): Application {
        keyboardIssueHandler = Some(handler); this
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
    public func caretSnapshot(): CaretSnapshot {
        if (let Some(value) <- readSession()) { value.requireReadContext(); return value.caret }
        CaretSnapshot(Option<NodeRef>.None,0,0,false)
    }
    public func focusedNode(): ?NodeRef {
        if (let Some(value) <- readSession()) {
            value.requireReadContext(); value.focusManager.observe()
            if (let Some(node) <- value.focusManager.focused) { return Some(node.reference()) }
        }
        None
    }
    public func activeTarget(): ?NodeRef {
        if (let Some(value) <- readSession()) {
            value.requireReadContext(); value.focusManager.observe()
            if (let Some(node) <- value.focusManager.focused) {
                if (value.focusManager.effective(node,true)) {
                    if (value.focusManager.effective(node,false)) {
                        if (value.inOverlayDomain(node)) { return Some(node.reference()) }
                    }
                }
            }
            if (let Some(reserved) <- value.reservedLayer) {
                if (let Some(rootRef) <- reserved.root) { if (rootRef.isValid()) {
                    let root = rootRef.resolve()
                    if (value.focusManager.effective(root,true)) {
                        if (value.focusManager.effective(root,false)) {
                            if (value.inOverlayDomain(root)) { return Some(rootRef) }
                        }
                    }
                } }
            }
            if (let Some(modal) <- value.topModal()) {
                if (let Some(rootRef) <- modal.root) { if (rootRef.isValid()) {
                    let root = rootRef.resolve()
                    if (value.focusManager.effective(root,true)) {
                        if (value.focusManager.effective(root,false)) { return Some(rootRef) }
                    }
                } }
            }
            if (value.topModal().isNone()) {
                if (let Some(node) <- value.root.readMount()) {
                    if (value.focusManager.effective(node,true)) {
                        if (value.focusManager.effective(node,false)) { return Some(node.reference()) }
                    }
                }
            }
        }
        None
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
                device: device, theme: themeLoader.currentTheme())
            session = Some(value)
            themeLoader.open(value.id)
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
                            applyThemeCandidate(value)
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
                        value.validationWidth = width; value.validationHeight = height
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
        validateKeyboardEvent(key)
        let targetNode = target.resolve()
        if (targetNode.session.id != value.id) {
            throw UIException("WrongUIContext", "target belongs to another session")
        }
        if (!value.inOverlayDomain(targetNode)) { throw UIException("FocusOutsideDomain", "target outside modal domain") }
        if (let Some(layer) <- value.layerFor(targetNode)) {
            if (layer.options.mode == OverlayMode.Passive) { throw UIException("InvalidProperty", "passive layer cannot be a keyboard target") }
        }
        let path = ArrayList<RuntimeNode>()
        var cursor: ?RuntimeNode = Some(targetNode)
        var checkEnabled = true
        let modal = value.topModal()
        while (let Some(node) <- cursor) {
            if (!node.component.isVisible || (checkEnabled && !node.component.isEnabled)) {
                throw UIException("InvalidProperty", "hidden target")
            }
            path.add(node);
            if (node.overlayRoot) { checkEnabled = false }
            if (let Some(layer) <- modal) {
                if (let Some(rootRef) <- layer.root) { if (rootRef.sameNode(node.reference())) { break } }
            }
            cursor = node.parent
        }
        let captures = Array<?(UIKeyEvent) -> Unit>(path.size,{i => path[i].component.captureHandler})
        let bubbles = Array<?(UIKeyEvent) -> Unit>(path.size,{i => path[i].component.keyHandler})
        let ancestors = Array<?(UIKeyEvent) -> Unit>(path.size,{i => path[i].component.ancestorDefault})
        let targetDefault = targetNode.component.targetDefault
        let savedAppHandler = eventHandler
        let savedLegacy = handler
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
                                if (let Some(callback) <- captures[i]) {
                                    callback(event)
                                }
                            }
                            i = 0
                            while (i < path.size && !event.stopped) {
                                event.setCurrent(path[i].reference())
                                if (let Some(callback) <- bubbles[i]) {
                                    callback(event)
                                }
                                i++
                            }
                            if (!event.stopped && modal.isNone()) {
                                if (let Some(callback) <- savedAppHandler) {
                                    callback(event)
                                }
                            }
                            if (!event.stopped && key.code != "interrupt" && modal.isNone()) {
                                savedLegacy(key)
                            }
                            if (!event.defaultPrevented) {
                                event.setCurrent(target)
                                if (let Some(callback) <- targetDefault) { callback(event) }
                            }
                            if (!event.defaultPrevented) {
                                if (key.code == "interrupt") { value.requestStop(); running = false; event.preventDefault() }
                                else if (key.code == "tab" || key.code == "backtab") {
                                    if (value.focusManager.move(key.code == "backtab" || key.shift)) { event.preventDefault() }
                                } else if (key.code == "escape") {
                                    if (let Some(layer) <- value.layerFor(targetNode)) {
                                        if (layer.options.mode != OverlayMode.Passive && layer.options.closeOnEscape) {
                                            value.closeOverlay(layer,OverlayCloseReason.Escape); event.preventDefault()
                                        }
                                    }
                                }
                            }
                            i = 0
                            while (i < path.size && !event.defaultPrevented) {
                                event.setCurrent(path[i].reference())
                                if (let Some(callback) <- ancestors[i]) { callback(event) }
                                if (!event.defaultPrevented) {
                                    if (viewportDefault(path[i],key)) { event.preventDefault() }
                                }
                                i++
                            }
                        } finally {
                            event.active = false
                            value.batchDepth--;
                            value.inCallback = false
                        }
                        value.stabilize(turnCutoff)
                        applyThemeCandidate(value)
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
    private func dispatchDeviceKey(key: KeyEvent): Unit {
        if (let Some(target) <- activeTarget()) { dispatch(target,key) }
        else if (key.code == "interrupt") { running = false }
        else { dispatchHiddenKey(key) }
    }
    private func reportKeyboardIssue(diagnostic: KeyboardDiagnostic): Unit {
        if (let Some(callback) <- keyboardIssueHandler) {
            batch({ =>
                let work = current(); work.inCallback = true
                try { callback(diagnostic) } finally { work.inCallback = false }
            })
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
        let probe = CaretProbe()
        var deviceSession: ?RuntimeSession = None
        var pasteEnabled = false
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
            let decoder = KeyboardDecoder(limits: keyboardLimits)
            decoder.caretProbe = Some(probe)
            decoder.inputActive = Some({ =>
                if (!running) { false }
                else if (let Some(work) <- readSession()) { !work.isStopping() }
                else { false }
            })
            let pasteTarget: Array<?NodeRef> = [None]
            decoder.onPasteStart = Some({ => pasteTarget[0] = activeTarget() })
            decoder.onIssue = Some({diagnostic => reportKeyboardIssue(diagnostic)})
            decoder.onEvent = Some({key =>
                if (key.code != "paste") { dispatchDeviceKey(key) }
                else {
                    var available = false
                    if (let Some(target) <- pasteTarget[0]) {
                        if (target.isValid() && readSession().isSome()) {
                            let node = target.resolve(); let owner = current()
                            if (owner.focusManager.effective(node,true)) {
                                if (owner.focusManager.effective(node,false)) {
                                    available = owner.inOverlayDomain(node)
                                }
                            }
                            if (available) { dispatch(target,key) }
                        }
                    }
                    if (!available) { reportKeyboardIssue(KeyboardDiagnostic(KeyboardIssue.PasteTargetUnavailable, decoder.pasteOffset())) }
                    pasteTarget[0] = Option<NodeRef>.None
                }
            })
            if (let Some(work) <- readSession()) {
                deviceSession = Some(work)
                if (!work.isStopping()) {
                    let enabled = writeTerminal("\u{1b}[?2004h",work,true)
                    if (enabled.issue == SessionIssue.Cancelled) { running = false }
                    else if (enabled.issue == SessionIssue.AllocationFailed) { throw Exception("paste mode allocation failed") }
                    else if (enabled.issue != SessionIssue.NoIssue) { work.recordDeviceFailure(); work.throwDeviceFailure() }
                    else { pasteEnabled = true }
                    let before = unsafe { cjt_monotonic_ms() }
                    if (before < 0 || before > Int64.Max - 600) { probe.status = "unknown-clock" }
                    else {
                        let written = writeTerminal("\u{1b}[?25$p",work,true)
                        if (written.issue == SessionIssue.Cancelled) { running = false }
                        else if (written.issue == SessionIssue.AllocationFailed) { throw Exception("caret query allocation failed") }
                        else if (written.issue != SessionIssue.NoIssue) { work.recordDeviceFailure(); work.throwDeviceFailure() }
                        else { probe.begin(unsafe { cjt_monotonic_ms() }) }
                    }
                    lastCapabilities = Some(capabilities.withCursorStatus(probe.status))
                }
            }
            var lastInput: Int64 = -1
            // If the clock fails, count completed poll intervals rather than
            // interpreting a probe wakeup as a full keyboard idle interval.
            var untimedIdleRemaining: Int64 = 0
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
                let hasThemeCandidate = themeLoader.hasCandidate(work.id)
                if (probe.status == "pending") { probe.check(unsafe { cjt_monotonic_ms() }) }
                lastCapabilities = Some(capabilities.withCursorStatus(probe.status))
                if (work.needsWork() || hasThemeCandidate || probe.dirty || width != previousWidth || height != previousHeight || mode != baselineProfile
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
                    let logicalCaret = work.caret
                    if (logicalCaret.visible) {
                        output += "\u{1b}[${logicalCaret.y + 1};${logicalCaret.x + 1}H"
                    }
                    if (probe.known() && (probe.dirty || logicalCaret.visible != probe.currentVisible)) {
                        output += if (logicalCaret.visible) { "\u{1b}[?25h" } else { "\u{1b}[?25l" }
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
                        probe.committed(logicalCaret.visible)
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
                var readTimeout: Int64 = 100
                if (probe.status == "pending") {
                    let now = unsafe { cjt_monotonic_ms() }
                    probe.check(now)
                    if (probe.status == "pending") { readTimeout = lesser(readTimeout,probe.deadline - now) }
                    lastCapabilities = Some(capabilities.withCursorStatus(probe.status))
                }
                if (decoder.waitingIdle() && lastInput >= 0) {
                    let now = unsafe { cjt_monotonic_ms() }
                    if (now < 0) { lastInput = -1; untimedIdleRemaining = 100 }
                    else if (now >= lastInput) { readTimeout = lesser(readTimeout,greater(0,100 - (now - lastInput))) }
                }
                if (decoder.waitingIdle() && untimedIdleRemaining > 0) {
                    readTimeout = lesser(readTimeout,untimedIdleRemaining)
                }
                let value = readByte(Int32(readTimeout))
                if (probe.status == "pending") { probe.check(unsafe { cjt_monotonic_ms() }) }
                lastCapabilities = Some(capabilities.withCursorStatus(probe.status))
                if (value == -2) {
                    running = false
                    continue
                }
                if (value == -3) {
                    throw Exception("terminal input failed")
                }
                if (value == -4) {
                    decoder.finish(); running = false; continue
                }
                if (value == -5) { continue }
                if (value == -1 && decoder.waitingIdle() && untimedIdleRemaining > 0) {
                    untimedIdleRemaining -= lesser(untimedIdleRemaining,readTimeout)
                    if (untimedIdleRemaining == 0) {
                        lastInput = -1
                        decoder.timeout()
                        if (readSession().isNone() || work.isStopping()) { break }
                        continue
                    }
                }
                if (value >= 0 && decoder.waitingIdle() && lastInput >= 0) {
                    let now = unsafe { cjt_monotonic_ms() }
                    if (now < 0) {
                        lastInput = -1; untimedIdleRemaining = 100
                    } else if (now >= lastInput && now - lastInput >= 100) {
                        lastInput = -1
                        decoder.timeout()
                        if (readSession().isNone() || work.isStopping()) { break }
                    }
                }
                if (value >= 0) {
                    decoder.feed([UInt8(value)])
                    if (decoder.waitingIdle()) {
                        lastInput = unsafe { cjt_monotonic_ms() }
                        untimedIdleRemaining = if (lastInput < 0) { 100 } else { 0 }
                    } else { lastInput = -1; untimedIdleRemaining = 0 }
                } else if (decoder.waitingIdle() && lastInput >= 0) {
                    let now = unsafe { cjt_monotonic_ms() }
                    if (now < 0) {
                        lastInput = -1
                        untimedIdleRemaining = greater(0,100 - readTimeout)
                        if (untimedIdleRemaining == 0) { decoder.timeout() }
                    } else if (now >= lastInput && now - lastInput >= 100) {
                        lastInput = -1; decoder.timeout()
                    }
                }
                lastCapabilities = Some(capabilities.withCursorStatus(probe.status))
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
        let canRestorePaste = if (pasteEnabled) { unsafe { cjt_output_unsafe() } == 0 } else { false }
        if (canRestorePaste) {
            if (let Some(work) <- deviceSession) {
                let written = writeTerminal("\u{1b}[?2004l",work,false)
                if (written.issue != SessionIssue.NoIssue) {
                    let error = SessionDeviceException(unsafe { cjt_output_unsafe() } != 0)
                    match (failure) { case None => failure = Some(error); case Some(first) => failure = Some(aggregateCleanup(first,error)) }
                }
            }
        }
        if (probe.known() && probe.managed && probe.currentVisible != probe.originalVisible) {
            let outputSafe = unsafe { cjt_output_unsafe() } == 0
            if (outputSafe) {
                if (let Some(work) <- deviceSession) {
                    let restore = if (probe.originalVisible) { "\u{1b}[?25h" } else { "\u{1b}[?25l" }
                    let written = writeTerminal(restore,work,false)
                    if (written.issue != SessionIssue.NoIssue) {
                        let error = SessionDeviceException(unsafe { cjt_output_unsafe() } != 0)
                        match (failure) { case None => failure = Some(error); case Some(first) => failure = Some(aggregateCleanup(first,error)) }
                    }
                }
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

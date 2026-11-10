package cjtui

public class Application {
    private let root: Component
    private var handler: (KeyEvent) -> Unit = {_ =>}
    private var running = false
    private var colorOverride: ?ColorMode = None
    private var lastCapabilities: ?TerminalCapabilities = None
    public init(root: Component) {
        this.root = root
    }
    public init(root: Component, colorMode!: ColorMode) {
        this.root = root
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
        running = false
    }
    public func run(): Unit {
        if (unsafe { cjt_open() } != 0) {
            throw Exception("Linux ANSI TTY required")
        }
        running = true
        let capabilities = detectTerminalCapabilities()
        lastCapabilities = Some(capabilities)
        let initialMode = match (colorOverride) {
            case Some(value) => value
            case None => capabilities.colorMode
        }
        var failure: ?Exception = None
        var restoreFailed = false
        try {
            let decoder = InputDecoder()
            var baseline: ?Frame = None
            var baselineProfile = terminalRenderProfile(capabilities, initialMode)
            var previousWidth: Int64 = -1
            var previousHeight: Int64 = -1
            while (running) {
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
                let frame = render(root, width, height)
                var output = ""
                if (width != previousWidth || height != previousHeight) {
                    baseline = None
                }
                match (baseline) {
                    case None => output = frame.toAnsiForTerminal(profile)
                    case Some(old) => output = frame.changesSinceForTerminal(old, baselineProfile, profile)
                }
                if (!output.isEmpty()) {
                    writeScreen(output)
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
                        if (key.code == "interrupt") {
                            running = false
                        } else {
                            handler(key)
                        }
                    case None => ()
                }
            }
        } catch (error: Exception) {
            failure = Some(error)
        } finally {
            running = false
            restoreFailed = unsafe { cjt_close() } != 0
        }
        match (failure) {
            case Some(error) =>
                if (restoreFailed) {
                    throw Exception("${error.message}; terminal restore failed")
                }
                throw error
            case None => ()
        }
        if (restoreFailed) {
            throw Exception("terminal restore failed")
        }
    }
}

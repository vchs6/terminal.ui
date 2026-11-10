package cjtui

public class Application {
    private let root: Component
    private var handler: (KeyEvent) -> Unit = {_ =>}
    private var running = false
    private var mode: ColorMode
    public init(root: Component, colorMode!: ColorMode = ColorMode.Basic16) {
        this.root = root
        this.mode = colorMode
    }
    public func colorMode(value: ColorMode): Application {
        mode = value
        this
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
        var failure: ?Exception = None
        var restoreFailed = false
        try {
            let decoder = InputDecoder()
            var baseline: ?Frame = None
            var baselineMode = mode
            var previousWidth: Int64 = -1
            var previousHeight: Int64 = -1
            while (running) {
                let width = Int64(unsafe { cjt_size(0) })
                let height = Int64(unsafe { cjt_size(1) })
                if (width < 0 || height < 0) {
                    throw Exception("terminal size unavailable")
                }
                let frame = render(root, width, height)
                var output = ""
                if (width != previousWidth || height != previousHeight) {
                    baseline = None
                }
                match (baseline) {
                    case None => output = frame.toAnsi(colorMode: mode)
                    case Some(old) => output = frame.changesSince(old, baselineMode, mode)
                }
                if (!output.isEmpty()) {
                    writeScreen(output)
                }
                baseline = frame
                baselineMode = mode
                previousWidth = width
                previousHeight = height
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

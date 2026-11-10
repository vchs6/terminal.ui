package cjtui

public class Application {
    private let root: Component
    private var handler: (KeyEvent) -> Unit = {_ =>}
    private var running = false
    public init(root: Component) {
        this.root = root
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
        try {
            let decoder = InputDecoder()
            var baseline: ?Frame = None
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
                    case None => output = frame.toAnsi()
                    case Some(old) => output = frame.changesSince(old)
                }
                if (!output.isEmpty()) {
                    writeScreen(output)
                }
                baseline = frame
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
        } finally {
            running = false
            if (unsafe { cjt_close() } != 0) {
                throw Exception("terminal restore failed")
            }
        }
    }
}

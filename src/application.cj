package cjtui
foreign {
    func cjt_open(): Int32
    func cjt_close(): Int32
    func cjt_size(axis: Int32): Int32
    func cjt_read(timeout: Int32): Int32
    func cjt_buffer_clear(): Unit
    func cjt_buffer_add(value: Int32): Int32
    func cjt_buffer_write(): Int32
}
public class KeyEvent {
    public let code: String
    public let text: String
    init(code: String, text: String) { this.code = code; this.text = text }
    init(code: String) { this.code = code; this.text = "" }
}
func readByte(timeout: Int32): Int32 { unsafe { cjt_read(timeout) } }
var discardSequence: Int32 = 0
var discardEscaped = false
func nextKey(first: Int32): ?KeyEvent {
    if (discardSequence != 0) {
        if (discardSequence == 1 && first >= 64 && first <= 126) { discardSequence = 0 }
        if (discardSequence == 2) {
            if (first == 7 || (discardEscaped && first == 92)) { discardSequence = 0 }
            discardEscaped = first == 27
        }
        return None
    }
    if (first == 3) { return KeyEvent("interrupt") }
    if (first == 13 || first == 10) { return KeyEvent("enter") }
    if (first == 127 || first == 8) { return KeyEvent("backspace") }
    if (first == 27) {
        let next = readByte(35)
        if (next == -1) { return KeyEvent("escape") }
        if (next == 93 || next == 80 || next == 94 || next == 95) {
            var escaped = false
            for (_ in 0..256) {
                let b = readByte(35)
                if (b < 0) { discardSequence = 2; discardEscaped = escaped; return None }
                if (b == 7 || (escaped && b == 92)) { return None }
                escaped = b == 27
            }
            discardSequence = 2; discardEscaped = escaped
            return None
        }
        if (next != 91 && next != 79) { return None }
        var intermediate = false
        for (_ in 0..32) {
            let b = readByte(35)
            if (b < 0) { discardSequence = 1; return None }
            if (b >= 64 && b <= 126) {
                if (intermediate) { return None }
                match (b) {
                    case 65 => return KeyEvent("up")
                    case 66 => return KeyEvent("down")
                    case 67 => return KeyEvent("right")
                    case 68 => return KeyEvent("left")
                    case _ => return None
                }
            }
            intermediate = true
        }
        discardSequence = 1
        return None
    }
    if (first < 32 || first == 127) { return None }
    if (first < 128) { return KeyEvent("text", String(Rune(UInt32(first)))) }
    var count: Int32 = 0
    var code: UInt32 = 0
    var minimum: UInt32 = 0
    if (first >= 194 && first <= 223) { count = 1; code = UInt32(first & 31); minimum = 128 }
    else if (first >= 224 && first <= 239) { count = 2; code = UInt32(first & 15); minimum = 2048 }
    else if (first >= 240 && first <= 244) { count = 3; code = UInt32(first & 7); minimum = 65536 }
    else { return None }
    for (_ in 0..count) {
        let b = readByte(100)
        if (b < 128 || b > 191) { return None }
        code = (code << 6) | UInt32(b & 63)
    }
    if (code < minimum || code > 0x10ffff || (code >= 0xd800 && code <= 0xdfff) || (code >= 128 && code < 160)) { return None }
    KeyEvent("text", String(Rune(code)))
}
func writeScreen(value: String): Unit {
    unsafe {
        cjt_buffer_clear()
        for (b in value.toArray()) {
            if (cjt_buffer_add(Int32(b)) != 0) { throw Exception("terminal output allocation failed") }
        }
        if (cjt_buffer_write() != 0) { throw Exception("terminal write failed; display synchronization lost") }
    }
}
public class Application {
    private let root: Component
    private var handler: (KeyEvent) -> Unit = { _ => }
    private var running = false
    public init(root: Component) { this.root = root }
    public func onKey(handler: (KeyEvent) -> Unit): Application { this.handler = handler; this }
    public func stop(): Unit { running = false }
    public func run(): Unit {
        if (unsafe { cjt_open() } != 0) { throw Exception("Linux ANSI TTY required") }
        running = true
        discardSequence = 0; discardEscaped = false
        try {
            var baseline: ?Frame = None
            var previousWidth: Int64 = -1
            var previousHeight: Int64 = -1
            while (running) {
                let width = Int64(unsafe { cjt_size(0) })
                let height = Int64(unsafe { cjt_size(1) })
                if (width < 0 || height < 0) { throw Exception("terminal size unavailable") }
                let frame = render(root, width, height)
                var output = ""
                if (width != previousWidth || height != previousHeight) { baseline = None }
                match (baseline) {
                    case None => output = frame.toAnsi()
                    case Some(old) => output = frame.changesSince(old)
                }
                if (!output.isEmpty()) { writeScreen(output) }
                baseline = frame; previousWidth = width; previousHeight = height
                let value = readByte(100)
                if (value == -2) { running = false; continue }
                if (value == -3) { throw Exception("terminal input failed") }
                if (value >= 0) {
                    match (nextKey(value)) {
                        case Some(event) => if (event.code == "interrupt") { running = false } else { handler(event) }
                        case None => ()
                    }
                }
            }
        } finally {
            running = false
            if (unsafe { cjt_close() } != 0) { throw Exception("terminal restore failed") }
        }
    }
}

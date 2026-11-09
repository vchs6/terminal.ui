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
// The parser keeps only bounded state across polls and never forwards control payloads.
class InputDecoder {
    var state: Int64 = 0 // normal, ESC, CSI, string, string-ESC, ESC intermediate
    var parameter = false
    var stringRemaining: Int32 = 0
    var stringC2 = false
    var remaining: Int32 = 0
    var code: UInt32 = 0
    var minimum: UInt32 = 0
    func timeout(): ?KeyEvent {
        if (state == 1) { state = 0; return KeyEvent("escape") }
        None
    }
    func feed(first: Int32): ?KeyEvent {
        if (first == 3) { state = 0; remaining = 0; return KeyEvent("interrupt") }
        if (state == 3) {
            if (first == 7 || first == 27) {
                state = if (first == 7) { 0 } else { 4 }
                stringRemaining = 0; stringC2 = false
            } else if (stringRemaining > 0 && first >= 128 && first <= 191) {
                if (stringC2 && first == 0x9c) { state = 0 }
                stringRemaining--; stringC2 = false
            } else {
                stringRemaining = 0; stringC2 = false
                if (first == 0x9c) { state = 0 }
                else if (first >= 194 && first <= 223) { stringRemaining = 1; stringC2 = first == 194 }
                else if (first >= 224 && first <= 239) { stringRemaining = 2 }
                else if (first >= 240 && first <= 244) { stringRemaining = 3 }
            }
            return None
        }
        if (state == 4) {
            if (first == 92 || first == 7) { state = 0; return None }
            if (first == 27) { return None }
            state = 3; stringRemaining = 0; stringC2 = false
            // This byte belongs to the discarded string too, including UTF-8 leads.
            return feed(first)
        }
        if (state == 2) {
            if (first >= 64 && first <= 126) {
                state = 0
                if (!parameter) {
                    match (first) {
                        case 65 => return KeyEvent("up")
                        case 66 => return KeyEvent("down")
                        case 67 => return KeyEvent("right")
                        case 68 => return KeyEvent("left")
                        case _ => ()
                    }
                }
            } else if (first == 27) { state = 1 }
            else { parameter = true }
            return None
        }
        if (state == 5) {
            if (first >= 48 && first <= 126) { state = 0 }
            else if (first == 27) { state = 1 }
            return None
        }
        if (state == 1) {
            state = 0
            if (first == 91 || first == 79) { state = 2; parameter = false }
            else if (first == 93 || first == 80 || first == 88 || first == 94 || first == 95) { state = 3; stringRemaining = 0; stringC2 = false }
            else if (first >= 32 && first <= 47) { state = 5 }
            else if (first == 27) { state = 1 }
            return None
        }
        if (remaining > 0) {
            if (first >= 128 && first <= 191) {
                code = (code << 6) | UInt32(first & 63)
                remaining--
                if (remaining != 0) { return None }
                if (code < minimum || code > 0x10ffff || (code >= 0xd800 && code <= 0xdfff)) { return None }
                if (code >= 128 && code < 160) {
                    if (code == 0x90 || code == 0x98 || code == 0x9d || code == 0x9e || code == 0x9f) { state = 3; stringRemaining = 0; stringC2 = false }
                    else if (code == 0x9b) { state = 2; parameter = false }
                    return None
                }
                return KeyEvent("text", String(Rune(code)))
            }
            remaining = 0
            // A malformed prefix must not consume the next independent byte.
            return feed(first)
        }
        if (first == 27) { state = 1; return None }
        if (first == 13 || first == 10) { return KeyEvent("enter") }
        if (first == 127 || first == 8) { return KeyEvent("backspace") }
        if (first < 32) { return None }
        if (first < 128) { return KeyEvent("text", String(Rune(UInt32(first)))) }
        if (first >= 194 && first <= 223) { remaining = 1; code = UInt32(first & 31); minimum = 128 }
        else if (first >= 224 && first <= 239) { remaining = 2; code = UInt32(first & 15); minimum = 2048 }
        else if (first >= 240 && first <= 244) { remaining = 3; code = UInt32(first & 7); minimum = 65536 }
        else if (first == 0x90 || first == 0x98 || first == 0x9d || first == 0x9e || first == 0x9f) { state = 3; stringRemaining = 0; stringC2 = false }
        else if (first == 0x9b) { state = 2; parameter = false }
        None
    }
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
        try {
            let decoder = InputDecoder()
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
                let event = if (value >= 0) { decoder.feed(value) } else { decoder.timeout() }
                match (event) {
                    case Some(key) => if (key.code == "interrupt") { running = false } else { handler(key) }
                    case None => ()
                }
            }
        } finally {
            running = false
            if (unsafe { cjt_close() } != 0) { throw Exception("terminal restore failed") }
        }
    }
}

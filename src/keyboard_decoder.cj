package cjtui

import std.collection.ArrayList

// One state machine serves both the public byte adapter and the device loop.
public class KeyboardDecoder {
    private let limits: KeyboardLimits
    private var closed = false
    private var offset: Int64 = 0
    private var start: Int64 = 0
    private var state: Int64 = 0 // normal, escape, CSI, SS3, string, string-escape, paste
    private var sequence = ArrayList<UInt8>()
    private var paste = ArrayList<UInt8>()
    private var endPrefix = ArrayList<UInt8>()
    private var drained = false
    private var malformed = false
    private var intermediate = false
    private var osc = false
    private var stringRemaining: Int32 = 0
    private var stringC2 = false
    private var utfRemaining: Int32 = 0
    private var utfCode: UInt32 = 0
    private var utfMin: UInt32 = 0
    private var utfStart: Int64 = 0
    private var utfAlt = false
    private var c1Csi = false
    private var c1PrefixBytes: Int64 = 1
    private var keys = ArrayList<KeyEvent>()
    private var issues = ArrayList<KeyboardDiagnostic>()
    var onEvent: ?(KeyEvent) -> Unit = None
    var onIssue: ?(KeyboardDiagnostic) -> Unit = None
    var onPasteStart: ?() -> Unit = None
    var caretProbe: ?CaretProbe = None

    public init(limits!: KeyboardLimits = KeyboardLimits()) { this.limits = limits }
    private func checkOpen(): Unit { if (closed) { throw KeyboardException("DecoderClosed", "decoder closed") } }
    private func event(key: KeyEvent): Unit {
        keys.add(key)
        if (let Some(callback) <- onEvent) { callback(key) }
    }
    private func issue(kind: KeyboardIssue, at: Int64): Unit {
        let diagnostic = KeyboardDiagnostic(kind, at); issues.add(diagnostic)
        if (let Some(callback) <- onIssue) { callback(diagnostic) }
    }
    private func batch(): KeyboardBatch {
        let result = KeyboardBatch(keys.toArray(), issues.toArray())
        keys.clear(); issues.clear(); result
    }
    public func feed(chunk: Array<UInt8>): KeyboardBatch {
        checkOpen()
        for (byte in chunk) {
            if (offset == Int64.Max) { closed = true; throw KeyboardException("InputTooLarge", "input offset overflow") }
            let at = offset; offset++; consume(Int32(byte), at)
        }
        batch()
    }
    public func timeout(): KeyboardBatch {
        checkOpen()
        if (state == 1 && utfRemaining == 0) { state = 0; event(KeyEvent("escape")) }
        else if ((state == 1 || state == 2 || state == 3) && !drained) {
            state = 0; utfRemaining = 0; issue(KeyboardIssue.IncompleteInput, start)
        }
        batch()
    }
    public func finish(): KeyboardBatch {
        checkOpen(); closed = true
        if (state == 6) { issue(KeyboardIssue.IncompletePaste, start) }
        else if (state != 0 || utfRemaining > 0) {
            issue(KeyboardIssue.IncompleteInput, if (state != 0) { start } else { utfStart })
        }
        state = 0; utfRemaining = 0; batch()
    }
    func waitingIdle(): Bool { state == 1 || ((state == 2 || state == 3) && !drained) }
    func pasteOffset(): Int64 { start }
    private func beginSequence(at: Int64): Unit {
        state = 1; start = at; sequence.clear(); sequence.add(27)
        drained = false; malformed = false; intermediate = false; c1Csi = false
    }
    private func appendSequence(byte: Int32): Unit {
        if (!drained) {
            sequence.add(UInt8(byte))
            let pasteMarker: Array<UInt8> = [27, 91, 50, 48, 48, 126]
            var pasteCandidate = sequence.size <= pasteMarker.size
            if (pasteCandidate) {
                for (i in 0..sequence.size) {
                    if (sequence[i] != pasteMarker[i]) { pasteCandidate = false; break }
                }
            }
            if (sequence.size > limits.maxSequenceBytes && !pasteCandidate) {
                drained = true; issue(KeyboardIssue.SequenceTooLong, start); sequence.clear()
            }
        }
    }
    private func beginString(at: Int64, isOsc: Bool): Unit {
        start = at; state = 4; osc = isOsc; stringRemaining = 0; stringC2 = false
        issue(KeyboardIssue.UnsupportedSequence, at)
    }
    private func c1(code: UInt32, at: Int64, encoded!: Bool = false): Unit {
        if (code == 0x9b) {
            state = 2; start = at; sequence.clear()
            if (encoded) { sequence.add(0xc2) }
            sequence.add(0x9b); c1PrefixBytes = if (encoded) { 2 } else { 1 }
            c1Csi = true; drained = false; malformed = false; intermediate = false
            if (sequence.size > limits.maxSequenceBytes) {
                drained = true; issue(KeyboardIssue.SequenceTooLong, start); sequence.clear()
            }
        } else if (code == 0x90 || code == 0x98 || code == 0x9d || code == 0x9e || code == 0x9f) {
            beginString(at, code == 0x9d)
        } else { state = 0; issue(KeyboardIssue.UnsupportedSequence, at) }
    }
    private func scalar(code: UInt32, at: Int64, alt: Bool): Unit {
        if (code >= 128 && code < 160) { c1(code, at, encoded: true); return }
        state = 0; event(KeyEvent("text", text: String(Rune(code)), alt: alt))
    }
    private func consume(byte: Int32, at: Int64): Unit {
        if (state == 6) { pasteByte(byte); return }
        if (byte == 3) {
            state = 0; utfRemaining = 0; event(KeyEvent("interrupt", ctrl: true)); return
        }
        if (state == 4 || state == 5) { stringByte(byte); return }
        if (utfRemaining > 0) {
            if (byte >= 128 && byte <= 191) {
                utfCode = (utfCode << 6) | UInt32(byte & 63); utfRemaining--
                if (utfRemaining == 0) {
                    if (utfCode < utfMin || utfCode > 0x10ffff || (utfCode >= 0xd800 && utfCode <= 0xdfff)) {
                        issue(KeyboardIssue.InvalidUtf8, utfStart); state = 0
                    } else { scalar(utfCode, utfStart, utfAlt) }
                }
                return
            }
            utfRemaining = 0; issue(KeyboardIssue.InvalidUtf8, utfStart); state = 0
            consume(byte, at); return
        }
        if (byte == 27) { beginSequence(at); return }
        if (state == 1) {
            if (byte == 91 || byte == 79) {
                state = if (byte == 91) { 2 } else { 3 }; appendSequence(byte); return
            }
            if (byte == 93 || byte == 80 || byte == 88 || byte == 94 || byte == 95) {
                beginString(start, byte == 93); return
            }
            if (byte >= 32 && byte < 127) { scalar(UInt32(byte), at, true); return }
            if (byte >= 194 && byte <= 244) { beginUtf(byte, at, true); return }
            issue(KeyboardIssue.UnsupportedSequence, start); state = 0; return
        }
        if (state == 2 || state == 3) {
            if (byte >= 128 && byte <= 159) { c1(UInt32(byte), at); return }
            if (byte == 194) { beginUtf(byte, at, false); return }
            appendSequence(byte)
            if (state == 2 && sequence.size == 3 && byte == 91 && !drained) { return }
            if (byte >= 64 && byte <= 126) {
                if (!drained && !malformed) { completeSequence() }
                state = if (state == 6) { 6 } else { 0 }; return
            }
            if (byte >= 32 && byte <= 47) { intermediate = true }
            else if (byte >= 48 && byte <= 63) {
                if (intermediate && !malformed && !drained) { malformed = true; issue(KeyboardIssue.MalformedSequence, start) }
            } else if (!malformed && !drained) { malformed = true; issue(KeyboardIssue.MalformedSequence, start) }
            return
        }
        if (byte == 9) { event(KeyEvent("tab")); return }
        if (byte == 10 || byte == 13) { event(KeyEvent("enter")); return }
        if (byte == 8 || byte == 127) { event(KeyEvent("backspace")); return }
        if (byte >= 1 && byte <= 26) { event(KeyEvent(String(Rune(UInt32(96 + byte))), ctrl: true)); return }
        if (byte < 32) { issue(KeyboardIssue.UnsupportedSequence, at); return }
        if (byte < 128) { scalar(UInt32(byte), at, false); return }
        if (byte >= 194 && byte <= 244) { beginUtf(byte, at, false); return }
        if (byte >= 128 && byte <= 159) { c1(UInt32(byte), at); return }
        issue(KeyboardIssue.InvalidUtf8, at)
    }
    private func beginUtf(byte: Int32, at: Int64, alt: Bool): Unit {
        utfStart = if (alt) { start } else { at }; utfAlt = alt
        if (byte <= 223) { utfRemaining = 1; utfCode = UInt32(byte & 31); utfMin = 128 }
        else if (byte <= 239) { utfRemaining = 2; utfCode = UInt32(byte & 15); utfMin = 2048 }
        else { utfRemaining = 3; utfCode = UInt32(byte & 7); utfMin = 65536 }
    }
    private func completeSequence(): Unit {
        let raw = sequence.toArray()
        let text = try { String.fromUtf8(raw) } catch (_: IllegalArgumentException) { "" }
        if (!c1Csi && text == "\u{1b}[200~") {
            state = 6; paste.clear(); endPrefix.clear(); drained = false
            if (let Some(callback) <- onPasteStart) { callback() }
            return
        }
        if (let Some(probe) <- caretProbe) {
            for (digit in 0..5) {
                if (text == "\u{1b}[?25;${digit}$y") { probe.report(Int32(digit)); return }
            }
        }
        var body = text
        if (c1Csi) {
            if (raw.size > c1PrefixBytes) { body = String.fromUtf8(raw.slice(c1PrefixBytes, raw.size - c1PrefixBytes)) }
        } else if (text.startsWith("\u{1b}[")) {
            body = String.fromUtf8(raw.slice(2, raw.size - 2))
        } else if (text.startsWith("\u{1b}O")) {
            body = String.fromUtf8(raw.slice(2, raw.size - 2))
        }
        let ss3 = !c1Csi && text.startsWith("\u{1b}O")
        for ((suffix, name) in [("A", "up"), ("B", "down"), ("C", "right"), ("D", "left"), ("H", "home"), ("F", "end")]) {
            if (body == suffix) { event(KeyEvent(name)); return }
            if (!ss3) {
                for (m in 1..9) {
                    if (body == "1;${m}${suffix}") {
                        let bits = m - 1; event(KeyEvent(name, ctrl: (bits & 4) != 0, alt: (bits & 2) != 0, shift: (bits & 1) != 0)); return
                    }
                }
            }
        }
        if (!ss3 && body == "Z") { event(KeyEvent("backtab", shift: true)); return }
        for ((number, name) in [("1", "home"), ("7", "home"), ("4", "end"), ("8", "end"),
            ("2", "insert"), ("3", "delete"), ("5", "pageup"), ("6", "pagedown"),
            ("11", "f1"), ("12", "f2"), ("13", "f3"), ("14", "f4"), ("15", "f5"),
            ("17", "f6"), ("18", "f7"), ("19", "f8"), ("20", "f9"), ("21", "f10"), ("23", "f11"), ("24", "f12")]) {
            if (!ss3 && body == "${number}~") { event(KeyEvent(name)); return }
            if (number == "1" || number == "7" || number == "4" || number == "8" || number == "2" || number == "3" || number == "5" || number == "6") {
                for (m in 1..9) {
                    if (!ss3 && body == "${number};${m}~") {
                        let bits = m - 1; event(KeyEvent(name, ctrl: (bits & 4) != 0, alt: (bits & 2) != 0, shift: (bits & 1) != 0)); return
                    }
                }
            }
        }
        for ((letter, name) in [("P", "f1"), ("Q", "f2"), ("R", "f3"), ("S", "f4")]) {
            if (ss3 && body == letter) { event(KeyEvent(name)); return }
        }
        for ((letter, name) in [("[A", "f1"), ("[B", "f2"), ("[C", "f3"), ("[D", "f4"), ("[E", "f5")]) {
            if (!ss3 && body == letter) { event(KeyEvent(name)); return }
        }
        issue(KeyboardIssue.UnsupportedSequence, start)
    }
    private func stringByte(byte: Int32): Unit {
        if (state == 5) {
            if (byte == 92 || (osc && byte == 7)) { state = 0; return }
            if (byte != 27) { state = 4 }
            return
        }
        if (stringRemaining > 0 && byte >= 128 && byte <= 191) {
            if (stringC2 && byte == 0x9c) { state = 0 }
            stringRemaining--; stringC2 = false; return
        }
        stringRemaining = 0; stringC2 = false
        if (byte == 27) { state = 5 }
        else if (byte == 0x9c || (osc && byte == 7)) { state = 0 }
        else if (byte >= 194 && byte <= 223) { stringRemaining = 1; stringC2 = byte == 194 }
        else if (byte >= 224 && byte <= 239) { stringRemaining = 2 }
        else if (byte >= 240 && byte <= 244) { stringRemaining = 3 }
    }
    private func appendPaste(byte: UInt8): Unit {
        if (drained) { return }
        if (paste.size >= limits.maxPasteBytes) {
            drained = true; paste.clear(); issue(KeyboardIssue.PasteTooLarge, start); return
        }
        paste.add(byte)
    }
    private func pasteByte(byte: Int32): Unit {
        let marker: Array<UInt8> = [27, 91, 50, 48, 49, 126]
        endPrefix.add(UInt8(byte))
        while (!endPrefix.isEmpty()) {
            var matches = true
            for (i in 0..endPrefix.size) { if (endPrefix[i] != marker[i]) { matches = false; break } }
            if (matches) { break }
            appendPaste(endPrefix.remove(at: 0))
        }
        if (endPrefix.size == marker.size) {
            endPrefix.clear(); state = 0
            if (!drained) {
                let text: ?String = try { Some(String.fromUtf8(paste.toArray())) }
                    catch (_: IllegalArgumentException) { Option<String>.None }
                if (let Some(value) <- text) { event(KeyEvent("paste", text: value)) }
                else { issue(KeyboardIssue.InvalidPasteEncoding, start) }
            }
            paste.clear()
        }
    }
}

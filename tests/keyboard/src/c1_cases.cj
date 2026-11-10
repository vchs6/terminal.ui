package keyboard_contract
import cjtui.*

// Breaks caught: treating continuation bytes as C1/ST, accepting C1 paste,
// leaking a quarantined string after timeout, interpreting 03 in paste.
func c1Cases(): Unit {
    for (byte in [0x80, 0x81, 0x82, 0x83, 0x84, 0x85, 0x86, 0x87, 0x88, 0x89, 0x8a, 0x8b,
        0x8c, 0x8d, 0x8e, 0x8f, 0x91, 0x92, 0x93, 0x94, 0x95, 0x96, 0x97, 0x99, 0x9a, 0x9c]) {
        for (intro in [[UInt8(byte)], [UInt8(0xc2), UInt8(byte)]]) {
            let bytes = joined([[65], intro, [66]])
            allSplits(GoldenCase("unsupported C1 ${byte}", bytes,
                [KeyEvent("text", text: "A"), KeyEvent("text", text: "B")],
                issues: [ExpectedIssue(KeyboardIssue.UnsupportedSequence, 1)]))
        }
    }
    for (intro in [[UInt8(0x9b)], [UInt8(0xc2), UInt8(0x9b)]]) {
        allSplits(GoldenCase("C1 CSI navigation", joined([[65], intro, [65, 66]]),
            [KeyEvent("text", text: "A"), KeyEvent("up"), KeyEvent("text", text: "B")]))
        allSplits(GoldenCase("C1 CSI is not bracket paste", joined([[65], intro, "200~x".toArray()]),
            [KeyEvent("text", text: "A"), KeyEvent("text", text: "x")],
            issues: [ExpectedIssue(KeyboardIssue.UnsupportedSequence, 1)]))
    }
    for (intro in [[UInt8(0x90)], [UInt8(0x98)], [UInt8(0x9d)], [UInt8(0x9e)], [UInt8(0x9f)],
        [UInt8(0xc2), UInt8(0x90)], [UInt8(0xc2), UInt8(0x98)], [UInt8(0xc2), UInt8(0x9d)],
        [UInt8(0xc2), UInt8(0x9e)], [UInt8(0xc2), UInt8(0x9f)],
        "\u{1b}P".toArray(), "\u{1b}X".toArray(), "\u{1b}]".toArray(), "\u{1b}^".toArray(), "\u{1b}_".toArray()]) {
        for (end in ["\u{1b}\\".toArray(), [UInt8(0x9c)], [UInt8(0xc2), UInt8(0x9c)]]) {
            // Ü contains 9C as a continuation; it MUST NOT terminate the string.
            let bytes = joined([[65], intro, "ÜLEAK\u{18}\u{1a}\u{1b}x".toArray(), end, [66]])
            allSplits(GoldenCase("control string quarantine", bytes,
                [KeyEvent("text", text: "A"), KeyEvent("text", text: "B")],
                issues: [ExpectedIssue(KeyboardIssue.UnsupportedSequence, 1)]))
        }
        allSplits(GoldenCase("03 cancels nonpaste string", joined([[65], intro, [120, 3, 66]]),
            [KeyEvent("text", text: "A"), KeyEvent("interrupt", ctrl: true), KeyEvent("text", text: "B")],
            issues: [ExpectedIssue(KeyboardIssue.UnsupportedSequence, 1)]))
    }
    allSplits(GoldenCase("OSC BEL terminates", "a\u{1b}]hidden\u{7}b".toArray(),
        [KeyEvent("text", text: "a"), KeyEvent("text", text: "b")],
        issues: [ExpectedIssue(KeyboardIssue.UnsupportedSequence, 1)]))
    allSplits(GoldenCase("DCS BEL does not terminate", "a\u{1b}P\u{7}hidden\u{1b}\\b".toArray(),
        [KeyEvent("text", text: "a"), KeyEvent("text", text: "b")],
        issues: [ExpectedIssue(KeyboardIssue.UnsupportedSequence, 1)]))
    allSplits(GoldenCase("new ESC cancels unfinished CSI", "\u{1b}[12\u{1b}[A".toArray(), [KeyEvent("up")]))
    allSplits(GoldenCase("03 cancels unfinished CSI", "\u{1b}[12\u{3}x".toArray(),
        [KeyEvent("interrupt", ctrl: true), KeyEvent("text", text: "x")]))
    allSplits(GoldenCase("C1 CSI cancels unfinished 7bit CSI", [27, 91, 49, 0x9b, 65], [KeyEvent("up")]))
}

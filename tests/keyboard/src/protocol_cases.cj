package keyboard_contract
import cjtui.*

// Breaks caught: lost final byte, guessed modifiers, wrong legacy spelling,
// CRLF coalescing, UTF8 split corruption, leaking unsupported sequence payload.
func protocolCases(): Unit {
    for ((bytes, code) in [
        ("\u{1b}[A", "up"), ("\u{1b}[B", "down"), ("\u{1b}[C", "right"), ("\u{1b}[D", "left"),
        ("\u{1b}OA", "up"), ("\u{1b}OB", "down"), ("\u{1b}OC", "right"), ("\u{1b}OD", "left"),
        ("\u{1b}[H", "home"), ("\u{1b}[F", "end"), ("\u{1b}OH", "home"), ("\u{1b}OF", "end"),
        ("\u{1b}[1~", "home"), ("\u{1b}[7~", "home"), ("\u{1b}[4~", "end"), ("\u{1b}[8~", "end"),
        ("\u{1b}[2~", "insert"), ("\u{1b}[3~", "delete"), ("\u{1b}[5~", "pageup"), ("\u{1b}[6~", "pagedown"),
        ("\u{1b}OP", "f1"), ("\u{1b}OQ", "f2"), ("\u{1b}OR", "f3"), ("\u{1b}OS", "f4"),
        ("\u{1b}[11~", "f1"), ("\u{1b}[12~", "f2"), ("\u{1b}[13~", "f3"), ("\u{1b}[14~", "f4"),
        ("\u{1b}[15~", "f5"), ("\u{1b}[17~", "f6"), ("\u{1b}[18~", "f7"), ("\u{1b}[19~", "f8"),
        ("\u{1b}[20~", "f9"), ("\u{1b}[21~", "f10"), ("\u{1b}[23~", "f11"), ("\u{1b}[24~", "f12"),
        ("\u{1b}[[A", "f1"), ("\u{1b}[[B", "f2"), ("\u{1b}[[C", "f3"), ("\u{1b}[[D", "f4"), ("\u{1b}[[E", "f5")
    ]) { asciiCase(code, bytes, KeyEvent(code)) }
    asciiCase("backtab", "\u{1b}[Z", KeyEvent("backtab", shift: true))
    // Literal modifier matrix; a wrong bit assignment fails these fields.
    for ((parameter, ctrl, alt, shift) in [
        ("1", false, false, false), ("2", false, false, true),
        ("3", false, true, false), ("4", false, true, true),
        ("5", true, false, false), ("6", true, false, true),
        ("7", true, true, false), ("8", true, true, true)
    ]) {
        for ((final, code) in [("A", "up"), ("B", "down"), ("C", "right"), ("D", "left"), ("H", "home"), ("F", "end")]) {
            asciiCase("modifier ${code}/${parameter}", "\u{1b}[1;${parameter}${final}",
                KeyEvent(code, ctrl: ctrl, alt: alt, shift: shift))
        }
        for ((number, code) in [("1", "home"), ("7", "home"), ("4", "end"), ("8", "end"),
            ("2", "insert"), ("3", "delete"), ("5", "pageup"), ("6", "pagedown")]) {
            asciiCase("tilde modifier ${code}/${parameter}", "\u{1b}[${number};${parameter}~",
                KeyEvent(code, ctrl: ctrl, alt: alt, shift: shift))
        }
    }
    allSplits(GoldenCase("CRLF is two enter", [13, 10, 8, 127, 9],
        [KeyEvent("enter"), KeyEvent("enter"), KeyEvent("backspace"), KeyEvent("backspace"), KeyEvent("tab")]))
    for ((byte, code) in [(1, "a"), (2, "b"), (3, "interrupt"), (4, "d"), (5, "e"), (6, "f"), (7, "g"),
        (11, "k"), (12, "l"), (14, "n"), (15, "o"), (16, "p"), (17, "q"), (18, "r"), (19, "s"),
        (20, "t"), (21, "u"), (22, "v"), (23, "w"), (24, "x"), (25, "y"), (26, "z")]) {
        allSplits(GoldenCase("C0 ${byte}", [UInt8(byte)], [KeyEvent(code, ctrl: true)]))
    }
    for (byte in [0, 28, 29, 30, 31]) {
        allSplits(GoldenCase("unsupported C0 ${byte}", [65, UInt8(byte), 66],
            [KeyEvent("text", text: "A"), KeyEvent("text", text: "B")],
            issues: [ExpectedIssue(KeyboardIssue.UnsupportedSequence, 1)]))
    }
    asciiCase("uppercase provides no physical Shift", "A", KeyEvent("text", text: "A"))
    asciiCase("UTF8 中", "中", KeyEvent("text", text: "中"))
    asciiCase("UTF8 continuation 9B", "Л", KeyEvent("text", text: "Л"))
    asciiCase("UTF8 continuation 9C", "Ü", KeyEvent("text", text: "Ü"))
    asciiCase("UTF8 4 byte", "😀", KeyEvent("text", text: "😀"))
    asciiCase("Alt ASCII", "\u{1b}x", KeyEvent("text", text: "x", alt: true))
    asciiCase("Alt UTF8", "\u{1b}中", KeyEvent("text", text: "中", alt: true))
    for (sequence in ["\u{1b}[99~", "\u{1b}[1;9A", "\u{1b}[2;2A", "\u{1b}[97u", "\u{1b}OT"]) {
        allSplits(GoldenCase("unknown framed sequence", ("a" + sequence + "b").toArray(),
            [KeyEvent("text", text: "a"), KeyEvent("text", text: "b")],
            issues: [ExpectedIssue(KeyboardIssue.UnsupportedSequence, 1)]))
    }
    allSplits(GoldenCase("illegal parameter after intermediate", "a\u{1b}[ 1Ab".toArray(),
        [KeyEvent("text", text: "a"), KeyEvent("text", text: "b")],
        issues: [ExpectedIssue(KeyboardIssue.MalformedSequence, 1)]))
    allSplits(GoldenCase("bad UTF8 prefix retries current ASCII", [65, 0xe2, 66],
        [KeyEvent("text", text: "A"), KeyEvent("text", text: "B")],
        issues: [ExpectedIssue(KeyboardIssue.InvalidUtf8, 1)]))
}

package slice_contract
import cjtui.*
func check(value: Bool, name: String): Unit {
    if (!value) { throw Exception("FAIL: ${name}") }
    println("PASS: ${name}")
}
func illegal(action: () -> Unit, name: String): Unit {
    var rejected = false
    try { action() } catch (_: IllegalArgumentException) { rejected = true }
    check(rejected, name)
}
func rejected(action: () -> Unit, name: String): Unit {
    var failed = false
    try { action() } catch (_: Exception) { failed = true }
    check(failed, name)
}
func blank(f: Frame, x: Int64, y: Int64): Bool {
    let c = f.cellAt(x, y)
    return c.grapheme == " " && c.width == 1 && !c.continuation
}
func frozenCondition(): Bool { true }
func custom(value: String): Unit { Text(value).foreground(Color.Green) }
func frameCases(): Unit {
    illegal({ => Frame(-1, 1); () }, "negative width")
    illegal({ => Frame(1, -1); () }, "negative height")
    for (f in [Frame(0, 0), Frame(0, 2), Frame(2, 0)]) {
        f.put(0, 0, "中")
        check(f.toAnsi() == "", "zero area ANSI")
        illegal({ => f.cellAt(0, 0); () }, "zero area cellAt")
    }
    let f = Frame(8, 2)
    check(f.width == 8 && f.height == 2, "frame dimensions")
    illegal({ => f.cellAt(-1, 0); () }, "negative cellAt")
    illegal({ => f.cellAt(8, 0); () }, "right cellAt")
    illegal({ => f.cellAt(0, 2); () }, "bottom cellAt")
    f.put(0, 0, "e\u{301}中👩‍💻🇨🇳")
    check(f.cellAt(0, 0).grapheme == "e\u{301}" && f.cellAt(0, 0).width == 1, "combining cell")
    for (x in [1, 3, 5]) {
        check(f.cellAt(x, 0).width == 2 && !f.cellAt(x, 0).continuation, "wide leading cell")
        check(f.cellAt(x + 1, 0).width == 0 && f.cellAt(x + 1, 0).continuation, "wide continuation")
    }
    check(f.toPlainText() == "e\u{301}中👩‍💻🇨🇳 \n        ", "full columns plain snapshot")
    f.put(2, 0, "x")
    check(blank(f, 1, 0) && f.cellAt(2, 0).grapheme == "x", "overwrite continuation clears old cluster")
    f.put(3, 0, "y")
    check(blank(f, 4, 0), "overwrite leading clears continuation")
    let clip = Frame(3, 1)
    clip.put(2, 0, "中")
    check(clip.toPlainText() == "   ", "right clipped wide omitted")
    clip.put(-1, 0, "中X")
    check(clip.toPlainText() == " X ", "left clipped wide omitted but following text positioned")
    clip.put(2, 0, "x")
    clip.put(1, 0, "中")
    check(clip.cellAt(2, 0).continuation, "wide write covers old narrow")
    clip.put(100, 100, "x")
    clip.put(0, -1, "x")
    let zero = Frame(2, 1)
    zero.put(0, 0, "\u{301}")
    zero.put(0, 0, "")
    check(zero.toPlainText() == "  ", "standalone zero width and empty ignored")
    let lines = Frame(4, 3)
    lines.put(1, 0, "a\r\nb\nc")
    check(lines.toPlainText() == " a  \n b  \n c  ", "LF and CRLF restore original x")
    let narrow = Frame(2, 1)
    narrow.put(0, 0, "·")
    let wide = Frame(2, 1, ambiguousWide: true)
    wide.put(0, 0, "·")
    check(narrow.cellAt(0, 0).width == 1 && wide.cellAt(0, 0).width == 2, "frame ambiguous policy")
}
func controlCases(): Unit {
    for (n in 0..32) {
        if (n != 10 && n != 13) {
            let text = String(Rune(UInt32(n)))
            rejected({ => Frame(4, 1).put(0, 0, text) }, "reject C0 ${n}")
        }
    }
    for (n in 128..160) {
        let text = String(Rune(UInt32(n)))
        rejected({ => Frame(4, 1).put(0, 0, text) }, "reject C1 ${n}")
    }
    rejected({ => Frame(4, 1).put(0, 0, "\r") }, "reject lone CR")
    rejected({ => Frame(8, 1).put(0, 0, "\u{1b}[2J") }, "reject CSI injection")
    rejected({ => Frame(8, 1).put(0, 0, "\u{1b}]52;c;dGVzdA==\u{7}") }, "reject OSC injection")
    rejected({ => render(Text("\u{1b}[2J"), 8, 1); () }, "component text cannot inject")
}
func styleCases(): Unit {
    let s = Style(foreground: Color.Red, background: Color.Blue, bold: true)
    check(s.foreground == Color.Red && s.background == Color.Blue && s.bold, "style fields")
    let f = Frame(2, 1)
    f.put(0, 0, "x")
    let before = f.toAnsi()
    f.put(0, 0, "x", style: s)
    check(f.cellAt(0, 0).style == s && f.cellAt(0, 0).style == Style(foreground: Color.Red, background: Color.Blue, bold: true), "style value equality")
    check(f.toPlainText() == "x " && f.toAnsi() != before, "style only update changes ANSI")
    let snap = Frame(2, 2)
    snap.put(0, 0, "a")
    snap.put(1, 1, "b")
    let ansi = snap.toAnsi()
    check(ansi.startsWith("\u{1b}[0m\u{1b}[1;1H"), "ANSI reset and absolute initial position")
    check(ansi.contains("\u{1b}[2;1H") && ansi.endsWith("\u{1b}[0m"), "ANSI row positioning and final reset")
    check(!ansi.contains("\n") && !ansi.contains("\r"), "ANSI snapshot never scrolls with newline")
    check(snap.toPlainText() == "a \n b" && !snap.toPlainText().contains("\u{1b}"), "plain retains spaces no final LF or ESC")
}
func componentCases(): Unit {
    let root = Column {
        Row { Text("A").foreground(Color.Red); Text("中") }
        if (frozenCondition()) { Text("B") } else { Text("wrong") }
        for (value in ["C", "D"]) { custom(value) }
    }.foreground(Color.Cyan).background(Color.Blue).bold()
    let f = render(root, 4, 4)
    check(f.toPlainText() == "A中 \nB   \nC   \nD   ", "blocks if for custom function and layout")
    check(f.cellAt(0, 0).style.foreground == Color.Red && f.cellAt(1, 0).style.foreground == Color.Cyan, "explicit child overrides inherited color")
    check(f.cellAt(1, 0).style.bold && f.cellAt(1, 0).style.background == Color.Blue, "ancestor style inheritance")
    check(render(Text("X\nY"), 2, 2).toPlainText() == "X \nY ", "standalone multiline Text root")
    check(render(Row { Text("中"); Text("X") }, 1, 1).toPlainText() == " ", "actual size clips ancestor wide glyph")
    var caught = false
    try {
        Column { Text("discard"); Row { Text("discard"); throw Exception("construction abort") } }
    } catch (_: Exception) { caught = true }
    check(caught, "construction exception propagated")
    let fresh = Column { Text("clean"); Row { Text("Z") } }
    check(render(fresh, 5, 2).toPlainText() == "clean\nZ    ", "construction context clean after nested exception")
    check(render(Text("solo"), 4, 1).toPlainText() == "solo", "standalone root clean after exception")
}
main(): Int64 {
    frameCases()
    controlCases()
    styleCases()
    componentCases()
    return 0
}

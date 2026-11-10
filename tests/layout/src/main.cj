package layout_contract
import cjtui.*
func check(value: Bool, name: String): Unit {
    if (!value) { throw Exception("FAIL: ${name}") }
    println("PASS: ${name}")
}
func plain(root: Component, width: Int64, height: Int64, expected: String, name: String): Unit {
    let frame = render(root, width, height)
    check(frame.width == width && frame.height == height, "actual viewport: ${name}")
    check(frame.toPlainText() == expected, "${name}: got [${frame.toPlainText()}], want [${expected}]")
}
func illegal(action: () -> Unit, name: String): Unit {
    var caught = false
    try { action() } catch (_: IllegalArgumentException) { caught = true }
    check(caught, name)
}
func rejected(action: () -> Unit, name: String): Unit {
    var caught = false
    try { action() } catch (_: Exception) { caught = true }
    check(caught, name)
}
func geometry(): Unit {
    let r = Rect(-2, -3, 4, 5)
    check(r.x == -2 && r.y == -3 && r.width == 4 && r.height == 5, "Rect preserves signed origin and nonnegative extents")
    let extreme = Rect(Int64.Min, Int64.Max, Int64.Max, 0)
    check(extreme.width == Int64.Max && extreme.height == 0, "Rect permits extrema and empty geometry")
    illegal({ => Rect(0, 0, -1, 1); () }, "Rect negative width rejected")
    illegal({ => Rect(0, 0, 1, -1); () }, "Rect negative height rejected")
    plain(Text("abcdef").width(3).height(1), 6, 2, "abc   \n      ", "fixed root uses outer size")
    plain(Text("abcdef").width(0), 6, 1, "      ", "explicit zero is not auto")
    plain(Text("abcdef").height(0), 6, 2, "      \n      ", "zero height draws nothing")
    plain(Text("abcdef").width(1).widthAuto(), 6, 1, "abcdef", "widthAuto clears fixed root")
    plain(Text("A\nB").height(0).heightAuto(), 2, 2, "A \nB ", "heightAuto clears fixed root")
    plain(Text("ABCDE").minWidth(100).minHeight(100), 3, 1, "ABC", "root min cannot enlarge actual viewport")
    plain(Row { Text("A").minWidth(3); Text("B") }, 6, 1, "A  B  ", "nonflex minimum reserves outer space")
    plain(Row { Text("ABCDE").width(2).minWidth(4); Text("Z") }, 6, 1, "ABCDZ ", "minimum can exceed fixed request")
    plain(Row { Text("ABCDE").width(Int64.Max); Text("Z") }, 3, 1, "ABC", "extreme fixed child converges to ancestor")
    plain(Row { Text("AB").width(2); Text("CD").width(2); Text("Z") }, 3, 1, "ABC", "nonflex overflow preserves order and clips suffix")
}
func proportion(): Unit {
    plain(Row { Text("AAAAAA").layoutWeight(1); Text("BBBBBB").layoutWeight(1); Text("CCCCCC").layoutWeight(1) }, 8, 1, "AAABBBCC", "equal remainders resolve in declaration order")
    plain(Row { Text("AAAAAAAA").layoutWeight(1); Text("BBBBBBBB").layoutWeight(2); Text("CCCCCCCC").layoutWeight(3) }, 8, 1, "ABBBCCCC", "largest remainder wins over earlier child")
    plain(Row { Text("AAAAAAAA").layoutWeight(1); Text("BBBBBBBB").layoutWeight(2); Text("CCCCCCCC").layoutWeight(3) }, 10, 1, "AABBBCCCCC", "non-tied exact ratio rounding")
    plain(Row { Text("AA").width(2); Text("BBBBBBBB").layoutWeight(1); Text("CCCCCCCC").layoutWeight(2) }.gap(1), 10, 1, "AA BB CCCC", "fixed and gaps deducted before flex")
    plain(Row { Text("AAAAAAAAAA").minWidth(3).layoutWeight(1); Text("BBBBBBBBBB").minWidth(1).layoutWeight(1) }, 10, 1, "AAAAAABBBB", "flex minimum precedes weight remainder")
    plain(Row { Text("AAAAAAAAAA").minWidth(8).layoutWeight(1); Text("BBBBBBBBBB").minWidth(4).layoutWeight(100) }, 6, 1, "AAAABB", "infeasible minima use clamped minimum ratio rather than weights")
    plain(Row { Text("AAAAAA").width(1).layoutWeight(1); Text("BBBBBB").width(5).layoutWeight(1) }, 6, 1, "AAABBB", "positive weights replace fixed and natural main size")
    plain(Row { Text("AA").layoutWeight(0); Text("BBBBBB").layoutWeight(1) }, 6, 1, "AABBBB", "zero weight remains nonflex")
    plain(Column { Text("A\nA\nA\nA\nA").layoutWeight(1); Text("B\nB\nB\nB\nB").layoutWeight(1) }, 1, 5, "A\nA\nA\nB\nB", "column uses same largest remainder allocation")
    plain(Row { Text("AAAAAAAA").layoutWeight(Int64.Max / 2); Text("BBBBBBBB").layoutWeight(Int64.Max / 2) }, 7, 1, "AAAABBB", "integer multiply-divide survives product overflow")
    plain(Row { Text("AAA").layoutWeight(Int64.Max / 2 - 1); Text("BBB").layoutWeight(Int64.Max / 2) }, 3, 1, "ABB", "near-equal extreme remainders remain exact beyond float precision")
    plain(Row { Text("AAAAAAAA").layoutWeight(Int64.Max - 1); Text("BBBBBBBB").layoutWeight(1) }, 7, 1, "AAAAAAA", "extreme skew preserves exact remainder")
    plain(Row { Text("AAAAAAAAA").minWidth(Int64.Max).layoutWeight(1); Text("BBBBBBBBB").minWidth(Int64.Max).layoutWeight(1) }, 9, 1, "AAAAABBBB", "minimum clamp precedes safe sum")
    rejected({ => render(Row { Text("A").layoutWeight(Int64.Max); Text("B").layoutWeight(1) }, 5, 1); () }, "unrepresentable weight sum diagnosed")
    plain(Row { Text("A").width(Int64.Max); Text("B").layoutWeight(1) }.gap(Int64.Max), 3, 1, "A  ", "extreme occupied extent saturates without wrapping")
}
func paddingAndAlignment(): Unit {
    plain(Text("ABCDE\nFGHIJ").padding(1), 7, 4, "       \n ABCDE \n FGHIJ \n       ", "padding applies to text and consumes outer box")
    plain(Column { Text("A"); Text("B") }.padding(1), 4, 4, "    \n A  \n B  \n    ", "container padding does not inherit into child")
    plain(Text("X").padding(1), 1, 1, " ", "insets consume left top first at tiny viewport")
    plain(Text("X").padding(Int64.Max), 3, 2, "   \n   ", "extreme padding is bounded")
    plain(Row { Text("A"); Text("B") }.gap(2), 8, 1, "A  B    ", "gap has no leading or trailing allocation")
    plain(Row { Text("A"); Text("B") }.justifyContent(Alignment.Center), 7, 1, "  AB   ", "main center floors odd free space")
    plain(Row { Text("A"); Text("B") }.justifyContent(Alignment.End), 7, 1, "     AB", "main end consumes remaining space")
    plain(Column { Text("A"); Text("B") }.justifyContent(Alignment.End), 1, 4, " \n \nA\nB", "column main alignment")
    plain(Row { Text("A") }.alignItems(Alignment.Center), 3, 4, "   \nA  \n   \n   ", "cross center floors odd remaining space")
    plain(Row { Text("A") }.alignItems(Alignment.End), 3, 3, "   \n   \nA  ", "cross end aligns bottom")
    plain(Column { Text("A").textAlign(Alignment.End); Text("B").width(2).textAlign(Alignment.End) }.alignItems(Alignment.Stretch), 6, 2, "     A\n B    ", "stretch affects only auto cross sizes")
    plain(Text("A\nBCD").textAlign(Alignment.Center), 6, 2, "  A   \n BCD  ", "text aligns every line separately")
    plain(Text("A\r\nBCD").textAlign(Alignment.End), 6, 2, "     A\n   BCD", "text end handles CRLF")
    plain(Text("ABCDE").textAlign(Alignment.End), 3, 1, "ABC", "overlong end-aligned text clips from original start")
    plain(Row { Text("中X").width(1); Text("Z") }, 3, 1, " Z ", "child clipping keeps wide cluster whole")
    plain(Column { Row { Text("ABC").width(3); Text("Z") }.width(2); Text("Q") }, 4, 2, "AB  \nQ   ", "nested ancestor content clips descendants")
    plain(Text("X"), 0, 2, "\n", "zero-width viewport shape")
    plain(Text("X"), 2, 0, "", "zero-height viewport shape")
}
func validation(): Unit {
    let c = Text("ABCDE").width(3).height(1).minWidth(2).minHeight(1).layoutWeight(0).padding(0).textAlign(Alignment.End)
    illegal({ => c.width(-1); () }, "negative width setter immediate")
    illegal({ => c.height(-1); () }, "negative height setter immediate")
    illegal({ => c.minWidth(-1); () }, "negative minWidth immediate")
    illegal({ => c.minHeight(-1); () }, "negative minHeight immediate")
    illegal({ => c.layoutWeight(-1); () }, "negative weight immediate")
    illegal({ => c.padding(-1); () }, "negative padding immediate")
    illegal({ => c.textAlign(Alignment.Stretch); () }, "stretch text alignment immediate")
    illegal({ => c.gap(1); () }, "gap on Text immediate")
    illegal({ => c.alignItems(Alignment.Start); () }, "alignItems on Text immediate")
    illegal({ => c.justifyContent(Alignment.Start); () }, "justifyContent on Text immediate")
    plain(c, 5, 2, "ABC  \n     ", "rejected setters retain all old settings and chain mutates original")
    let row = Row { Text("A"); Text("B") }.gap(1).justifyContent(Alignment.End)
    illegal({ => row.gap(-1); () }, "negative gap immediate")
    illegal({ => row.justifyContent(Alignment.Stretch); () }, "stretch justification immediate")
    illegal({ => row.textAlign(Alignment.Start); () }, "textAlign on container immediate")
    plain(row, 6, 1, "   A B", "container retains settings after rejected calls")
    for (text in ["\u{1b}[2J", "\u{0}", "\u{85}", "\r"]) {
        rejected({ => render(Text(text).width(0).height(0), 0, 0); () }, "zero-size text still validates controls")
        rejected({ => render(Row { Text("X").width(2); Text(text) }, 1, 1); () }, "fully clipped text still validates controls")
    }
}
main(): Int64 {
    geometry()
    proportion()
    paddingAndAlignment()
    validation()
    return 0
}

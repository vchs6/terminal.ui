package composition_contract

import cjtui.*

func check(value: Bool, name: String): Unit {
    if (!value) { throw Exception("FAIL: ${name}") }
    println("PASS: ${name}")
}

func snapshot(frame: Frame, expected: String, name: String): Unit {
    check(frame.toPlainText() == expected, "${name}: got [${frame.toPlainText()}], want [${expected}]")
}

func emptyCell(frame: Frame, x: Int64, y: Int64, transparent: Bool): Bool {
    let cell = frame.cellAt(x, y)
    cell.grapheme == " " && cell.width == 1 && !cell.continuation &&
        cell.style == Style() && cell.isTransparent == transparent
}

func transparencyAndOrder(): Unit {
    let base = Frame(4, 2)
    base.put(0, 0, "abcd\nefgh")
    let layer = Frame(4, 2, transparent: true)
    check(emptyCell(layer, 0, 0, true), "transparent construction normalizes blank metadata")
    check(emptyCell(Frame(1, 1), 0, 0, false), "ordinary construction remains opaque")
    layer.put(1, 0, "X")
    let style = Style(background: Color.Blue)
    layer.put(2, 1, " ", style: style)
    base.composite(layer)
    snapshot(base, "aXcd\nef h", "transparent blanks skip; opaque styled blank covers")
    check(base.cellAt(2, 1).style == style && !base.cellAt(2, 1).isTransparent,
        "styled blank retains opacity and background")
    snapshot(layer, " X  \n    ", "different source stays unchanged")
    check(layer.cellAt(2, 1).style == style && layer.cellAt(0, 0).isTransparent,
        "source metadata unchanged")
    let upper = Frame(1, 1, transparent: true)
    upper.put(0, 0, "Y")
    base.composite(upper, x: 1)
    snapshot(base, "aYcd\nef h", "later layers appear above earlier layers")
    layer.put(0, 0, " ")
    check(emptyCell(layer, 0, 0, false), "Style default space is explicitly opaque")
    base.composite(layer)
    snapshot(base, " Xcd\nef h", "opaque default space is not guessed transparent")
}

func clustersAndClear(): Unit {
    let style = Style(foreground: Color.Red, background: Color.Blue, bold: true)
    let source = Frame(5, 1)
    source.put(0, 0, "a中bc", style: style)
    let leftCut = source.copy(Rect(2, 0, 3, 1))
    snapshot(leftCut, " bc", "copy cuts source continuation into a styled blank")
    check(!leftCut.cellAt(0, 0).continuation && leftCut.cellAt(0, 0).width == 1 &&
        leftCut.cellAt(0, 0).style == style && !leftCut.cellAt(0, 0).isTransparent,
        "clipped source fragment keeps exact style and opacity")
    let rightCut = source.resized(2, 1)
    snapshot(rightCut, "a ", "resize cuts source leader into a styled blank")
    check(rightCut.cellAt(1, 0).style == style && rightCut.cellAt(1, 0).width == 1,
        "right cut does not retain a wide leader")
    let target = Frame(5, 1, transparent: true)
    target.put(0, 0, "a中bc", style: style)
    let upper = Frame(1, 1)
    upper.put(0, 0, "X")
    target.composite(upper, x: 2)
    snapshot(target, "a Xbc", "writing target continuation clears leader outside intersection")
    check(emptyCell(target, 1, 0, true), "target partner cleanup uses default transparency")
    source.clear(Rect(2, 0, 1, 1), transparent: true)
    snapshot(source, "a  bc", "clear continuation clears the whole old cluster")
    check(emptyCell(source, 1, 0, true) && emptyCell(source, 2, 0, true),
        "explicit transparent clear resets both cells and style")
    source.clear(Rect(0, 0, 1, 1))
    check(emptyCell(source, 0, 0, false), "clear defaults to opaque Style blank")
}

func independentAndSelfCopy(): Unit {
    let source = Frame(5, 1)
    source.put(0, 0, "abcde")
    let copied = source.copy(Rect(0, 0, 5, 1))
    copied.put(0, 0, "X")
    snapshot(source, "abcde", "copy has no shared mutable cells")
    let grown = source.resized(7, 1)
    snapshot(grown, "abcde  ", "resized growth uses source default blanks")
    grown.put(1, 0, "Y")
    snapshot(source, "abcde", "resize has no shared mutable cells")
    source.composite(source, x: 1)
    snapshot(source, "aabcd", "rightward self overlap reads initial source snapshot")
    let left = Frame(5, 1)
    left.put(0, 0, "abcde")
    left.composite(left, x: -1)
    snapshot(left, "bcdee", "leftward self overlap reads initial source snapshot")
}

main(): Int64 {
    transparencyAndOrder()
    clustersAndClear()
    independentAndSelfCopy()
    return 0
}

package composition_contract

import cjtui.*

func illegal(action: () -> Unit, name: String): Unit {
    var caught = false
    try { action() } catch (_: IllegalArgumentException) { caught = true }
    check(caught, name)
}

func invariants(frame: Frame, name: String): Unit {
    var valid = true
    for (y in 0..frame.height) {
        for (x in 0..frame.width) {
            let c = frame.cellAt(x, y)
            if (c.isTransparent) {
                valid = valid && emptyCell(frame, x, y, true)
            } else if (c.continuation) {
                if (x == 0) { valid = false } else {
                    let leader = frame.cellAt(x - 1, y)
                    valid = valid && !leader.continuation && leader.width == 2 &&
                        !leader.isTransparent && leader.style == c.style && c.grapheme == "" && c.width == 0
                }
            } else if (c.width == 2) {
                if (x + 1 >= frame.width) { valid = false } else {
                    let next = frame.cellAt(x + 1, y)
                    valid = valid && next.continuation && !next.isTransparent && next.style == c.style
                }
            } else { valid = valid && c.width == 1 }
        }
    }
    check(valid, "${name}: complete clusters and normalized transparency")
}

func opacityAndExplicitClear(): Unit {
    let frame = Frame(6, 3, transparent: true)
    let style = Style(foreground: Color.Red, background: Color.Blue, italic: true)
    frame.fillRect(Rect(0, 0, 1, 1), style: style)
    frame.drawBorder(Rect(2, 0, 1, 1), border: BorderStyle.Ascii, style: style)
    frame.drawShadow(Rect(3, 0, 1, 1), offsetX: 1, offsetY: 0, style: style)
    check(!frame.cellAt(0, 0).isTransparent && frame.cellAt(0, 0).style == style,
        "fill writes opaque styled spaces on a transparent frame")
    check(!frame.cellAt(2, 0).isTransparent && frame.cellAt(2, 0).style == style,
        "border writes opaque cells on a transparent frame")
    check(!frame.cellAt(4, 0).isTransparent && frame.cellAt(4, 0).style == style,
        "shadow writes opaque cells on a transparent frame")
    check(emptyCell(frame, 1, 0, true) && emptyCell(frame, 5, 2, true), "unused allocation stays transparent")
    frame.put(1, 1, "中", style: style)
    frame.clear(Rect(1, 1, 1, 1))
    check(emptyCell(frame, 1, 1, false) && emptyCell(frame, 2, 1, false),
        "default clear overrides transparent frame default for complete touched cluster")
    frame.put(1, 1, "中", style: style)
    frame.put(2, 1, "X")
    check(emptyCell(frame, 1, 1, true) && !frame.cellAt(2, 1).isTransparent,
        "clear does not mutate default blank kind used by subsequent put")
    let opaque = Frame(4, 1)
    opaque.put(0, 0, "中AB", style: style)
    opaque.clear(Rect(0, 0, 1, 1), transparent: true)
    check(emptyCell(opaque, 0, 0, true) && emptyCell(opaque, 1, 0, true),
        "transparent clear touching leader resets partner outside rectangle")
    opaque.put(0, 0, "中", style: style)
    opaque.put(1, 0, "X")
    check(emptyCell(opaque, 0, 0, false), "explicit transparent clear does not change opaque default")
    opaque.clear(Rect(1, 0, 0, 1), transparent: true)
    snapshot(opaque, " XAB", "zero-width clear is a no-op")
    invariants(frame, "draw/put/clear")
    invariants(opaque, "opaque frame explicit transparent clear")
}

func clippingAndSourceOwnership(): Unit {
    let style = Style(foreground: Color.Green, background: Color.Yellow, underline: true)
    let source = Frame(5, 1)
    source.put(0, 0, "a中bc", style: style)
    let left = Frame(5, 1)
    left.put(0, 0, "uvwxy")
    left.composite(source, x: -2)
    snapshot(left, " bcxy", "negative offset clips source wide continuation into styled blank")
    check(left.cellAt(0, 0).style == style && !left.cellAt(0, 0).isTransparent,
        "left clipped composite fragment is opaque with exact source style")
    let right = Frame(5, 1)
    right.put(0, 0, "uvwxy")
    right.composite(source, x: 3)
    snapshot(right, "uvwa ", "right target edge clips source wide leader into styled blank")
    check(right.cellAt(4, 0).style == style && right.cellAt(4, 0).width == 1,
        "right clipped composite fragment keeps style and one column")
    snapshot(source, "a中bc", "clipping never mutates source")
    check(source.cellAt(1, 0).width == 2 && source.cellAt(2, 0).continuation &&
        source.cellAt(2, 0).style == style, "source cluster metadata stays unchanged")
    let cut = source.copy(Rect(0, 0, 2, 1))
    snapshot(cut, "a ", "copy right boundary clips source leader")
    check(cut.cellAt(1, 0).style == style && !cut.cellAt(1, 0).isTransparent,
        "copy right fragment retains style and opacity")
    let whole = source.copy(Rect(1, 0, 2, 1))
    snapshot(whole, "中", "copy retains a complete source cluster")
    check(whole.cellAt(0, 0).width == 2 && whole.cellAt(1, 0).continuation,
        "complete copied source has its continuation")
    let target = Frame(5, 1)
    target.put(0, 0, "a中bc", style: style)
    let upper = Frame(1, 1)
    upper.put(0, 0, "X")
    target.composite(upper, x: 1)
    snapshot(target, "aX bc", "writing target leader clears continuation outside intersection")
    check(emptyCell(target, 2, 0, false), "target partner uses target blank kind and Style default")
    let skipped = Frame(1, 1, transparent: true)
    target.put(1, 0, "中", style: style)
    target.composite(skipped, x: 2)
    snapshot(target, "a中bc", "transparent intersection never clears an existing target cluster")
    let crossing = Frame(4, 1, transparent: true)
    crossing.put(0, 0, "中中", style: style)
    let wideLayer = Frame(2, 1)
    wideLayer.put(0, 0, "中", style: style)
    crossing.composite(wideLayer, x: 1)
    snapshot(crossing, " 中 ", "source cluster crossing two old clusters clears both outside partners")
    check(emptyCell(crossing, 0, 0, true) && emptyCell(crossing, 3, 0, true),
        "both crossed target partners normalize to target default")
    let rows = Frame(3, 2)
    rows.put(0, 0, "ABC\nDEF")
    let grid = Frame(3, 2)
    grid.put(0, 0, "123\n456")
    grid.composite(rows, x: -1, y: -1)
    snapshot(grid, "EF3\n456", "negative x/y preserve source-local coordinates")
    for (frame in [left, right, cut, whole, target, crossing, grid]) { invariants(frame, "clipped operations") }
}

func copiesResizeAndPolicy(): Unit {
    let source = Frame(2, 1, transparent: true, maxCells: 12)
    source.put(0, 0, "AB")
    let padded = source.copy(Rect(-1, -1, 4, 3))
    snapshot(padded, "    \n AB \n    ", "copy preserves requested origin and pads out-of-source area")
    check(padded.width == 4 && padded.height == 3 && emptyCell(padded, 0, 1, true) &&
        !padded.cellAt(1, 1).isTransparent && emptyCell(padded, 3, 2, true),
        "copy outside padding inherits default transparency")
    let grown = source.resized(4, 2)
    snapshot(grown, "AB  \n    ", "resize growth keeps original origin")
    check(emptyCell(grown, 3, 0, true) && emptyCell(grown, 1, 1, true),
        "resize growth inherits transparent default")
    source.put(0, 0, "X")
    snapshot(padded, "    \n AB \n    ", "source mutation cannot affect existing copy")
    snapshot(grown, "AB  \n    ", "source mutation cannot affect resized frame")
    for (frame in [padded, grown]) {
        frame.put(0, 0, "中")
        frame.put(1, 0, "Q")
        check(emptyCell(frame, 0, 0, true), "copy/resize retain default blank kind for future cluster cleanup")
    }
    illegal({ => padded.resized(13, 1); () }, "copy retains original explicit cell budget")
    illegal({ => grown.copy(Rect(0, 0, 4, 4)); () }, "resized frame retains original explicit cell budget")
    let wide = Frame(3, 1, ambiguousWide: true)
    wide.put(0, 0, "·A")
    let copied = wide.copy(Rect(0, 0, 3, 1))
    let resized = wide.resized(4, 1)
    for (frame in [copied, resized]) {
        frame.put(0, 0, "·")
        check(frame.cellAt(0, 0).width == 2 && frame.cellAt(1, 0).continuation,
            "copy/resize retain ambiguous-wide policy for future writes")
    }
    let target = Frame(3, 1)
    target.put(0, 0, "abc")
    illegal({ => target.composite(wide); () }, "policy mismatch rejected")
    snapshot(target, "abc", "policy mismatch rejected before target mutation")
    illegal({ => target.composite(Frame(0, 0, ambiguousWide: true)); () },
        "empty source policy mismatch rejected before no-op")
    illegal({ => Frame(0, 0).composite(wide, x: Int64.Max); () },
        "empty destination policy mismatch rejected before no-op")
    illegal({ => target.composite(wide, x: Int64.Min); () },
        "offscreen policy mismatch rejected before clipping")
    snapshot(target, "abc", "all rejected policy operations leave target unchanged")
    for (frame in [padded, grown, copied, resized]) { invariants(frame, "copy/resize") }
}

func overlaps(): Unit {
    let down = Frame(2, 3)
    down.put(0, 0, "ab\ncd\nef")
    down.composite(down, y: 1)
    snapshot(down, "ab\nab\ncd", "downward self overlap snapshots rows")
    let up = Frame(2, 3)
    up.put(0, 0, "ab\ncd\nef")
    up.composite(up, y: -1)
    snapshot(up, "cd\nef\nef", "upward self overlap snapshots rows")
    let wide = Frame(5, 1)
    wide.put(0, 0, "中ab")
    wide.composite(wide, x: 1)
    snapshot(wide, " 中ab", "self overlap snapshots wide cluster before partner cleanup")
    let transparent = Frame(5, 1, transparent: true)
    transparent.put(0, 0, "AB")
    transparent.composite(transparent, x: 1)
    snapshot(transparent, "AAB  ", "self overlap snapshots opacity and leaves transparent holes")
    check(emptyCell(transparent, 3, 0, true) && emptyCell(transparent, 4, 0, true),
        "self overlap preserves original transparent holes")
    transparent.composite(transparent)
    snapshot(transparent, "AAB  ", "zero-offset self copy preserves content")
    for (frame in [down, up, wide, transparent]) { invariants(frame, "self overlap") }
}

func budgetAndExtrema(): Unit {
    illegal({ => Frame(-1, 1); () }, "negative width rejected")
    illegal({ => Frame(1, -1); () }, "negative height rejected")
    illegal({ => Frame(1, 1, maxCells: 0); () }, "zero budget rejected")
    illegal({ => Frame(0, 0, maxCells: -1); () }, "negative budget rejected even for empty frame")
    illegal({ => Frame(2, 2, maxCells: 3); () }, "positive area budget rejected before allocation")
    illegal({ => Frame(1048577, 1); () }, "default positive-area allocation budget enforced")
    illegal({ => Frame(Int64.Max, 2, maxCells: Int64.Max); () }, "overflowing product rejected before allocation")
    let small = Frame(3, 1, maxCells: 3)
    illegal({ => small.copy(Rect(0, 0, 4, 1)); () }, "copy checks destination budget")
    illegal({ => small.resized(2, 2); () }, "resize checks destination budget")
    illegal({ => small.resized(-1, 1); () }, "resize checks negative dimensions")
    let frame = Frame(3, 2)
    frame.put(0, 0, "abc\ndef")
    let layer = Frame(1, 1)
    layer.put(0, 0, "X")
    for (extreme in [Int64.Min, Int64.Max]) {
        frame.composite(layer, x: extreme)
        frame.composite(layer, y: extreme)
        frame.clear(Rect(extreme, extreme, Int64.Max, Int64.Max), transparent: true)
        snapshot(frame, "abc\ndef", "extreme geometry remains outside without overflow or virtual loops")
        let outside = frame.copy(Rect(extreme, extreme, 2, 1))
        snapshot(outside, "  ", "extreme copy origin pads bounded result")
    }
    frame.clear(Rect(-1, -1, Int64.Max, Int64.Max), transparent: true)
    snapshot(frame, "   \n   ", "huge clear clips to actual bounded target")
    check(emptyCell(frame, 2, 1, true), "huge clear reaches far visible corner")
    for (empty in [Frame(0, Int64.Max), Frame(Int64.Max, 0)]) {
        empty.clear(Rect(Int64.Min, Int64.Min, Int64.Max, Int64.Max))
        empty.composite(layer, x: Int64.Min, y: Int64.Max)
        frame.composite(empty)
        check(empty.toAnsi() == "", "zero-area extrema preserve legacy ANSI empty contract")
        check(empty.copy(Rect(0, 0, 0, Int64.Max)).toAnsi() == "", "zero-area extreme copy short circuits")
        check(empty.resized(Int64.Max, 0).toPlainText() == "", "zero-height extreme resize exports empty text")
    }
    check(Frame(0, 4, maxCells: 3).toPlainText() == "\n\n\n", "zero-width LF length allowed exactly at budget")
    illegal({ => Frame(0, 5, maxCells: 3).toPlainText(); () }, "zero-width LF length over budget rejected")
    illegal({ => Frame(0, Int64.Max).toPlainText(); () }, "zero-width extreme text fails before virtual iteration")
    check(Frame(0, 5, maxCells: 3).toAnsi() == "", "zero-width ANSI remains empty regardless of text LF budget")
}

package incremental_frame_cow

import cjtui.*

// Run under a process address-space cap: a row directory proportional to virtual height fails.
func zeroAxes(): Unit {
    let tall = Frame(0, Int64.Max, ambiguousWide: true, transparent: true, maxCells: 7)
    let wide = Frame(Int64.Max, 0, ambiguousWide: true, transparent: true, maxCells: 7)
    let clone = tall.copy(Rect(0, 0, 0, Int64.Max))
    let resized = wide.resized(0, Int64.Max)
    for (f in [tall, clone, resized]) {
        check(f.width == 0 && f.height == Int64.Max, "virtual tall metadata")
        check(f.toAnsi() == "", "zero ANSI")
        f.put(0, 0, "中")
        f.fillRect(Rect(0, 0, Int64.Max, Int64.Max))
        f.clear(Rect(0, 0, Int64.Max, Int64.Max), transparent: true)
        f.drawBorder(Rect(0, 0, Int64.Max, Int64.Max))
        f.drawShadow(Rect(0, 0, Int64.Max, Int64.Max))
        f.composite(wide)
        rejects({ => f.toPlainText(); () }, "virtual text rejects before giant output")
        let finite = f.resized(2, 2)
        cell(finite, 0, 0, " ", 1, false, Style(), true, "zero resize keeps default transparency")
        finite.put(0, 0, "·")
        cell(finite, 1, 0, "", 0, true, Style(), false, "zero resize keeps width policy")
        rejects({ => f.resized(4, 2); () }, "zero resize keeps budget")
        rejects({ => f.composite(Frame(0, 0)); () }, "zero checks policy before short circuit")
    }
    let wideCopy = wide.copy(Rect(0, 0, Int64.Max, 0))
    check(wideCopy.width == Int64.Max && wideCopy.height == 0, "virtual wide copy dimensions")
    check(wideCopy.toPlainText() == "" && wideCopy.toAnsi() == "", "virtual wide export")
    check(Frame(0, 3).toPlainText() == "\n\n", "finite zero-width LF rule")
    rejects({ => Frame(Int64.Max, 2); () }, "positive-area multiplication overflow")
    rejects({ => Frame(3, 3, maxCells: 8); () }, "positive-area budget")
}

package glyph_observable_control
import cjtui.*

func check(value: Bool, name: String): Unit {
    if (!value) { throw Exception("FAIL ${name}") }
    println("PASS ${name}")
}

main(): Int64 {
    let text = Observable<String>("中")
    let foreground = Observable<Color>(Color.Red)
    check(text.get() == "中" && foreground.get() == Color.Red, "public typed get reads initial values")
    let app = Application(Text({ => text.get() }).foreground({ => foreground.get() }))
    app.startHeadless()
    try {
        let initial = app.snapshot(4, 1)
        check(initial.toPlainText() == "中  " && initial.cellAt(0, 0).style.foreground == Color.Red,
            "public get creates live text and foreground bindings")
        for ((next, expected) in [("文", "文  "), ("??", "??  "),
            ("👩\u{200d}💻", "👩\u{200d}💻  "), ("❤\u{fe0f}", "❤\u{fe0f}  "), ("A", "A   ")]) {
            app.batch({ => text.set(next) })
            check(text.get() == next && app.snapshot(4, 1).toPlainText() == expected,
                "String set/get invalidates existing binding: ${next}")
        }
        app.batch({ => foreground.set(Color.Blue) })
        let colored = app.snapshot(4, 1)
        check(foreground.get() == Color.Blue && colored.toPlainText() == "A   " &&
            colored.cellAt(0, 0).style.foreground == Color.Blue,
            "Color-only set/get updates existing style binding")
        app.batch({ => text.set("文"); foreground.set(Color.Blue) })
        let combined = app.snapshot(4, 1)
        check(text.get() == "文" && foreground.get() == Color.Blue &&
            combined.toPlainText() == "文  " && combined.cellAt(0, 0).style.foreground == Color.Blue,
            "combined event writes preserve text and color semantics")
    } finally { app.dispose() }
    return 0
}

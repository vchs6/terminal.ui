package glyph_capture_control
import cjtui.*

func check(value: Bool, name: String): Unit {
    if (!value) { throw Exception("FAIL ${name}") }
    println("PASS ${name}")
}

main(): Int64 {
    let root = Text("capture")
    let app = Application(root)
    let serial = Array<Int64>(1, repeat: 0)
    app.onKey { event =>
        match (event.text) {
            case "p" => serial[0]++
            case "q" => app.stop()
            case _ => ()
        }
    }
    app.startHeadless()
    try {
        let target = root.reference().getOrThrow()
        check(serial[0] == 0, "stored onKey starts at zero")
        for ((input, expected) in [("p", 1), ("x", 1), ("p", 2), ("p", 3)]) {
            app.dispatch(target, KeyEvent("text", text: input))
            check(serial[0] == expected, "actual onKey callback count ${input}=${expected}")
        }
        app.dispatch(target, KeyEvent("text", text: "q"))
        check(serial[0] == 3, "serial retained after callback-driven stop")
    } finally { app.dispose() }
    return 0
}

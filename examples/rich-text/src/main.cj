package rich_text_example

import cjtui.*
import std.env.getCommandLine

main(): Int64 {
    // ANSI is explicitly decoded once; Text(String) continues to reject ESC.
    let decoded = parseAnsiText("\u{1b}[1;38;2;80;180;255mANSI styles\u{1b}[0m remain structured")
    let alternate = Observable<Bool>(false)
    let root = Column {
        Text("Rich text — t: toggle style, q: quit")
        Text(decoded.text)
        Text({
            => RichText(
                [
                    TextSpan("e", style: TextStylePatch(foreground: Some(if (alternate.get()) {
                        Color.Green
                    } else {
                        Color.Red
                    }))),
                    TextSpan("\u{301} and 界 👩\u{200d}💻", style: TextStylePatch(italic: Some(true)))
                ]
            )
        })
        Text(decoded.text).foreground(Color.Yellow)
    }
    let app = Application(root)
    app.onKey {
        event => if (event.text == "q") {
            app.stop()
        } else if (event.text == "t") {
            alternate.set(!alternate.get())
        }
    }
    if (getCommandLine().contains("--smoke")) {
        app.startHeadless()
        try {
            app.snapshot(64, 6)
            alternate.set(true)
            let frame = app.snapshot(64, 6)
            if (frame.cellAt(0, 2).grapheme != "e\u{301}" || frame.cellAt(0, 2).style.foreground != Color.Green) {
                throw Exception("rich text example smoke failed")
            }
            println(frame.toPlainText())
        } finally {
            app.dispose()
        }
    } else {
        app.run()
    }
    0
}

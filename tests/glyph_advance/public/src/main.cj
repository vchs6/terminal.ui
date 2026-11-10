package glyph_advance_contract

import cjtui.*
import std.env.getVariable
import std.fs.File

func check(value: Bool, name: String): Unit {
    if (!value) { throw Exception("FAIL: ${name}") }
    println("PASS: ${name}")
}

func publicContract(): Unit {
    // A003/A005: independent literal expectations, never a second width algorithm.
    for ((text, columns) in [("A", 1), ("界", 2), ("e\u{301}", 1), ("👩", 2), ("💻", 2),
        ("🇨🇳", 2), ("👩\u{200d}💻", 2), ("❤\u{fe0f}", 2), ("☀\u{fe0f}", 2), ("1\u{fe0f}\u{20e3}", 2)]) {
        check(displayWidth(text) == columns && graphemeClusters(text).size == 1, "canonical width and grapheme ${text}")
        let frame = Frame(columns, 1)
        frame.put(0, 0, text)
        check(frame.cellAt(0, 0).grapheme == text && frame.cellAt(0, 0).width == columns &&
            frame.toPlainText() == text, "public Frame retains canonical ${text}")
        check(frame.toAnsi() == "\u{1b}[0m\u{1b}[1;1H" + text + "\u{1b}[0m", "offline Unicode bytes ${text}")
    }
    let state = Observable<Bool>(false)
    let root = Text({ => RichText([TextSpan("👩\u{200d}💻", style: TextStylePatch(foreground: Some(if (state.get()) { Color.Green } else { Color.Red }))), TextSpan("❤\u{fe0f}Z")]) })
    let app = Application(root)
    app.startHeadless()
    try {
        check(app.snapshot(5, 1).toPlainText() == "👩\u{200d}💻❤\u{fe0f}Z", "rich headless logical Unicode")
        state.set(true)
        let frame = app.snapshot(5, 1)
        check(frame.cellAt(0, 0).style.foreground == Color.Green && frame.cellAt(0, 0).width == 2 &&
            frame.cellAt(1, 0).continuation && frame.cellAt(2, 0).grapheme == "❤\u{fe0f}", "rich reactive style and canonical columns")
    } finally { app.dispose() }
    let fileFrame = Frame(2, 1)
    fileFrame.put(0, 0, "👩\u{200d}💻")
    match (getVariable("CJTUI_ADVANCE_FILES")) {
        case Some(dir) =>
            fileFrame.writeAnsi(dir + "/unicode.ansi")
            fileFrame.writePlainText(dir + "/unicode.txt")
            check(String.fromUtf8(File.readFrom(dir + "/unicode.ansi")) == "\u{1b}[0m\u{1b}[1;1H👩\u{200d}💻\u{1b}[0m", "writeAnsi exact offline bytes")
            check(String.fromUtf8(File.readFrom(dir + "/unicode.txt")) == "👩\u{200d}💻", "writePlainText exact logical bytes")
        case None => throw Exception("CJTUI_ADVANCE_FILES must name a fresh existing directory")
    }
}

func hostConsumer(): Unit {
    // Ordinary public app: opposite VS16 physical error, no terminal branches in content.
    let state = Observable<Bool>(false)
    let sample = match (getVariable("CJTUI_ADVANCE_SAMPLE")) {
        case Some("sun") => "☀\u{fe0f}"
        case Some("keycap") => "1\u{fe0f}\u{20e3}"
        case _ => "❤\u{fe0f}"
    }
    let root = Column {
        Text("Advance compatibility — t: toggle, q: quit")
        Text("A 界 e\u{301} 👩 💻 🇨🇳")
        Text({ => RichText([TextSpan(sample, style: TextStylePatch(foreground: Some(if (state.get()) { Color.Green } else { Color.Red }))), TextSpan("Z")]) })
        Text("ANSI styles remain structured")
    }
    let app = Application(root)
    match (getVariable("CJTUI_ADVANCE_COLOR")) {
        case Some("basic8") => app.colorMode(ColorMode.Basic8)
        case Some("truecolor") => app.colorMode(ColorMode.TrueColor)
        case _ => app.colorModeAuto()
    }
    app.onKey { event => if (event.text == "q") { app.stop() } else if (event.text == "t") { state.set(!state.get()) } }
    app.run()
}

main(): Int64 {
    match (getVariable("CJTUI_ADVANCE_HOST")) {
        case Some("1") => hostConsumer()
        case _ => publicContract()
    }
    0
}

package glyph_session

import cjtui.*
import std.env.*
import std.fs.File

func modeName(value: GlyphMode): String {
    match (value) { case GlyphMode.Auto => "Auto"; case GlyphMode.Unicode => "Unicode"; case GlyphMode.Ascii => "Ascii" }
}

func save(app: Application, serial: Int64): Unit {
    let capabilities = app.terminalGlyphCapabilities().getOrThrow()
    let report = "nativeVt=${capabilities.nativeVt}\nmapKnown=${capabilities.mapKnown}\n" +
        "entryCount=${capabilities.entryCount}\nsource=${capabilities.source}\nreason=${capabilities.reason}\n" +
        "nativeError=${capabilities.nativeError}\nmode=${modeName(app.glyphMode())}\nserial=${serial}\n" +
        "frames=${app.stats().frames}\nmeasures=${app.stats().measures}\nmounted=${app.stats().mountedNodes}\n"
    File.writeTo(getVariable("CJTUI_GLYPH_REPORT").getOrThrow(), report.toArray())
}

main(): Int64 {
    let text = Observable<String>("中")
    let foreground = Observable<Color>(Color.Red)
    let root = Column {
        Text({ => text.get() }).foreground({ => foreground.get() })
        Text("é e\u{301} 中文 😀 ✈\u{fe0f} 👩‍💻 …")
        Text("BOX").border(BorderStyle.Rounded)
    }
    let app = Application(root)
    match (getVariable("CJTUI_GLYPH_MODE")) {
        case Some("Ascii") => app.glyphMode(GlyphMode.Ascii)
        case Some("Unicode") => app.glyphMode(GlyphMode.Unicode)
        case _ => ()
    }
    let serial = Array<Int64>(1, repeat: 0)
    app.onKey { event =>
        match (event.text) {
            case "p" => serial[0]++; save(app, serial[0])
            case "v" => text.set("文")
            case "t" => text.set("??")
            case "z" => text.set("👩\u{200d}💻")
            case "h" => text.set("❤\u{fe0f}")
            case "n" => text.set("A")
            case "c" => foreground.set(Color.Blue)
            case "b" => text.set("文"); foreground.set(Color.Blue)
            case "a" => app.glyphMode(GlyphMode.Ascii)
            case "u" => app.glyphMode(GlyphMode.Unicode)
            case "o" => app.glyphMode(GlyphMode.Auto)
            case "q" => app.stop()
            case _ => ()
        }
    }.run()
    // Retained diagnostics remain readable after cleanup and fd lifetime ends.
    // snapshot requires an outer UI boundary: never call it inside onKey.
    app.startHeadless()
    try {
        let logical = app.snapshot(32, 6).toPlainText()
        File.writeTo(getVariable("CJTUI_GLYPH_REPORT").getOrThrow() + ".snapshot", logical.toArray())
        app.snapshot(32, 6, glyphMode: GlyphMode.Ascii)
    } finally { app.dispose() }
    save(app, serial[0])
    return 0
}

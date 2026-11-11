package theme_glyph_language
import cjtui.*
import std.env.*
import std.fs.File

// SDK 1.2 facts: get()/set(), and a let reference holder captured by onKey.
// This consumer contains NO future Theme/TextOverflow names.
main(): Int64 {
    let source = Observable<String>("é …")
    let serial = Array<Int64>(1,repeat:0)
    let app = Application(Text({=>source.get()}))
    app.onKey { event =>
        match (event.text) {
            case "p" =>
                serial[0]++
                let caps = app.terminalGlyphCapabilities().getOrThrow()
                let report = "serial=${serial[0]}\nnativeVt=${caps.nativeVt}\nmapKnown=${caps.mapKnown}\nentryCount=${caps.entryCount}\nsource=${caps.source}\nreason=${caps.reason}\nnativeError=${caps.nativeError}\n"
                File.writeTo(getVariable("CJTUI_THEME_GLYPH_REPORT").getOrThrow(),report.toArray())
            case "q" => app.stop()
            case _ => ()
        }
    }
    if (getVariable("CJTUI_THEME_GLYPH_CONTROL_PTY").isSome()) {
        app.run()
    } else {
        source.set("ABCDE")
        app.startHeadless()
        try {
            if (app.snapshot(4,1,glyphMode:GlyphMode.Ascii).toPlainText() != "ABCD") { throw Exception("real snapshot API") }
            if (source.get() != "ABCDE" || serial[0] != 0) { throw Exception("SDK holder/get/set") }
        } finally { app.dispose() }
        println("PASS SDK1.2 get/set, legal onKey holder, actual current public Glyph API")
    }
    0
}

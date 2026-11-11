package theme_glyph_session
import cjtui.*
import std.env.*
import std.fs.File

func save(app: Application, serial: Int64): Unit {
    let caps = app.terminalGlyphCapabilities().getOrThrow()
    let report = "serial=${serial}\nnativeVt=${caps.nativeVt}\nmapKnown=${caps.mapKnown}\nentryCount=${caps.entryCount}\nsource=${caps.source}\nreason=${caps.reason}\nnativeError=${caps.nativeError}\nframes=${app.stats().frames}\nmeasures=${app.stats().measures}\nmounted=${app.stats().mountedNodes}\n"
    File.writeTo(getVariable("CJTUI_THEME_GLYPH_REPORT").getOrThrow(),report.toArray())
}
main(): Int64 {
    let source = Observable<String>("ABCDE")
    let root = Column {
        Text({=>source.get()}).width(0).overflow(TextOverflow.Ellipsis)
        Text({=>source.get()}).width(1).overflow(TextOverflow.Ellipsis)
        Text({=>source.get()}).width(2).overflow(TextOverflow.Ellipsis)
        Text({=>source.get()}).width(3).overflow(TextOverflow.Ellipsis)
        Text({=>source.get()}).width(4).overflow(TextOverflow.Ellipsis)
        Row { Text({=>source.get()}).layoutWeight(1).overflow(TextOverflow.Ellipsis); Text("q").width(1) }
        Text("éBCDE").width(4).overflow(TextOverflow.Ellipsis)
        Text("👩‍💻").width(2)
    }
    let app = Application(root,theme:Theme.preset(ThemePreset.Classic))
    match (getVariable("CJTUI_THEME_GLYPH_MODE")) {
        case Some("Ascii") => app.glyphMode(GlyphMode.Ascii)
        case Some("Unicode") => app.glyphMode(GlyphMode.Unicode)
        case _ => ()
    }
    let serial = Array<Int64>(1,repeat:0)
    app.onKey { event =>
        match (event.text) {
            case "p" => serial[0]++;save(app,serial[0])
            case "a" => app.glyphMode(GlyphMode.Ascii)
            case "u" => app.glyphMode(GlyphMode.Unicode)
            case "o" => app.glyphMode(GlyphMode.Auto)
            case "v" => source.set("VWXYZ")
            case "q" => app.stop()
            case _ => ()
        }
    }.run()
    // Device diagnostics retained, offline Auto/Unicode use independent policy.
    app.startHeadless()
    try {
        let path = getVariable("CJTUI_THEME_GLYPH_REPORT").getOrThrow()
        File.writeTo(path + ".default",app.snapshot(5,8).toPlainText().toArray())
        File.writeTo(path + ".ascii",app.snapshot(5,8,glyphMode:GlyphMode.Ascii).toPlainText().toArray())
        File.writeTo(path + ".auto",app.snapshot(5,8,glyphMode:GlyphMode.Auto).toPlainText().toArray())
        if (source.get() != "ABCDE") { throw Exception("source changed by layout") }
    } finally { app.dispose() }
    save(app,serial[0])
    0
}

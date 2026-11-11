package theme_glyph_refresh
import cjtui.*
import std.fs.File
import std.env.*
func cacheContext(): Unit {
    let source = Observable<String>("éBCDE")
    let node = Text({=>source.get()}).overflow(TextOverflow.Ellipsis)
    let app = Application(node,glyphMode:GlyphMode.Ascii)
    app.startHeadless()
    try {
        check(app.snapshot(4,1).toPlainText() == "éBC…","default ignores device Ascii")
        let mounted = app.stats().mountedNodes
        let frames = app.stats().frames
        check(app.snapshot(4,1,glyphMode:GlyphMode.Auto).toPlainText() == "éBC…","offline Auto independently Unicode")
        check(app.stats().frames == frames,"equal policies reuse cache")
        check(app.snapshot(4,1,glyphMode:GlyphMode.Ascii).toPlainText() == "é...","Ascii prefix before paint")
        check(app.stats().frames > frames,"changed policy invalidates frame")
        let asciiFrames = app.stats().frames
        check(app.snapshot(4,1,glyphMode:GlyphMode.Ascii).toPlainText() == "é...","repeat Ascii")
        check(app.stats().frames == asciiFrames,"same policy reuses cache")
        check(app.snapshot(4,1).toPlainText() == "éBC…","default recovers after Ascii cache")
        app.batch({=>app.glyphMode(GlyphMode.Unicode);()})
        check(app.snapshot(4,1,glyphMode:GlyphMode.Ascii).toPlainText() == "é...","offline ignores device Unicode")
        app.batch({=>app.glyphMode(GlyphMode.Ascii);()})
        check(app.snapshot(4,1).toPlainText() == "éBC…","setter cannot poison offline default")
        check(app.stats().mountedNodes == mounted,"preserve mounted tree")
        check(app.terminalGlyphCapabilities().isNone(),"headless does not detect device")
        check(source.get() == "éBCDE","business source unchanged")
        let output = getVariable("CJTUI_THEME_GLYPH_FILES").getOrThrow()
        let frame = app.snapshot(4,1,glyphMode:GlyphMode.Ascii)
        frame.writePlainText(output + "/ascii.txt")
        frame.writeAnsi(output + "/ascii.ansi")
        check(String.fromUtf8(File.readFrom(output + "/ascii.txt")) == "é...","plain file Unicode body")
        check(String.fromUtf8(File.readFrom(output + "/ascii.ansi")) == frame.toAnsi() && frame.toAnsi().contains("é..."),"ANSI file logical content")
    } finally { app.dispose() }
    check(render(node,4,1,glyphMode:GlyphMode.Ascii).toPlainText() == "é...","render after disposal")
    check(render(node,4,1).toPlainText() == "éBC…","render default after Ascii")
}

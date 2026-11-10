package glyph_public

import cjtui.*
import std.fs.File
import std.env.*

func check(value: Bool, name: String): Unit {
    if (!value) { throw Exception("FAIL ${name}") }
    println("PASS ${name}")
}

func fields(value: TerminalGlyphCapabilities): Unit {
    let nativeVt: Bool = value.nativeVt
    let known: Bool = value.mapKnown
    let count: Int64 = value.entryCount
    let source: String = value.source
    let reason: String = value.reason
    let nativeError: Int64 = value.nativeError
    check(nativeVt == nativeVt && known == known && count >= 0 && source == source &&
        reason == reason && nativeError >= 0, "readable public diagnostic snapshot")
}

main(): Int64 {
    let original = "é e\u{301} 中文 😀 ✈\u{fe0f} 👩‍💻 …"
    let expected = original + "           " // 19 display columns + 11 padding = 30.
    check(displayWidth(original) == 19, "independent source column count")
    let root = Text(original)
    for (mode in [GlyphMode.Auto, GlyphMode.Unicode, GlyphMode.Ascii]) {
        check(render(root, 30, 1, glyphMode: mode).toPlainText() == expected,
            "offline mode keeps all business graphemes")
    }
    check(render(root, 30, 1).toPlainText() == expected, "render default Unicode")
    let app = Application(root, limits: RuntimeLimits(), glyphMode: GlyphMode.Ascii)
    check(app.glyphMode() == GlyphMode.Ascii, "constructor stores requested override")
    check(app.terminalGlyphCapabilities().isNone(), "None before run")
    app.startHeadless()
    try {
        app.snapshot(30, 1, glyphMode: GlyphMode.Unicode)
        let samePolicyFrames = app.stats().frames
        app.snapshot(30, 1, glyphMode: GlyphMode.Unicode)
        app.snapshot(30, 1, glyphMode: GlyphMode.Auto)
        check(app.stats().frames == samePolicyFrames, "equal offline policy content reuses cache, independent of object identity")
        let beforeAscii = app.stats().frames
        app.snapshot(30, 1, glyphMode: GlyphMode.Ascii)
        check(app.stats().frames > beforeAscii, "offline Ascii policy invalidates cached logical Frame")
        let beforeUnicode = app.stats().frames
        app.snapshot(30, 1, glyphMode: GlyphMode.Unicode)
        check(app.stats().frames > beforeUnicode, "offline Unicode policy invalidates Ascii cache")
        for (mode in [GlyphMode.Unicode, GlyphMode.Ascii, GlyphMode.Auto, GlyphMode.Unicode]) {
            check(app.snapshot(30, 1, glyphMode: mode).toPlainText() == expected,
                "alternating offline modes preserve original Unicode")
        }
        let mounted = app.stats().mountedNodes
        app.batch({ => app.glyphMode(GlyphMode.Unicode); () })
        check(app.glyphMode() == GlyphMode.Unicode, "UI-domain setter")
        check(app.snapshot(30, 1).toPlainText() == expected, "device setting cannot pollute default snapshot")
        check(app.stats().mountedNodes == mounted, "mode switch preserves mounted nodes")
        check(app.terminalGlyphCapabilities().isNone(), "headless and snapshot never probe")
        let frame = app.snapshot(30, 1, glyphMode: GlyphMode.Ascii)
        let directory = getVariable("CJTUI_GLYPH_FILES").getOrThrow()
        let plain = directory + "/logical.txt"
        let ansi = directory + "/logical.ansi"
        frame.writePlainText(plain)
        frame.writeAnsi(ansi)
        check(String.fromUtf8(File.readFrom(plain)) == expected, "File complete logical Unicode plain snapshot")
        let saved = String.fromUtf8(File.readFrom(ansi))
        check(saved == frame.toAnsi() && saved.contains(original), "File complete logical Unicode ANSI snapshot")
        check(saved.contains("\u{1b}[1;1H"), "ANSI export contains independent full-frame positioning")
    } finally { app.dispose() }
    let frame = Frame(4, 1)
    frame.put(0, 0, "中")
    frame.put(1, 0, "A")
    check(frame.toPlainText() == " A  ", "overwriting continuation clears whole cluster")
    frame.put(3, 0, "中")
    check(frame.toPlainText() == " A  ", "right clipping drops whole wide cluster")
    let zero = Frame(0, 0)
    check(zero.toPlainText() == "" && zero.toAnsi() == "", "zero resource boundary")
    var rejected = false
    try { Frame(1048577, 1) } catch (_: IllegalArgumentException) { rejected = true }
    check(rejected, "existing Frame cell resource cap")
    println("PASS glyph offline contract")
    return 0
}

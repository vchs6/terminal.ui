package cjtui

import std.unittest.*
import std.unittest.testmacro.*

func g012Check(value: Bool, name: String): Unit {
    if (!value) { throw Exception("FAIL G012 ${name}") }
}

@Test
func glyph_g012_independent_width_facts_and_literal_projection(): Unit {
    let safe = GlyphRenderPolicy.conservativeUnicode()
    let unicode = GlyphRenderPolicy.unicode()
    // Handwritten logical width, scalar sum and projected text. These establish
    // this library's model agreement, never unknown-host font/advance support.
    for ((text, logical, scalarSum, expected) in [
        ("A", 1, 1, "A"), ("é", 1, 1, "é"), ("e\u{301}", 1, 1, "e\u{301}"),
        ("中", 2, 2, "中"), ("😀", 2, 2, "😀"), ("👩", 2, 2, "👩"),
        ("💻", 2, 2, "💻"), ("🇨🇳", 2, 2, "🇨🇳"),
        ("✈\u{fe0f}", 2, 1, "??"), ("❤\u{fe0f}", 2, 1, "??"),
        ("☀\u{fe0f}", 2, 1, "??"), ("1\u{fe0f}\u{20e3}", 2, 1, "??"),
        ("👩\u{200d}💻", 2, 4, "??"), ("…", 1, 1, "…")
    ]) {
        var actualSum: Int64 = 0
        for (scalar in text.runes()) { actualSum += displayWidth(scalar.toString()) }
        g012Check(displayWidth(text) == logical && actualSum == scalarSum, "independent width facts ${text}")
        g012Check(projectTerminalGlyph(text, logical, safe) == expected, "literal conservative projection ${text}")
        g012Check(projectTerminalGlyph(text, logical, unicode) == text, "explicit Unicode stays raw ${text}")
    }
    g012Check(projectTerminalGlyph("界界界界", 7, safe) == "???????", "bounded excess sum")
    g012Check(projectTerminalGlyph("界界界A", 7, safe) == "界界界A", "nonfixed width budget")
    for (policy in [safe, unicode]) {
        g012Check(projectTerminalGlyph("👩\u{200d}💻", 0, policy) == "", "zero width")
        var rejected = false
        try { projectTerminalGlyph("A", -1, policy) }
        catch (_: IllegalArgumentException) { rejected = true }
        g012Check(rejected, "negative width rejected")
    }
}

@Test
func glyph_g012_full_columns_and_logical_exports(): Unit {
    let profile = TerminalRenderProfile(colorMode: ColorMode.Monochrome,
        glyphPolicy: GlyphRenderPolicy.conservativeUnicode())
    let frame = Frame(19, 1)
    frame.put(0, 0, "é e\u{301} 中文 😀 ✈\u{fe0f} 👩\u{200d}💻 …")
    g012Check(frame.toAnsiForTerminal(profile) ==
        "\u{1b}[0m\u{1b}[1;1Hé e\u{301} 中文 😀 ?? ?? …\u{1b}[0m", "full nineteen projected columns")
    g012Check(frame.toPlainText() == "é e\u{301} 中文 😀 ✈\u{fe0f} 👩\u{200d}💻 …", "logical original retained")
    g012Check(frame.toAnsi() ==
        "\u{1b}[0m\u{1b}[1;1Hé e\u{301} 中文 😀 ✈\u{fe0f} 👩\u{200d}💻 …\u{1b}[0m", "default Unicode export")
    g012Check(frame.cellAt(15, 0).grapheme == "👩\u{200d}💻" && frame.cellAt(16, 0).continuation,
        "canonical head and continuation preserved")
}

@Test
func glyph_g012_diff_structure_and_profiles(): Unit {
    let safe = TerminalRenderProfile(colorMode: ColorMode.Monochrome,
        glyphPolicy: GlyphRenderPolicy.conservativeUnicode())
    let unicode = TerminalRenderProfile(colorMode: ColorMode.Monochrome)
    let zwj = Frame(4, 1)
    zwj.put(0, 0, "👩\u{200d}💻")
    let vs = Frame(4, 1)
    vs.put(0, 0, "❤\u{fe0f}")
    let questions = Frame(4, 1)
    questions.put(0, 0, "??")
    for ((old, current) in [(zwj, vs), (vs, zwj), (zwj, questions), (questions, zwj),
        (vs, questions), (questions, vs)]) {
        g012Check(current.changesSinceForTerminal(old, safe, safe) == "", "equal projected columns silence")
    }
    g012Check(zwj.changesSinceForTerminal(zwj, unicode, safe) ==
        "\u{1b}[0m\u{1b}[1;1H??  \u{1b}[0m", "old Unicode new conservative")
    g012Check(zwj.changesSinceForTerminal(zwj, safe, unicode) ==
        "\u{1b}[0m\u{1b}[1;1H👩\u{200d}💻  \u{1b}[0m", "old conservative new Unicode")
    g012Check(questions.changesSinceForTerminal(zwj, safe, unicode) == "", "policy plus structure equality")
    let narrow = Frame(4, 1)
    narrow.put(0, 0, "A")
    g012Check(narrow.changesSinceForTerminal(zwj, safe, safe) ==
        "\u{1b}[0m\u{1b}[1;1HA   \u{1b}[0m", "wide to narrow clears remainder")
}

@Test
func glyph_g012_style_and_device_color_independence(): Unit {
    let caps = TerminalCapabilities(colorMode: ColorMode.TrueColor, colorKnown: true, terminfoKnown: true,
        supportsBold: true, supportsDim: true, supportsItalic: true, supportsUnderline: true,
        supportsInverse: true, supportsStrikethrough: true, noColorVideo: -1, source: "terminfo", reason: "")
    let old = Frame(2, 1)
    old.put(0, 0, "👩\u{200d}💻", style: Style(foreground: Color.Red))
    let current = Frame(2, 1)
    current.put(0, 0, "??", style: Style(foreground: Color.Blue))
    let mono = TerminalRenderProfile(colorMode: ColorMode.Monochrome,
        glyphPolicy: GlyphRenderPolicy.conservativeUnicode())
    g012Check(current.changesSinceForTerminal(old, mono, mono) == "", "simultaneous color and glyph equality")
    let colored = TerminalRenderProfile(colorMode: ColorMode.TrueColor,
        glyphPolicy: GlyphRenderPolicy.conservativeUnicode())
    g012Check(current.changesSinceForTerminal(old, colored, colored) != "", "visible projected style change")
    for (mode in [ColorMode.Monochrome, ColorMode.Basic8, ColorMode.Basic16, ColorMode.Indexed256, ColorMode.TrueColor]) {
        g012Check(projectTerminalGlyph("👩\u{200d}💻", 2, terminalRenderProfile(caps, mode).glyphPolicy) == "??",
            "default device conservative regardless of color")
        g012Check(projectTerminalGlyph("👩\u{200d}💻", 2, snapshotProfile(mode).glyphPolicy) == "👩\u{200d}💻",
            "offline snapshot remains Unicode regardless of color")
    }
    g012Check(caps.source == "terminfo" && caps.reason == "", "raw color facts unchanged")
}

@Test
func glyph_g012_ambiguous_width_and_zero_area(): Unit {
    let safe = TerminalRenderProfile(colorMode: ColorMode.Monochrome,
        glyphPolicy: GlyphRenderPolicy.conservativeUnicode())
    let wide = Frame(2, 1, ambiguousWide: true)
    wide.put(0, 0, "…")
    g012Check(wide.cellAt(0, 0).width == 2 && wide.toPlainText() == "…", "public ambiguousWide unchanged")
    g012Check(wide.toAnsiForTerminal(safe) == "\u{1b}[0m\u{1b}[1;1H??\u{1b}[0m", "stored width wins over narrow scalar sum")
    for ((width, height) in [(0, 0), (0, Int64.Max), (Int64.Max, 0)]) {
        let empty = Frame(width, height)
        g012Check(empty.toAnsiForTerminal(safe) == "" &&
            empty.changesSinceForTerminal(empty, safe, safe) == "", "zero area fast path")
    }
}

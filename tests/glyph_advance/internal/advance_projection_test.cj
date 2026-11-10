package cjtui

import std.unittest.*
import std.unittest.testmacro.*

@Test
func advance_literal_projection_contract(): Unit {
    let safe = GlyphRenderPolicy.conservativeUnicode()
    let unicode = GlyphRenderPolicy.unicode()
    // A003 hand goldens. Scalar facts were separately measured by public displayWidth.
    for ((text, width, expected) in [
        ("A", 1, "A"), (" ", 1, " "), ("~", 1, "~"), ("界", 2, "界"),
        ("e\u{301}", 1, "e\u{301}"), ("👩", 2, "👩"), ("💻", 2, "💻"),
        ("🇨🇳", 2, "🇨🇳"), ("👩\u{200d}💻", 2, "??"),
        ("❤\u{fe0f}", 2, "??"), ("☀\u{fe0f}", 2, "??"), ("1\u{fe0f}\u{20e3}", 2, "??"),
        ("❤", 1, "❤"), ("☀", 1, "☀"), ("…", 1, "…"), ("…", 2, "??"),
        ("界", 1, "?"), ("A", 3, "???"), ("ABC", 3, "ABC"),
        ("👩\u{200d}💻", 4, "👩\u{200d}💻")
    ]) {
        advanceCheck(projectTerminalGlyph(text, width, safe) == expected, "conservative literal ${text}/${width}")
        advanceCheck(projectTerminalGlyph(text, width, unicode) == text, "Unicode exact ${text}/${width}")
    }
}

@Test
func advance_zero_negative_and_bounded_sum(): Unit {
    let safe = GlyphRenderPolicy.conservativeUnicode()
    for (policy in [safe, GlyphRenderPolicy.unicode()]) {
        advanceCheck(projectTerminalGlyph("👩\u{200d}💻", 0, policy) == "", "zero skips complete cluster")
        var rejected = false
        try { projectTerminalGlyph("A", -1, policy) }
        catch (_: IllegalArgumentException) { rejected = true }
        advanceCheck(rejected, "negative width rejected by both policies")
    }
    // A003 positive widths follow a real bounded Frame allocation; no Int64.Max string allocation.
    let bounded = Frame(7, 1, maxCells: 7)
    advanceCheck(projectTerminalGlyph("A", bounded.width, safe) == "???????", "no hard-coded width2 ceiling")
    advanceCheck(projectTerminalGlyph("界界界界", bounded.width, safe) == "???????", "sum exceeds width without wraparound")
    advanceCheck(projectTerminalGlyph("界界界A", bounded.width, safe) == "界界界A", "sum equals nonfixed budget")
    advanceCheck(projectTerminalGlyph("e\u{301}\u{301}\u{301}", 1, safe) == "e\u{301}\u{301}\u{301}", "zero scalars do not force replacement")
}

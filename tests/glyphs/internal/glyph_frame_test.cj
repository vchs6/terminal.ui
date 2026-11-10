package cjtui

import std.unittest.*
import std.unittest.testmacro.*

@Test
func glyph_device_diff_compares_projected_rows(): Unit {
    let profile = TerminalRenderProfile(colorMode: ColorMode.Monochrome,
        glyphPolicy: GlyphRenderPolicy.ascii())
    let old = Frame(4, 1)
    old.put(0, 0, "中")
    let sameWidth = Frame(4, 1)
    sameWidth.put(0, 0, "文")
    glyphCheck(sameWidth.changesSinceForTerminal(old, profile, profile) == "",
        "中 to 文 same projected question columns is silent")
    let differentStructure = Frame(4, 1)
    differentStructure.put(0, 0, "??")
    glyphCheck(differentStructure.changesSinceForTerminal(old, profile, profile) == "",
        "中 to two independent question cells is silent")
    let short = Frame(4, 1)
    short.put(0, 0, "A")
    glyphCheck(short.changesSinceForTerminal(old, profile, profile) == "\u{1b}[0m\u{1b}[1;1HA   \u{1b}[0m",
        "wide to narrow emits complete row clearing continuation and trailing columns")
}

@Test
func glyph_color_and_glyph_equivalence_is_silent(): Unit {
    let profile = TerminalRenderProfile(colorMode: ColorMode.Monochrome,
        glyphPolicy: GlyphRenderPolicy.ascii())
    let old = Frame(2, 1)
    old.put(0, 0, "中", style: Style(foreground: Color.Red))
    let current = Frame(2, 1)
    current.put(0, 0, "文", style: Style(foreground: Color.Blue))
    glyphCheck(current.changesSinceForTerminal(old, profile, profile) == "",
        "simultaneously color-equivalent and glyph-equivalent changes emit zero bytes")
}

@Test
func glyph_diff_projects_old_and_new_with_their_own_profiles(): Unit {
    let ascii = TerminalRenderProfile(colorMode: ColorMode.Monochrome,
        glyphPolicy: GlyphRenderPolicy.ascii())
    let unicode = TerminalRenderProfile(colorMode: ColorMode.Monochrome,
        glyphPolicy: GlyphRenderPolicy.unicode())
    let frame = Frame(2, 1)
    frame.put(0, 0, "é")
    glyphCheck(frame.changesSinceForTerminal(frame, unicode, ascii) == "\u{1b}[0m\u{1b}[1;1H? \u{1b}[0m",
        "same logical frame Unicode to Ascii changes output")
    glyphCheck(frame.changesSinceForTerminal(frame, ascii, unicode) == "\u{1b}[0m\u{1b}[1;1Hé \u{1b}[0m",
        "reverse profile switch uses old baseline profile")
    let plain = Frame(2, 1)
    plain.put(0, 0, "A")
    glyphCheck(plain.changesSinceForTerminal(plain, unicode, ascii) == "",
        "profile changes with equal projected bytes are silent")
}

@Test
func glyph_frame_encoder_decorations_and_logical_exports(): Unit {
    let profile = TerminalRenderProfile(colorMode: ColorMode.Monochrome,
        glyphPolicy: GlyphRenderPolicy.ascii())
    let frame = Frame(5, 3)
    frame.drawBorder(Rect(0, 0, 5, 3), border: BorderStyle.Rounded)
    frame.put(1, 1, "中")
    glyphCheck(frame.toPlainText() == "╭───╮\n│中 │\n╰───╯", "logical Unicode border and content preserved")
    glyphCheck(frame.toAnsiForTerminal(profile) == "\u{1b}[0m\u{1b}[1;1H+---+\u{1b}[2;1H|?? |\u{1b}[3;1H+---+\u{1b}[0m",
        "actual terminal encoder projects border and whole wide cluster once")
    glyphCheck(frame.toAnsi().contains("╭───╮") && frame.toAnsi().contains("│中 │"),
        "public ANSI export ignores device glyph profile")
    let zero = Frame(0, 0)
    glyphCheck(zero.toAnsiForTerminal(profile) == "", "zero-size actual encoder")
    let bounded = Frame(4, 1, maxCells: 4)
    bounded.put(0, 0, "中中")
    glyphCheck(bounded.toAnsiForTerminal(profile) == "\u{1b}[0m\u{1b}[1;1H????\u{1b}[0m", "exact Frame resource boundary")
    var rejected = false
    try { Frame(5, 1, maxCells: 4) } catch (_: IllegalArgumentException) { rejected = true }
    glyphCheck(rejected, "over-budget rejected at real Frame boundary")
}

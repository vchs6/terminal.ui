package cjtui

import std.unittest.*
import std.unittest.testmacro.*

@Test
func advance_full_and_logical_frame_contract(): Unit {
    let safe = TerminalRenderProfile(colorMode: ColorMode.Monochrome,
        glyphPolicy: GlyphRenderPolicy.conservativeUnicode())
    let frame = Frame(6, 2, maxCells: 12)
    frame.put(0, 0, "👩\u{200d}💻界A")
    frame.put(0, 1, "❤\u{fe0f}Z")
    advanceCheck(frame.toAnsiForTerminal(safe) == "\u{1b}[0m\u{1b}[1;1H??界A \u{1b}[2;1H??Z   \u{1b}[0m", "full literal projected rows")
    advanceCheck(frame.toPlainText() == "👩\u{200d}💻界A \n❤\u{fe0f}Z   ", "logical text unchanged")
    advanceCheck(frame.cellAt(0, 0).grapheme == "👩\u{200d}💻" && frame.cellAt(0, 0).width == 2 &&
        frame.cellAt(1, 0).continuation, "canonical wide head and continuation unchanged")
    advanceCheck(frame.toAnsi() == "\u{1b}[0m\u{1b}[1;1H👩\u{200d}💻界A \u{1b}[2;1H❤\u{fe0f}Z   \u{1b}[0m", "offline default Unicode bytes unchanged")
    let edge = Frame(3, 1)
    edge.put(2, 0, "👩\u{200d}💻")
    advanceCheck(edge.toAnsiForTerminal(safe) == "\u{1b}[0m\u{1b}[1;1H   \u{1b}[0m", "right edge wide cluster remains atomically clipped")
    edge.put(1, 0, "👩\u{200d}💻")
    advanceCheck(edge.toAnsiForTerminal(safe) == "\u{1b}[0m\u{1b}[1;1H ??\u{1b}[0m", "right edge fallback occupies exactly two cells")
}

@Test
func advance_diff_compares_canonical_projected_columns(): Unit {
    let safe = TerminalRenderProfile(colorMode: ColorMode.Monochrome,
        glyphPolicy: GlyphRenderPolicy.conservativeUnicode())
    let zwj = Frame(4, 1)
    zwj.put(0, 0, "👩\u{200d}💻")
    let vs = Frame(4, 1)
    vs.put(0, 0, "❤\u{fe0f}")
    let questions = Frame(4, 1)
    questions.put(0, 0, "??")
    for ((a, b) in [(zwj, vs), (vs, zwj), (zwj, questions), (questions, zwj), (vs, questions), (questions, vs)]) {
        advanceCheck(a.changesSinceForTerminal(b, safe, safe) == "", "equivalent wide-head vs independent width1 columns is silent")
    }
    let short = Frame(4, 1)
    short.put(0, 0, "A")
    advanceCheck(short.changesSinceForTerminal(zwj, safe, safe) == "\u{1b}[0m\u{1b}[1;1HA   \u{1b}[0m", "wide to narrow clears whole row")
    advanceCheck(zwj.changesSinceForTerminal(short, safe, safe) == "\u{1b}[0m\u{1b}[1;1H??  \u{1b}[0m", "narrow to wide projects delta")
}

@Test
func advance_style_groups_and_color_equivalence(): Unit {
    let safe = TerminalRenderProfile(colorMode: ColorMode.TrueColor,
        glyphPolicy: GlyphRenderPolicy.conservativeUnicode())
    let mono = TerminalRenderProfile(colorMode: ColorMode.Monochrome,
        glyphPolicy: GlyphRenderPolicy.conservativeUnicode())
    let wide = Frame(2, 1)
    wide.put(0, 0, "👩\u{200d}💻", style: Style(foreground: Color.Red))
    let grouped = Frame(2, 1)
    grouped.put(0, 0, "?", style: Style(foreground: Color.Red))
    grouped.put(1, 0, "?", style: Style(foreground: Color.Red))
    advanceCheck(grouped.changesSinceForTerminal(wide, safe, safe) == "" &&
        wide.changesSinceForTerminal(grouped, safe, safe) == "", "same style split grouping is equivalent")
    advanceCheck(wide.toAnsiForTerminal(safe) == "\u{1b}[0m\u{1b}[1;1H\u{1b}[0m\u{1b}[31m??\u{1b}[0m\u{1b}[0m", "fallback retains entire cluster style")
    grouped.put(1, 0, "?", style: Style(foreground: Color.Blue))
    advanceCheck(grouped.changesSinceForTerminal(wide, safe, safe) == "\u{1b}[0m\u{1b}[1;1H\u{1b}[0m\u{1b}[31m?\u{1b}[0m\u{1b}[34m?\u{1b}[0m", "one column style change remains visible")
    advanceCheck(grouped.changesSinceForTerminal(wide, mono, mono) == "", "color and glyph projection equality is silent")
    grouped.put(1, 0, "?", style: Style(bold: true))
    advanceCheck(grouped.changesSinceForTerminal(wide, mono, mono) != "", "supported attribute changes remain visible")
}

@Test
func advance_policy_switch_uses_both_baselines(): Unit {
    let safe = TerminalRenderProfile(colorMode: ColorMode.Monochrome,
        glyphPolicy: GlyphRenderPolicy.conservativeUnicode())
    let unicode = TerminalRenderProfile(colorMode: ColorMode.Monochrome)
    let frame = Frame(2, 1)
    frame.put(0, 0, "👩\u{200d}💻")
    advanceCheck(frame.changesSinceForTerminal(frame, unicode, safe) == "\u{1b}[0m\u{1b}[1;1H??\u{1b}[0m", "Unicode baseline to conservative")
    advanceCheck(frame.changesSinceForTerminal(frame, safe, unicode) == "\u{1b}[0m\u{1b}[1;1H👩\u{200d}💻\u{1b}[0m", "conservative baseline to Unicode")
    let literal = Frame(2, 1)
    literal.put(0, 0, "??")
    advanceCheck(literal.changesSinceForTerminal(frame, safe, unicode) == "", "policy and structure change with same actual columns is silent")
    let plain = Frame(2, 1)
    plain.put(0, 0, "界")
    advanceCheck(plain.changesSinceForTerminal(plain, unicode, safe) == "", "policy identity alone does not repaint equal columns")
    let changedSize = Frame(3, 1)
    changedSize.put(0, 0, "👩\u{200d}💻")
    advanceCheck(changedSize.changesSinceForTerminal(frame, safe, safe) == "\u{1b}[0m\u{1b}[1;1H?? \u{1b}[0m", "dimension change uses projected full output")
}

@Test
func advance_ambiguous_and_zero_area_budget(): Unit {
    let safe = TerminalRenderProfile(colorMode: ColorMode.Monochrome,
        glyphPolicy: GlyphRenderPolicy.conservativeUnicode())
    let frame = Frame(2, 1, ambiguousWide: true)
    frame.put(0, 0, "…")
    advanceCheck(frame.cellAt(0, 0).width == 2 && frame.toPlainText() == "…", "ambiguous Frame policy unchanged")
    advanceCheck(frame.toAnsiForTerminal(safe) == "\u{1b}[0m\u{1b}[1;1H??\u{1b}[0m", "device sum uses default narrow while preserving stored width2")
    for ((w, h) in [(0, 0), (0, Int64.Max), (Int64.Max, 0)]) {
        let zero = Frame(w, h)
        advanceCheck(zero.toAnsiForTerminal(safe) == "", "zero area full fast path")
        advanceCheck(zero.changesSinceForTerminal(zero, safe, safe) == "", "zero area diff fast path without huge row allocation")
    }
    let bounded = Frame(4, 1, maxCells: 4)
    bounded.put(0, 0, "👩\u{200d}💻❤\u{fe0f}")
    advanceCheck(bounded.toAnsiForTerminal(safe) == "\u{1b}[0m\u{1b}[1;1H????\u{1b}[0m", "actual Frame exact budget")
    var rejected = false
    try { Frame(5, 1, maxCells: 4) } catch (_: IllegalArgumentException) { rejected = true }
    advanceCheck(rejected, "actual over-budget Frame rejected")
}

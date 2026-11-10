package cjtui

import std.unittest.*
import std.unittest.testmacro.*

@Test
func advance_device_factory_and_color_override(): Unit {
    let caps = TerminalCapabilities(colorMode: ColorMode.TrueColor, colorKnown: true, terminfoKnown: true,
        supportsBold: true, supportsDim: false, supportsItalic: true, supportsUnderline: true,
        supportsInverse: true, supportsStrikethrough: false, noColorVideo: 0, source: "terminfo", reason: "")
    for (mode in [ColorMode.Monochrome, ColorMode.Basic8, ColorMode.Basic16, ColorMode.Indexed256, ColorMode.TrueColor]) {
        let profile = terminalRenderProfile(caps, mode)
        advanceCheck(profile.colorMode == mode && profile.supportsBold && !profile.supportsDim &&
            profile.supportsItalic && !profile.supportsStrikethrough && profile.noColorVideo == 0,
            "glyph policy preserves requested color and capability attributes")
        advanceCheck(projectTerminalGlyph("👩\u{200d}💻", 2, profile.glyphPolicy) == "??" &&
            projectTerminalGlyph("❤\u{fe0f}", 2, profile.glyphPolicy) == "??", "all explicit colors use safe device policy")
        advanceCheck(projectTerminalGlyph("👩\u{200d}💻", 2, snapshotProfile(mode).glyphPolicy) == "👩\u{200d}💻",
            "every offline color profile retains Unicode")
    }
    advanceCheck(caps.source == "terminfo" && caps.reason == "" && caps.terminfoKnown,
        "policy selection does not fabricate capability facts")
}

package cjtui

import std.unittest.*
import std.unittest.testmacro.*

@Test
func advance_existing_device_path_behavior(): Unit {
    // Uses only fixed91 interfaces: behavioral RED is separate from absent API.
    let caps = TerminalCapabilities(colorMode: ColorMode.TrueColor, colorKnown: true, terminfoKnown: true,
        supportsBold: true, supportsDim: true, supportsItalic: true, supportsUnderline: true,
        supportsInverse: true, supportsStrikethrough: true, noColorVideo: -1, source: "terminfo", reason: "")
    let frame = Frame(4, 1)
    frame.put(0, 0, "👩\u{200d}💻❤\u{fe0f}")
    advanceCheck(frame.toAnsi() == "\u{1b}[0m\u{1b}[1;1H👩\u{200d}💻❤\u{fe0f}\u{1b}[0m", "fixed offline Unicode contract")
    for (mode in [ColorMode.Monochrome, ColorMode.Basic8, ColorMode.Basic16, ColorMode.Indexed256, ColorMode.TrueColor]) {
        advanceCheck(frame.toAnsiForTerminal(terminalRenderProfile(caps, mode)) == "\u{1b}[0m\u{1b}[1;1H????\u{1b}[0m",
            "A003/A005 device byte behavior: ZWJ and VS16 become four question columns for ${mode}")
    }
}

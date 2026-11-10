package cjtui

func check(value: Bool, label: String): Unit {
    if (!value) { throw Exception("FAIL ${label}") }
    println("PASS ${label}")
}

main(): Int64 {
    let full = Style(foreground: Color.Red, bold: true, dim: true, italic: true,
        underline: true, inverse: true, strikethrough: true)
    let blank = Style(bold: true, dim: true, italic: true,
        underline: true, inverse: true, strikethrough: true)
    let profile = TerminalRenderProfile(colorMode: ColorMode.Basic8, noColorVideo: 19)
    check(projectTerminalStyle(full, profile) == Style(foreground: Color.Red), "ncv19 colored style drops all six attrs")
    check(projectTerminalStyle(blank, profile) == blank, "ncv19 uncolored style preserves all supported attrs")
    check(projectTerminalStyle(full, TerminalRenderProfile(colorMode: ColorMode.Monochrome, noColorVideo: 19)) == blank,
        "ncv19 Monochrome preserves all supported attrs")
    check(projectTerminalStyle(full, TerminalRenderProfile(colorMode: ColorMode.Basic8, noColorVideo: 18)) ==
        Style(foreground: Color.Red, bold: true, italic: true, inverse: true, strikethrough: true),
        "ncv18 still removes exactly dim and underline")
    return 0
}

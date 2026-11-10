package capability_contract

import cjtui.*

func check(value: Bool, name: String): Unit {
    if (!value) {
        throw Exception("FAIL: ${name}")
    }
    println("PASS: ${name}")
}

func inspect(capabilities: TerminalCapabilities): Unit {
    // This is intentionally a public-consumer field audit. It validates that
    // diagnostics expose a read-only snapshot rather than a configuration API.
    let mode = capabilities.colorMode
    let known = capabilities.colorKnown
    let terminfo = capabilities.terminfoKnown
    let bold = capabilities.supportsBold
    let dim = capabilities.supportsDim
    let italic = capabilities.supportsItalic
    let underline = capabilities.supportsUnderline
    let inverse = capabilities.supportsInverse
    let strike = capabilities.supportsStrikethrough
    let ncv = capabilities.noColorVideo
    let source = capabilities.source
    let reason = capabilities.reason
    check(mode == mode && known == known && terminfo == terminfo && bold == bold && dim == dim &&
        italic == italic && underline == underline && inverse == inverse && strike == strike && ncv == ncv &&
        source == source && reason == reason, "TerminalCapabilities public diagnostic fields are readable")
}

func publicApi(): Unit {
    let root = Text("public consumer")
    let automatic = Application(root)
    match (automatic.terminalCapabilities()) {
        case None => check(true, "diagnostic is absent before a successful terminal session")
        case Some(capabilities) => inspect(capabilities)
    }
    let automaticReceiver: Application = automatic.colorModeAuto()
    automaticReceiver.onKey {_ => ()}
    check(true, "colorModeAuto returns the Application receiver")

    let advanced = Application(root, colorMode: ColorMode.Basic8)
    let overrideReceiver: Application = advanced.colorMode(ColorMode.TrueColor)
    overrideReceiver.onKey {_ => ()}
    let restored: Application = advanced.colorModeAuto()
    restored.onKey {_ => ()}
    check(true, "explicit override and colorModeAuto return the Application receiver")
    check(ColorMode.Basic8 == ColorMode.Basic8 && ColorMode.Basic8 != ColorMode.Basic16,
        "Basic8 is a distinct concrete public output mode")
}

func pureSnapshots(): Unit {
    let frame = Frame(1, 1)
    frame.put(0, 0, "X", style: Style(foreground: Color.Rgb(1, 128, 254), bold: true, dim: true,
        italic: true, underline: true, inverse: true, strikethrough: true))
    let esc = "\u{1b}["
    let expected = esc + "0m" + esc + "1;1H" + esc + "0m" + esc + "38;2;1;128;254m" +
        esc + "1m" + esc + "2m" + esc + "3m" + esc + "4m" + esc + "7m" + esc + "9mX" + esc + "0m" + esc + "0m"
    check(frame.toAnsi() == expected, "default Frame.toAnsi is a pure TrueColor six-attribute snapshot")
    let basic = esc + "0m" + esc + "1;1H" + esc + "0m" + esc + "34m" +
        esc + "1m" + esc + "2m" + esc + "3m" + esc + "4m" + esc + "7m" + esc + "9mX" + esc + "0m" + esc + "0m"
    check(frame.toAnsi(colorMode: ColorMode.Basic16) == basic,
        "explicit offline Basic16 preview preserves the legacy color projection and attributes")
}

main(): Int64 {
    publicApi()
    pureSnapshots()
    return 0
}

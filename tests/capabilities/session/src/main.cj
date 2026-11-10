package capability_session

import cjtui.*
import std.env.*
import std.fs.*

foreign {
    func cjt_test_base_seed(): Int64
    func cjt_test_base_colors(): Int64
}

class SessionState {
    let reportPath: String
    var app: ?Application = None
    var seededColors: Int64 = -1

    init(reportPath: String) {
        this.reportPath = reportPath
    }
}

func modeName(mode: ColorMode): String {
    match (mode) {
        case ColorMode.Monochrome => "Monochrome"
        case ColorMode.Basic8 => "Basic8"
        case ColorMode.Basic16 => "Basic16"
        case ColorMode.Indexed256 => "Indexed256"
        case ColorMode.TrueColor => "TrueColor"
    }
}

func report(state: SessionState): Unit {
    match (state.app) {
        case None => throw Exception("missing application")
        case Some(app) =>
            match (app.terminalCapabilities()) {
                case None => throw Exception("profile missing after successful open")
                case Some(capabilities) =>
                    let text = "colorMode=${modeName(capabilities.colorMode)}\n" +
                        "colorKnown=${capabilities.colorKnown}\n" +
                        "terminfoKnown=${capabilities.terminfoKnown}\n" +
                        "bold=${capabilities.supportsBold}\n" +
                        "dim=${capabilities.supportsDim}\n" +
                        "italic=${capabilities.supportsItalic}\n" +
                        "underline=${capabilities.supportsUnderline}\n" +
                        "inverse=${capabilities.supportsInverse}\n" +
                        "strikethrough=${capabilities.supportsStrikethrough}\n" +
                        "noColorVideo=${capabilities.noColorVideo}\n" +
                        "source=${capabilities.source}\n" +
                        "reason=${capabilities.reason}\n" +
                        "baseColors=${unsafe { cjt_test_base_colors() }}\n" +
                        "seededColors=${state.seededColors}\n"
                    File.writeTo(state.reportPath, text.toArray())
            }
    }
}

main(): Int64 {
    let reportPath = getVariable("CJTUI_CAPABILITY_REPORT").getOrThrow()
    let state = SessionState(reportPath)
    if (getVariable("CJTUI_CAPABILITY_SEED").isSome()) {
        state.seededColors = unsafe { cjt_test_base_seed() }
    }
    let root = Column {
        Text("COLOR").foreground(Color.BrightRed)
        Text("RICH").foreground(Color.Rgb(1, 128, 254)).background(Color.Indexed(17))
            .bold().dim().italic().underline().inverse().strikethrough()
    }
    let app = Application(root)
    state.app = Some(app)
    if (getVariable("CJTUI_CAPABILITY_OVERRIDE").isSome()) {
        app.colorMode(ColorMode.Basic8)
    }
    app.onKey { event =>
        if (event.text == "a") {
            match (state.app) {
                case Some(current) => current.colorModeAuto()
                case None => ()
            }
        }
        if (event.text == "p") {
            report(state)
        }
        if (event.text == "q") {
            match (state.app) {
                case Some(current) => current.stop()
                case None => ()
            }
        }
    }.run()
    return 0
}

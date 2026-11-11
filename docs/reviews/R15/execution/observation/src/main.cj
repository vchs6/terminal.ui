package theme_observation
import cjtui.*
import std.env.*
import std.fs.File
main(): Int64 {
    let selected = getVariable("TASK087_PRESET").getOrThrow()
    let preset = match(selected) {
        case "Dark" => ThemePreset.Dark
        case "Light" => ThemePreset.Light
        case "HighContrast" => ThemePreset.HighContrast
        case "Classic" => ThemePreset.Classic
        case _ => throw Exception("unknown observation preset")
    }
    // Frozen tests/themes/integration/src/preset_frames.cj scene, normal public run.
    let root = Column { Text("x"); Text("y").styles([StyleUse.Named("accent")]) }
    let app = Application(root,theme:Theme.preset(preset))
    app.onKey { event =>
        match (event.text) {
            case "p" =>
                let caps=app.terminalGlyphCapabilities().getOrThrow()
                File.writeTo(getVariable("TASK087_REPORT").getOrThrow(),"preset=${selected}\nframes=${app.stats().frames}\nnativeVt=${caps.nativeVt}\nmapKnown=${caps.mapKnown}\nsource=${caps.source}\nreason=${caps.reason}\n".toArray())
            case "q" => app.stop()
            case _ => ()
        }
    }.run()
    0
}

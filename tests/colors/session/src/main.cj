package color_session
import cjtui.*
import std.env.*
import std.fs.*
// A second onKey callback acknowledges the previous event only after its run-loop render.
// No output hook, private API, sleep, or stdout sentinel participates in the oracle.
main(): Int64 {
    let directory = getVariable("CJTUI_COLOR_HANDSHAKE").getOrThrow()
    let dynamic = [Text("")]
    let fence = [Text("")]
    let root = Column {
        Text("PLAIN-UNCHANGED")
        Text("NAMED-UNCHANGED").foreground(Color.Red)
        dynamic[0] = Text("RGB-DYNAMIC").foreground(Color.Rgb(250, 0, 0))
        fence[0] = Text("EVENT-FENCE")
    }
    let app = Application(root, colorMode: ColorMode.Basic16)
    var serial = 0
    app.onKey { event =>
        match (event.text) {
            case "h" => serial++; fence[0].bold(serial % 2 == 1); File.writeTo(directory + "/ack-" + serial.toString(), [97u8, 99u8, 107u8])
            case "b" => app.colorMode(ColorMode.Basic16)
            case "i" => app.colorMode(ColorMode.Indexed256)
            case "r" => app.colorMode(ColorMode.TrueColor)
            case "m" => app.colorMode(ColorMode.Monochrome)
            case "x" => dynamic[0].foreground(Color.Rgb(249, 0, 0))
            case "y" => dynamic[0].foreground(Color.Rgb(250, 0, 0))
            case "n" => dynamic[0].foreground(Color.Red)
            case "a" => dynamic[0].foreground(Color.Indexed(1))
            case "d" => dynamic[0].foreground(Color.Default)
            case "t" => dynamic[0].bold().dim().italic().underline().inverse().strikethrough()
            case "f" => dynamic[0].bold(false).dim(false).italic(false).underline(false).inverse(false).strikethrough(false)
            case "q" => app.stop()
            case _ => ()
        }
    }.run()
    return 0
}

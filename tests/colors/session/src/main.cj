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
    let serial = [0]
    app.colorMode(ColorMode.Basic16).onKey { event =>
        if (event.text == "h") {
            serial[0]++
            fence[0].bold(serial[0] % 2 == 1)
            File.writeTo(directory + "/ack-" + serial[0].toString(), [97u8, 99u8, 107u8])
        }
        if (event.text == "b") { app.colorMode(ColorMode.Basic16) }
        if (event.text == "i") { app.colorMode(ColorMode.Indexed256) }
        if (event.text == "r") { app.colorMode(ColorMode.TrueColor) }
        if (event.text == "m") { app.colorMode(ColorMode.Monochrome) }
        if (event.text == "x") { dynamic[0].foreground(Color.Rgb(249, 0, 0)) }
        if (event.text == "y") { dynamic[0].foreground(Color.Rgb(250, 0, 0)) }
        if (event.text == "n") { dynamic[0].foreground(Color.Red) }
        if (event.text == "a") { dynamic[0].foreground(Color.Indexed(1)) }
        if (event.text == "d") { dynamic[0].foreground(Color.Default) }
        if (event.text == "t") { dynamic[0].bold().dim().italic().underline().inverse().strikethrough() }
        if (event.text == "f") { dynamic[0].bold(false).dim(false).italic(false).underline(false).inverse(false).strikethrough(false) }
        if (event.text == "q") { app.stop() }
    }.run()
    return 0
}

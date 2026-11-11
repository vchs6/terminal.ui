package glyph_capture_control
import cjtui.*
main(): Int64 {
    let app = Application(Text("capture"))
    var serial: Int64 = 0
    app.onKey { event =>
        if (event.text == "p") { serial++; println(serial) }
    }
    return 0
}

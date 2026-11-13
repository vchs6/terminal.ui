package slice_session_fixture
import cjtui.*
import std.env.*
// External application; product public API only. The last row reveals actual resize clipping.
main(): Int64 {
    let collectEvents = getVariable("CJTUI_TEST_EVENTS") == Some("1")
    let app = Application(Column {
        Text("cjtui").foreground(Color.Cyan)
        Row { Text("中文 "); Text("👩‍💻") }
        Text("0123456789ABCDEFGHIJKLMNOPQRSTUV")
    })
    app.onKey { event =>
        if (collectEvents) { println("CJTUI_TEST_EVENT:${event.code}:${event.text}") }
        if (event.text == "q") { app.stop() }
        if (!collectEvents && event.text == "e") { throw Exception("handler sentinel") }
    }.run()
    return 0
}

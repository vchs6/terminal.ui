package slice_session_fixture
import cjtui.*
// External application; product public API only. The last row reveals actual resize clipping.
main(): Int64 {
    let app = Application(Column {
        Text("cjtui").foreground(Color.Cyan)
        Row { Text("中文 "); Text("👩‍💻") }
        Text("0123456789ABCDEFGHIJKLMNOPQRSTUV")
    })
    app.onKey { event =>
        if (event.text == "q") { app.stop() }
        if (event.text == "e") { throw Exception("handler sentinel") }
    }.run()
    return 0
}

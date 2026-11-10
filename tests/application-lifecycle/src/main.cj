package application_lifecycle
import cjtui.*
main(): Int64 {
    let app = Application(Column {
        Text("CJTUI_LIFECYCLE_READY")
        Text("0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ")
    })
    app.onKey { event =>
        if (event.text == "q") { app.stop() }
        if (event.text == "e") { throw Exception("CJTUI_CALLBACK_SENTINEL") }
    }.run()
    return 0
}

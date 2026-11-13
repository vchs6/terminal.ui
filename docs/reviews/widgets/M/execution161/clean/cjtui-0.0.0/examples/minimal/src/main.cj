package cjtui_minimal
import cjtui.*
main(): Int64 {
    let app = Application(Column {
        Text("cjtui").foreground(Color.Cyan)
        Row { Text("中文 "); Text("👩‍💻") }
    })
    app.onKey { event => if (event.text == "q") { app.stop() } }.run()
    return 0
}

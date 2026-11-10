package resize_coherence

import cjtui.*

main(): Int64 {
    let app = Application(Column {
        Text("CJTUI_COHERENCE_READY")
        Text("0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ")
    })
    app.onKey({ event => if (event.text == "q") { app.stop() } }).run()
    return 0
}

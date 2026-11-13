package cjtui_keyboard_example
import cjtui.*

main(): Int64 {
    let app = Application(Text("Type keys; press q to quit").focusable(true))
    app.onKeyEvent({ event =>
        if (event.key.code == "text" && event.key.text == "q") { app.stop() }
    })
    app.run()
    0
}

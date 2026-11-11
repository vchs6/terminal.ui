package viewport_example

import cjtui.*
import std.env.getCommandLine

main(): Int64 {
    let root = Column {
        Text("Viewport example — Tab changes focus; q quits").height(1)
        ScrollView {
            for (i in 0..30) { Text("Item ${i}") }
        }.layoutWeight(1)
        Row { Text("Name       | Status       | Owner        | Updated") }
            .height(1).viewport(ScrollAxes.Horizontal).focusable(true)
        Text("Up/Down scroll the list; Left/Right scroll the table.").height(1)
    }
    let app = Application(root)
    app.onKey({event => if (event.text == "q") { app.stop() }})
    if (getCommandLine().contains("--smoke")) {
        app.startHeadless()
        try {
            let frame = app.snapshot(30,8)
            if (frame.toPlainText().isEmpty()) { throw Exception("empty viewport snapshot") }
            println("PASS viewport example")
        } finally { app.dispose() }
    } else { app.run() }
    0
}

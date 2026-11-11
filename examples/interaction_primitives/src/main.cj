package interaction_primitives

import cjtui.*
import std.env.getCommandLine

main(): Int64 {
    let progress = Observable<Int64>(1)
    let button = {=> Text("Press Enter").focusable(true).defaultAction({event =>
        if (event.key.code == "enter") {
            progress.set(if (progress.get() == 1) { 2 } else { 1 })
            event.preventDefault()
        }
    }) }
    let bar = {=> Canvas({constraints => constraints.constrain(Size(3,1))}, {context =>
        context.fill(Rect(0,0,3,1))
        context.put(0,0,if (progress.get() == 1) { "#.." } else { "##." })
    }) }
    let caret = {=> Canvas({constraints => constraints.constrain(Size(3,1))}, {context =>
        context.put(0,0,"xy ")
        context.caret(2,0)
    }).focusable(true) }
    let root = Column { button(); bar(); caret() }
    let app = Application(root)
    app.onKey({event => if (event.text == "q") { app.stop() }})
    if (getCommandLine().contains("--smoke")) {
        app.startHeadless()
        try {
            let frame = app.snapshot(12,3)
            if (frame.toPlainText().isEmpty()) { throw Exception("empty interaction snapshot") }
            println("PASS interaction primitives")
        } finally { app.dispose() }
    } else { app.run() }
    0
}

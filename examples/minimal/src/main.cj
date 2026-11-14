package cjtui_minimal
import cjtui.*
import std.env.getCommandLine

main(): Int64 {
    let args = getCommandLine()
    if (args.size > 2 || (args.size == 2 && args[1] != "--smoke")) {
        println("Usage: main [--smoke]")
        return 1
    }
    let app = Application(Column {
        Text("cjtui").foreground(Color.Cyan)
        Row { Text("中文 "); Text("👩‍💻") }
    })
    if (args.size == 2) {
        app.startHeadless()
        try {
            let frame = app.snapshot(16, 3).toPlainText()
            if (!frame.contains("cjtui") || !frame.contains("中文")) { throw Exception("minimal startup failed") }
            println("BEGIN minimal 16x3")
            println(frame)
            println("END minimal")
            println("PASS minimal")
        } finally { app.dispose() }
    } else {
        app.onKey { event => if (event.text == "q") { app.stop() } }.run()
    }
    return 0
}

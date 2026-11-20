package cjtui_composition
import cjtui.*
import std.env.getCommandLine

main(): Int64 {
    let args = getCommandLine()
    if (args.size > 2 || (args.size == 2 && args[1] != "--smoke")) {
        println("Usage: main [--smoke]")
        return 1
    }
    let data = JobData()
    let commands = Commands(data)
    let app = Application(ApplicationView(data, commands).viewport(ScrollAxes.Off).alignItems(Alignment.Stretch))
    commands.app = Some(app)
    app.onKeyEvent({event => commands.global(event.key.code)})
    if (args.size == 2) {
        app.startHeadless()
        try {
            for (size in [(80, 24), (40, 12), (16, 6)]) {
                println("BEGIN tasks ${size[0]}x${size[1]}")
                println(app.snapshot(size[0], size[1]).toPlainText())
                println("END tasks")
            }
            app.batch({=> commands.scene(true)})
            for (size in [(80, 24), (40, 12), (16, 6)]) {
                println("BEGIN logs ${size[0]}x${size[1]}")
                println(app.snapshot(size[0], size[1]).toPlainText())
                println("END logs")
            }
            if (data.stage.get() != 0 || data.hideDone.get() || data.nameOrder.get() || !data.query.get().isEmpty() ||
                data.taskRows().size != 3 || data.logRows().size != 24 || !data.logQuery.get().isEmpty() ||
                data.errorsOnly.get() || data.newest.get() || data.notes.get() != "Check input") {
                throw Exception("business startup state failed")
            }
            println("STATE tasks ready=2 done=1 visible=${data.taskRows().size} notes=${data.notes.get()}")
            println("STATE logs total=24 visible=${data.logRows().size} query=${data.logQuery.get()} errorsOnly=${data.errorsOnly.get()} order=oldest")
            println("PASS composition")
        } finally { app.dispose() }
    } else { app.run() }
    0
}

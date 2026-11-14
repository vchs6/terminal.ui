package cjtui_theme_showcase
import cjtui.*
import std.env.getCommandLine

main(): Int64 {
    let args = getCommandLine()
    let smoke = args.size == 2 && args[1] == "--smoke"
    if (!(args.size == 1 || smoke || (args.size == 3 && args[1] == "--theme-file" && !args[2].isEmpty() && !args[2].startsWith("--")))) {
        println("Usage: main [--smoke | --theme-file PATH]")
        return 1
    }
    let file: ?String = if (args.size == 3) { Some(args[2]) } else { None }
    if (smoke) { runSmoke(); return 0 }
    let data = GalleryData()
    let commands = Commands(data, file)
    let app = Application(GalleryView(data, commands).viewport(ScrollAxes.Off).alignItems(Alignment.Stretch))
    commands.app = Some(app)
    app.onKeyEvent({event => commands.action(event.key.code)})
    app.run()
    0
}

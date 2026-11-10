package clean_consumer
import cjtui.*
import std.env.*
import std.fs.*
main(): Int64 {
    let output = getVariable("CJTUI_CONSUMER_OUTPUT").getOrThrow()
    let root = Column {
        Text("CLEAN-CONSUMER").foreground(Color.Cyan)
        Text("RGB 中 👩‍💻").foreground(Color.Rgb(250, 0, 0)).bold().italic()
    }
    let frame = render(root, 40, 6)
    File.writeTo(output + "/snapshot.txt", frame.toPlainText().toArray())
    File.writeTo(output + "/snapshot.ansi", frame.toAnsi().toArray())
    match (getVariable("CJTUI_CONSUMER_INTERACTIVE")) {
        case Some(_) =>
            let app = Application(root)
            app.onKey { event => if (event.text == "q") { app.stop() } }.run()
        case None => println("snapshot export complete")
    }
    return 0
}

package editing_example

import cjtui.*
import std.env.getCommandLine

main(): Int64 {
    let name = Observable<String>("")
    let notes = Observable<String>("")
    let message = Observable<String>("Tab changes focus; Ctrl-C exits without a selection.")
    let editor = TextEditController()
    let root = Column {
        Text({=> message.get()}).height(1)
        TextInput(name, controller: Some(editor), onSubmit: {value => message.set("Hello, " + value)}).height(1)
        TextArea(notes).height(4)
    }
    let app = Application(root)
    if (getCommandLine().contains("--smoke")) {
        app.startHeadless()
        try {
            app.batch({=> editor.replaceSelection("Ada")})
            if (name.get() != "Ada") {
                throw Exception("editing smoke failed")
            }
            println("PASS editing example")
        } finally {
            app.dispose()
        }
    } else {
        app.run()
    }
    0
}

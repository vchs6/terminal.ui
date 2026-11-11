package overlay_example
import cjtui.*
import std.env.getCommandLine

main(): Int64 {
    let model = Observable<String>("Shared setting")
    let open = Text("Enter: open modal; Escape: close; q: quit").focusable(true)
    let root = Column { open; SettingsPanel(model) }.viewport(ScrollAxes.Off)
    open.defaultAction({event =>
        if (event.key.code == "enter") {
            event.currentTarget.openOverlay(SettingsPanel(model).width(20).height(3),
                options:OverlayOptions(mode:OverlayMode.Modal))
            event.preventDefault()
        }
    })
    let app = Application(root)
    app.onKey({event => if (event.text == "q") { app.stop() }})
    if (getCommandLine().contains("--smoke")) {
        app.startHeadless()
        try {
            let handle = BoxOverlay()
            app.batch({=> handle.value = Some(root.reference().getOrThrow().openOverlay(
                SettingsPanel(model).width(20).height(3),options:OverlayOptions(mode:OverlayMode.Modal))) })
            model.set("Updated setting")
            if (!app.snapshot(30,5).toPlainText().contains("Updated setting")) { throw Exception("missing shared setting") }
            app.batch({=> handle.value.getOrThrow().close()})
            println("PASS overlay example")
        } finally { app.dispose() }
    } else { app.run() }
    0
}

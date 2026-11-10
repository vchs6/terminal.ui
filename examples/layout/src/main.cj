package cjtui_layout
import cjtui.*

class Panels {
    var left = Text("")
    var right = Text("")
    var decorated = true
    func toggle(): Unit {
        decorated = !decorated
        let border = if (decorated) { BorderStyle.Rounded } else { BorderStyle.None }
        left.border(border).shadow(enabled: decorated)
        right.border(border).shadow(enabled: decorated)
    }
}
main(): Int64 {
    let panels = Panels()
    let root = Column {
        Text("cjtui layout").foreground(Color.Cyan)
        Row {
            panels.left = Column { Text("Projects"); Text("Terminal UI") }
                .layoutWeight(1).height(6).padding(1).border(BorderStyle.Rounded).shadow()
            panels.right = Column { Text("Details"); Text("Shared layout") }
                .layoutWeight(1).height(6).padding(1).border(BorderStyle.Rounded).shadow()
        }.layoutWeight(1).gap(2).padding(1)
        Text("d: decoration   q: quit")
    }
    let app = Application(root)
    app.onKey { event =>
        if (event.text == "q") { app.stop() }
        else if (event.text == "d") { panels.toggle() }
    }.run()
    return 0
}

package dynamic_example

import cjtui.*
import std.env.getCommandLine

main(): Int64 {
    let items = Observable<Array<String>>(["A", "B", "C"])
    let show = Observable<Bool>(true)
    let root = Column {
        Text("r: reverse   e: empty/refill   i: insert manual   v: toggle   q: quit")
        If({=> show.get()}, {=> Text("Declared and manual children share one sequence")})
        ForEach<String>({=> items.get()}, {value => value}, {
            item => Text({=> item.value}).foreground(Color.Cyan)
        })
    }
    let app = Application(root)
    app.onKey {
        event => if (event.text == "q") {
            app.stop()
        } else if (event.text == "r") {
            items.set(["C", "B", "A"])
        } else if (event.text == "e") {
            items.set(if (items.get().isEmpty()) {
                ["D", "E"]
            } else {
                []
            })
        } else if (event.text == "v") {
            show.set(!show.get())
        } else if (event.text == "i") {
            let parent = root.reference().getOrThrow()
            let children = parent.children()
            let manual = Text("manual").foreground(Color.Yellow)
            if (children.size > 2) {
                parent.insertBefore(children[2], manual)
            } else {
                parent.append(manual)
            }
        }
    }
    if (getCommandLine().contains("--smoke")) {
        app.startHeadless()
        try {
            app.batch {
                =>
                    let parent = root.reference().getOrThrow()
                    parent.insertBefore(parent.children()[3], Text("manual"))
                    items.set(["C", "B", "A"])
            }
            app.snapshot(72, 8)
        } finally {
            app.dispose()
        }
    } else {
        app.run()
    }
    0
}

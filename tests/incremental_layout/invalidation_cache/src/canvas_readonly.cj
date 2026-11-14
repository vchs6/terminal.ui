package incremental_invalidation_cache

import cjtui.*

// Breaks: focus/enabled readonly inputs are absent from cached Canvas draw dependencies.
func canvasReadonly(): Unit {
    let epoch = [Int64(0)]
    let enabled = Observable<Bool>(true)
    let root = Column {
        Canvas({ _ => Size(2, 1) }, { context =>
            context.put(0, 0, if (!context.enabled) { "D" } else if (context.focused) { "F" } else { "U" })
        }).focusable(true).enabled({ => enabled.get() })
        Text("Z").focusable(true)
    }
    let app = Application(root)
    app.startHeadless()
    try {
        paired(app, root, epoch, 2, 2, "F \nZ ", "Canvas readonly initial focus")
        let canvas = root.reference().getOrThrow().children()[0]
        let other = root.reference().getOrThrow().children()[1]
        advance(app, epoch, { => other.requestFocus() })
        paired(app, root, epoch, 2, 2, "U \nZ ", "Canvas readonly focus leaves").noLayout()
        advance(app, epoch, { => canvas.requestFocus() })
        paired(app, root, epoch, 2, 2, "F \nZ ", "Canvas readonly focus changes").noLayout()
        advance(app, epoch, { => enabled.set(false) })
        paired(app, root, epoch, 2, 2, "D \nZ ", "Canvas readonly enabled changes").noLayout()
        advance(app, epoch, { => enabled.set(true) })
        paired(app, root, epoch, 2, 2, "U \nZ ", "Canvas readonly enabled restored").noLayout()
    } finally { app.dispose() }
}

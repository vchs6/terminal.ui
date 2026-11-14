package incremental_invalidation_cache

import cjtui.*

// Breaks: Canvas draw input remeasures, measure input is lost, or transient M1 replaces dependencies.
func canvasDependencies(): Unit {
    let epoch = [Int64(0)]
    let height = Observable<Int64>(1)
    let wide = Observable<String>("A")
    let narrow = Observable<String>("N")
    let root = Column {
        Canvas({ _ => Size(3, height.get()) }, { context =>
            context.put(0, 0, if (context.size.width >= 3) { wide.get() } else { narrow.get() })
            if (context.size.height > 1) { context.put(0, 1, "!") }
        })
        Column { Text("B"); Text("C") }
    }
    let app = Application(root)
    app.startHeadless()
    try {
        paired(app, root, epoch, 4, 4, "A   \nB   \nC   \n    ", "Canvas separate inputs initial")
        let stock = app.stats().subscriptions
        let different = render(root, 2, 4)
        check(different.toPlainText() == "N \nB \nC \n  ", "narrow transient draw input")
        check(app.stats().subscriptions == stock, "transient reference has no persistent subscription")
        advance(app, epoch, { => narrow.set("n") })
        paired(app, root, epoch, 4, 4, "A   \nB   \nC   \n    ", "transient narrow dependency detached").noTarget()
        advance(app, epoch, { => wide.set("D") })
        paired(app, root, epoch, 4, 4, "D   \nB   \nC   \n    ", "Canvas draw-only dependency").noLayout()
        advance(app, epoch, { => height.set(2) })
        paired(app, root, epoch, 4, 4, "D   \n!   \nB   \nC   ", "Canvas measure-only height moves siblings").reducedMeasure()
        advance(app, epoch, { => wide.set("E") })
        paired(app, root, epoch, 4, 4, "E   \n!   \nB   \nC   ", "draw subscription retained after measure").noLayout()
        advance(app, epoch, { => height.set(1) })
        paired(app, root, epoch, 4, 4, "E   \nB   \nC   \n    ", "measure subscription retained after draw").reducedMeasure()
    } finally { app.dispose() }
}

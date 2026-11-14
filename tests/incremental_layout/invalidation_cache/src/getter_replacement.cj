package incremental_invalidation_cache

import cjtui.*

// Breaks: equal getter results produce work; constant replacement leaves a subscription/getter alive.
func getterReplacement(): Unit {
    let epoch = [Int64(0)]
    let source = Observable<Int64>(1)
    let width = Observable<Int64>(3)
    var captured: ?Component = None
    let root = Column {
        captured = Some(Text({ => if (source.get() > 0) { "yes" } else { "no" } }).width({ => width.get() }))
        Text("Z")
    }
    let leaf = captured.getOrThrow()
    let app = Application(root)
    app.startHeadless()
    try {
        paired(app, root, epoch, 4, 2, "yes \nZ   ", "getter initial")
        advance(app, epoch, { => source.set(2); width.set(3) })
        paired(app, root, epoch, 4, 2, "yes \nZ   ", "typed equal String and Int64").noTarget()
        advance(app, epoch, { => source.notify(); width.notify() })
        paired(app, root, epoch, 4, 2, "yes \nZ   ", "Observable notify equal output").noTarget()
        advance(app, epoch, { => leaf.text("fix"); leaf.width(3) })
        paired(app, root, epoch, 4, 2, "fix \nZ   ", "constants replace getters")
        let stock = app.stats().subscriptions
        check(stock == 0, "both replaced getters release subscriptions")
        advance(app, epoch, { => source.set(0); width.set(1) })
        paired(app, root, epoch, 4, 2, "fix \nZ   ", "old sources detached").noTarget()
        advance(app, epoch, { => leaf.text({ => if (source.get() > 0) { "yes" } else { "no" } }) })
        paired(app, root, epoch, 4, 2, "no  \nZ   ", "getter restored")
    } finally { app.dispose() }
}

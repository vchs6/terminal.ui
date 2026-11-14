package incremental_invalidation_cache

import cjtui.*

// Breaks: hidden node invalidations are consumed before visibility returns; If sequence stale.
func hiddenUpdates(): Unit {
    let epoch = [Int64(0)]
    let visible = Observable<Bool>(true)
    let branch = Observable<Bool>(false)
    let content = Observable<String>("A")
    let root = Column {
        Text({ => content.get() }).visible({ => visible.get() })
        If({ => branch.get() }, { => Text("I") })
        Text("Z")
    }
    let app = Application(root)
    app.startHeadless()
    try {
        paired(app, root, epoch, 2, 4, "A \nZ \n  \n  ", "visible initial")
        let ref = root.reference().getOrThrow().children()[0]
        advance(app, epoch, { => visible.set(false) })
        paired(app, root, epoch, 2, 4, "Z \n  \n  \n  ", "hidden removed from layout")
        advance(app, epoch, { => content.set("B\nC"); branch.set(true) })
        paired(app, root, epoch, 2, 4, "I \nZ \n  \n  ", "hidden pending content and If insertion")
        check(ref.isValid(), "hidden node remains mounted")
        advance(app, epoch, { => visible.set(true) })
        paired(app, root, epoch, 2, 4, "B \nC \nI \nZ ", "latest hidden content restored")
        check(root.reference().getOrThrow().children()[0].sameNode(ref), "visible returns same identity")
        advance(app, epoch, { => branch.set(false); content.set("Q") })
        paired(app, root, epoch, 2, 4, "Q \nZ \n  \n  ", "If removal and latest text")
    } finally { app.dispose() }
}

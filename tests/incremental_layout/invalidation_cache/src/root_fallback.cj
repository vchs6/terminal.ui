package incremental_invalidation_cache

import cjtui.*

// Breaks: finite/fallback constraint stages share an invalid key or overflow loss leaves stale scroll.
func rootFallback(): Unit {
    let epoch = [Int64(0)]
    let first = Observable<String>("A")
    let root = Column {
        Text({ => first.get() }).layoutWeight(1)
        Text("B\nB\nB").layoutWeight(1)
    }
    let app = Application(root)
    app.startHeadless()
    try {
        paired(app, root, epoch, 1, 10, "A\n \n \n \n \nB\nB\nB\n \n ", "root finite 5/5")
        let ref = root.reference().getOrThrow()
        check(ref.viewportSnapshot().contentHeight == 10, "finite root content extent")
        advance(app, epoch, { => first.set("A\nA\nA\nA\nA\nA\nA\nA") })
        paired(app, root, epoch, 1, 10, "A\nA\nA\nA\nA\nA\nA\nA\nB\nB", "root finite overflow switches to natural 8/3")
        check(ref.viewportSnapshot().contentHeight == 11, "fallback root content extent")
        advance(app, epoch, { => check(ref.scrollTo(0, 1), "root scroll accepts final row") })
        paired(app, root, epoch, 1, 10, "A\nA\nA\nA\nA\nA\nA\nB\nB\nB", "root scroll translation").reducedMeasure()
        advance(app, epoch, { => first.set("A") })
        paired(app, root, epoch, 1, 10, "A\n \n \n \n \nB\nB\nB\n \n ", "root shrink returns finite input")
        check(ref.viewportSnapshot().offsetY == 0 && ref.viewportSnapshot().contentHeight == 10, "root offset clamped after shrink")
        advance(app, epoch, { => first.set("A\nA\nA\nA\nA\nA\nA\nA") })
        paired(app, root, epoch, 1, 10, "A\nA\nA\nA\nA\nA\nA\nA\nB\nB", "root repeated overflow cannot reuse finite result")
    } finally { app.dispose() }
}

package incremental_invalidation_cache

import cjtui.*

// Breaks: natural-height changes fail to move preceding/following nodes under center/end.
func columnJustification(): Unit {
    let epoch = [Int64(0)]
    let middle = Observable<String>("B")
    let alignment = Observable<Alignment>(Alignment.Center)
    let root = Column { Text("A"); Text({ => middle.get() }); Text("Z") }.justifyContent({ => alignment.get() })
    let app = Application(root)
    app.startHeadless()
    try {
        paired(app, root, epoch, 1, 7, " \n \nA\nB\nZ\n \n ", "column centered three")
        advance(app, epoch, { => middle.set("B\nB\nB") })
        paired(app, root, epoch, 1, 7, " \nA\nB\nB\nB\nZ\n ", "column centered height moves before and after").reducedMeasure()
        advance(app, epoch, { => alignment.set(Alignment.End) })
        paired(app, root, epoch, 1, 7, " \n \nA\nB\nB\nB\nZ", "column end position only").reducedMeasure()
        advance(app, epoch, { => middle.set("B") })
        paired(app, root, epoch, 1, 7, " \n \n \n \nA\nB\nZ", "column end shrink")
    } finally { app.dispose() }
}

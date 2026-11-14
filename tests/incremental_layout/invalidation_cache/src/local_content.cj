package incremental_invalidation_cache

import cjtui.*

// Breaks: one changed leaf causes measurement/arrangement of unrelated nested panels.
func localContent(): Unit {
    let epoch = [Int64(0)]
    let value = Observable<String>("AA")
    let root = Column {
        Column { Text({ => value.get() }); Text("B") }.height(2)
        Column { Row { Text("C"); Text("D") }; Text("E") }.height(2)
        Column { Text("F"); Row { Text("G"); Text("H") } }.height(2)
    }
    let app = Application(root)
    app.startHeadless()
    try {
        paired(app, root, epoch, 4, 6, "AA  \nB   \nCD  \nE   \nF   \nGH  ", "separated panels initial")
        advance(app, epoch, { => value.set("ZZ") })
        let sample = paired(app, root, epoch, 4, 6, "ZZ  \nB   \nCD  \nE   \nF   \nGH  ", "same width local leaf")
        sample.reducedMeasure(); sample.reducedArrange()
        advance(app, epoch, { => value.set("Q") })
        paired(app, root, epoch, 4, 6, "Q   \nB   \nCD  \nE   \nF   \nGH  ", "shorter local leaf").reducedMeasure()
    } finally { app.dispose() }
}

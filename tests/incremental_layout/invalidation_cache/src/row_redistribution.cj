package incremental_invalidation_cache

import cjtui.*

// Breaks: fixed sibling growth fails to redistribute flex widths/remainders or keeps stale wrap height.
func rowRedistribution(): Unit {
    let epoch = [Int64(0)]
    let fixed = Observable<String>("X")
    let root = Column {
        Row { Text({ => fixed.get() }); Text("AAAA").layoutWeight(1); Text("BBBB").layoutWeight(1) }
        Text("Z")
    }
    let app = Application(root)
    app.startHeadless()
    try {
        paired(app, root, epoch, 8, 2, "XAAAABBB\nZ       ", "row remainder initial 1/4/3")
        advance(app, epoch, { => fixed.set("XX") })
        paired(app, root, epoch, 8, 2, "XXAAABBB\nZ       ", "row sibling redistribution 2/3/3")
        advance(app, epoch, { => fixed.set("XXX") })
        paired(app, root, epoch, 8, 2, "XXXAAABB\nZ       ", "row remainder changes 3/3/2")
        paired(app, root, epoch, 9, 2, "XXXAAABBB\nZ        ", "row width changes flex input")
        paired(app, root, epoch, 8, 2, "XXXAAABB\nZ       ", "row width restored")
    } finally { app.dispose() }
}

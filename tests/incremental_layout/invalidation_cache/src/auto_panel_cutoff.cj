package incremental_invalidation_cache

import cjtui.*

// F4: no fixed-height barriers; same-size output cannot reallocate unrelated nested auto panels.
func autoPanelCutoff(): Unit {
    let epoch = [Int64(0)]
    let value = Observable<String>("a0")
    let root = Column {
        Column { Column {
            Text({ => value.get() }); Text("a1"); Text("a2"); Text("a3")
            Text("a4"); Text("a5"); Text("a6"); Text("a7")
        } }
        Column { Column {
            Text("b0"); Text("b1"); Text("b2"); Text("b3")
            Text("b4"); Text("b5"); Text("b6"); Text("b7")
        } }
        Column { Column {
            Text("c0"); Text("c1"); Text("c2"); Text("c3")
            Text("c4"); Text("c5"); Text("c6"); Text("c7")
        } }
    }
    let app = Application(root)
    app.startHeadless()
    try {
        paired(app, root, epoch, 3, 24, "a0 \na1 \na2 \na3 \na4 \na5 \na6 \na7 \nb0 \nb1 \nb2 \nb3 \nb4 \nb5 \nb6 \nb7 \nc0 \nc1 \nc2 \nc3 \nc4 \nc5 \nc6 \nc7 ", "F4 auto panels initial")
        advance(app, epoch, { => value.set("q0") })
        let sample = paired(app, root, epoch, 3, 24, "q0 \na1 \na2 \na3 \na4 \na5 \na6 \na7 \nb0 \nb1 \nb2 \nb3 \nb4 \nb5 \nb6 \nb7 \nc0 \nc1 \nc2 \nc3 \nc4 \nc5 \nc6 \nc7 ", "F4 same-size leaf auto panels")
        // Four-node affected path; at most two finite/fallback passes and two geometry walks per pass.
        let pathNodes: Int64 = 4
        let arrangeBound = pathNodes * 2 * 2
        let actualArranges = sample.after.arranges - sample.before.arranges
        println("F4 tree_nodes=31 affected_path=4 conservative_arrange_bound=${arrangeBound} actual_arranges=${actualArranges}")
        WorkChecks.verify(actualArranges <= arrangeBound, "F4 unchanged auto-panel subtrees exceed affected-path arrange bound")
    } finally { app.dispose() }
}

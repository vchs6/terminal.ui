package incremental_invalidation_cache

import cjtui.*

// Breaks: explicit invalidation is discarded merely because a constant leaf has no getter.
func explicitNotify(): Unit {
    let epoch = [Int64(0)]
    var captured: ?Component = None
    let root = Column { captured = Some(Text("A")); Column { Text("B"); Text("C") } }
    let leaf = captured.getOrThrow()
    let app = Application(root)
    app.startHeadless()
    try {
        paired(app, root, epoch, 2, 3, "A \nB \nC ", "notify initial")
        let ref = leaf.reference().getOrThrow()
        advance(app, epoch, { => ref.notify(ChangeKind.Bindings) })
        paired(app, root, epoch, 2, 3, "A \nB \nC ", "Bindings constant").noTarget()
        advance(app, epoch, { => ref.notify(ChangeKind.Style) })
        let style = paired(app, root, epoch, 2, 3, "A \nB \nC ", "Style constant")
        style.noLayout()
        check(style.after.paints > style.before.paints, "Style notification still paints")
        for (kind in [ChangeKind.Content, ChangeKind.Layout, ChangeKind.All]) {
            advance(app, epoch, { => ref.notify(kind) })
            let sample = paired(app, root, epoch, 2, 3, "A \nB \nC ", "explicit content/layout/all")
            check(sample.after.measures > sample.before.measures, "explicit content/layout/all invalidates leaf measure")
            sample.reducedMeasure()
        }
    } finally { app.dispose() }
}

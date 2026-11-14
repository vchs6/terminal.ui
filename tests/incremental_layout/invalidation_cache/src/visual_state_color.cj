package incremental_invalidation_cache

import cjtui.*

// F2: unequal visual states with foreground-only effective output are paint-only.
func visualStateColor(): Unit {
    let epoch = [Int64(0)]
    let states = Observable<VisualStates>(VisualStates())
    let root = Column {
        Text("A").foreground(Color.Red)
            .setStyle(StyleKeys.foreground, StyleValue<Color>.Value(Color.Blue), state: VisualState.Selected)
            .visualStates({ => states.get() })
        Text("Z")
    }
    let app = Application(root)
    app.startHeadless()
    try {
        let first = paired(app, root, epoch, 2, 2, "A \nZ ", "F2 visual normal red")
        check(first.frame.cellAt(0, 0).style.foreground == Color.Red, "F2 initial normal red Cell")
        advance(app, epoch, { => states.set(VisualStates(selected: true)) })
        let changed = paired(app, root, epoch, 2, 2, "A \nZ ", "F2 visual selected color-only output")
        check(changed.frame.cellAt(0, 0).style.foreground == Color.Blue, "F2 selected blue Cell changed")
        changed.noLayout()
    } finally { app.dispose() }
}

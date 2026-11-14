package incremental_invalidation_cache

import cjtui.*

// F2: unequal reusable style declarations with equal geometry are paint-only.
func reusableStyleColor(): Unit {
    let epoch = [Int64(0)]
    let red = StyleRule().withValue(StyleKeys.foreground, StyleValue<Color>.Value(Color.Red))
    let blue = StyleRule().withValue(StyleKeys.foreground, StyleValue<Color>.Value(Color.Blue))
    let styles = Observable<Array<StyleUse>>([StyleUse.Inline(red)])
    let root = Column { Text("A").styles({ => styles.get() }); Text("Z") }
    let app = Application(root)
    app.startHeadless()
    try {
        let first = paired(app, root, epoch, 2, 2, "A \nZ ", "F2 reusable red")
        check(first.frame.cellAt(0, 0).style.foreground == Color.Red, "F2 initial reusable red Cell")
        advance(app, epoch, { => styles.set([StyleUse.Inline(blue)]) })
        let changed = paired(app, root, epoch, 2, 2, "A \nZ ", "F2 unequal reusable color-only style")
        check(changed.frame.cellAt(0, 0).style.foreground == Color.Blue, "F2 reusable blue Cell changed")
        changed.noLayout()
    } finally { app.dispose() }
}

package incremental_invalidation_cache

import cjtui.*

// Breaks: full reference consumes pending dirty or replaces the persistent actual-constraint cache.
func referenceCache(): Unit {
    let epoch = [Int64(0)]
    let value = Observable<String>("abcd")
    let root = Column { Text({ => value.get() }).wrap(TextWrap.Grapheme); Text("Z") }
    let app = Application(root)
    app.startHeadless()
    try {
        paired(app, root, epoch, 4, 3, "abcd\nZ   \n    ", "reference cache initial")
        check(render(root, 2, 3).toPlainText() == "ab\ncd\nZ ", "temporary reference width")
        paired(app, root, epoch, 4, 3, "abcd\nZ   \n    ", "reference width does not replace target cache").noTarget()
        advance(app, epoch, { => value.set("xy") })
        check(render(root, 4, 3).toPlainText() == "xy  \nZ   \n    ", "reference sees stabilized latest input")
        paired(app, root, epoch, 4, 3, "xy  \nZ   \n    ", "reference preserves target dirty").reducedMeasure()
        paired(app, root, epoch, 4, 3, "xy  \nZ   \n    ", "stable after successful target").noTarget()
    } finally { app.dispose() }
}

package incremental_invalidation_cache

import cjtui.*

// R1-N2: a policy root-cache miss must revalidate pending nested text before painting cached lines.
func rootCacheMissText(): Unit {
    let epoch = [Int64(0)]
    let value = Observable<String>("abc")
    let root = Column { Column { Text({ => value.get() }) } }
    let app = Application(root)
    app.startHeadless()
    try {
        paired(app, root, epoch, 3, 1, "abc", "R1-N2 warm nested Unicode text")
        app.batch({ => value.set("q"); epoch[0]++ })
        let stable = epoch[0]
        println("R1-N2 next_target=Ascii3x1 expected=[q  ] epoch=${stable}")
        let actual = app.snapshot(3, 1, glyphMode: GlyphMode.Ascii)
        let full = render(root, 3, 1, glyphMode: GlyphMode.Ascii)
        check(epoch[0] == stable, "R1-N2 stable text/policy epoch")
        check(full.toPlainText() == "q  ", "R1-N2 independent full literal")
        equalCells(actual, full, "R1-N2 nested text with root cache miss")
        check(actual.toPlainText() == "q  ", "R1-N2 target literal")
        println("R1-N2 target completed literal=[${actual.toPlainText()}]")
    } finally { app.dispose() }
}

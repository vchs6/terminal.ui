package incremental_invalidation_cache

import cjtui.*

func paired(app: Application, root: Component, epoch: Array<Int64>, width: Int64, height: Int64,
    expected: String, label: String, glyphMode!: GlyphMode = GlyphMode.Unicode): WorkSample {
    let stable = epoch[0]
    let before = app.stats()
    let actual = app.snapshot(width, height, glyphMode: glyphMode)
    let after = app.stats()
    let reference = render(root, width, height, glyphMode: glyphMode)
    let full = app.stats()
    check(epoch[0] == stable, "${label}: stable business epoch")
    equalCells(actual, reference, label)
    check(actual.toPlainText() == expected, "${label}: literal layout actual=[${actual.toPlainText()}] expected=[${expected}]")
    println("PAIR ${label} epoch=${stable} measure=${after.measures-before.measures}/${full.measures-after.measures} arrange=${after.arranges-before.arranges}/${full.arranges-after.arranges} paint=${after.paints-before.paints}/${full.paints-after.paints}")
    WorkSample(actual, before, after, full, label)
}

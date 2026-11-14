package incremental_invalidation_cache

import cjtui.*

// F5: actual finite-height callback misses must contribute to the public measure counter.
func canvasFiniteMeasureStats(): Unit {
    let epoch = [Int64(0)]
    let calls = [Int64(0)]
    let root = Canvas({ constraints =>
        calls[0]++
        constraints.constrain(Size(3, 4))
    }, { context => context.put(0, 0, "A") }).viewport(ScrollAxes.Off)
    let app = Application(root)
    app.startHeadless()
    try {
        paired(app, root, epoch, 3, 2, "A  \n   ", "F5 explicit Off initial finite height")
        let stable = epoch[0]
        let beforeCalls = calls[0]
        let before = app.stats()
        let actual = app.snapshot(3, 4)
        let after = app.stats()
        let executed = calls[0] - beforeCalls
        let recorded = after.measures - before.measures
        let full = render(root, 3, 4)
        check(epoch[0] == stable, "F5 stable height-change epoch")
        equalCells(actual, full, "F5 finite-height full Cell equality")
        check(actual.toPlainText() == "A  \n   \n   \n   ", "F5 literal finite-height layout")
        println("F5 target_callbacks=${executed} target_recorded_measures=${recorded} epoch=${stable}")
        check(executed > 0, "F5 fixture observed actual new finite-height callback miss")
        WorkChecks.verify(recorded >= executed, "F5 every actual target measure callback must be counted")
    } finally { app.dispose() }
}

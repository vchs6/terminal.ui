package overlay_baseline

import cjtui.*

// Existing API sanity only: no claim about generic overlay behavior.
main(): Int64 {
    let value = Observable<String>("base")
    let root = Column {Text({=> value.get()})}
    let app = Application(root)
    app.startHeadless()
    if (app.snapshot(6, 1).toPlainText() != "base  ") {
        throw Exception("baseline first grid")
    }
    value.set("new")
    if (app.snapshot(6, 1).toPlainText() != "new   ") {
        throw Exception("baseline latest binding")
    }
    app.dispose()
    if (app.stats().mountedNodes != 0) {
        throw Exception("baseline cleanup")
    }
    println("BASELINE_ONLY existing public snapshot/binding/cleanup")
    return 0
}

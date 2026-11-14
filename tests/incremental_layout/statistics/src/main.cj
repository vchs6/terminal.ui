package incremental_layout_statistics

import cjtui.*

func check(value: Bool, label: String): Unit {
    if (!value) { throw Exception("FAIL: ${label}") }
}

// Ordinary typed reads intentionally fail on M1. No public constructor/reset is required.
func unchanged(a: RuntimeStats, b: RuntimeStats, label: String): Unit {
    let arrangeA: Int64 = a.arranges
    let writesA: Int64 = a.cellWrites
    let allocationA: Int64 = a.frameAllocatedCells
    check(arrangeA == b.arranges && writesA == b.cellWrites && allocationA == b.frameAllocatedCells, label)
}

// Breaks: uncharged initial capacity, external mutation charged to an Application, wrong lifecycle.
func allocationOwnership(): Unit {
    let root = Text("X")
    let app = Application(root)
    let before = app.stats()
    check(before.arranges == 0 && before.cellWrites == 0 && before.frameAllocatedCells == 0, "before start")
    app.startHeadless()
    let saved = app.snapshot(3, 2)
    let generated = app.stats()
    // Six visible target slots must first exist and be initialized: area-derived lower bounds,
    // independent of buffer/copy representation or timing.
    check(generated.arranges > 0 && generated.cellWrites >= 6 && generated.frameAllocatedCells >= 6,
        "initial arrangement/initialization/allocation charged")
    saved.put(0, 0, "中")
    saved.fillRect(Rect(0, 1, 3, 1), style: Style(background: Color.Blue))
    let ownCopy = saved.copy(Rect(0, 0, 3, 2))
    ownCopy.put(1, 0, "q")
    let unrelated = Frame(4, 2)
    unrelated.put(0, 0, "free")
    unrelated.composite(ownCopy)
    unchanged(generated, app.stats(), "saved snapshot edits/copy and unrelated Frame operations have no owner")
    check(generated.frames == 1, "old frames meaning unchanged")
    app.dispose()
    unchanged(generated, app.stats(), "dispose retains all three cumulative counters")
    app.startHeadless()
    let restarted = app.stats()
    check(restarted.cellWrites == 0 && restarted.frameAllocatedCells == 0 && restarted.frames == 0,
        "new session resets generation counters")
    app.dispose()
    println("PASS CASE 8 counter initialization/ownership/dispose/restart")
}

// Breaks: reference uses cached work, real new counts replaced with defaults, old stats redefined.
func completeReferenceWork(): Unit {
    let state = Observable<String>("a")
    let root = Row { Text({ => state.get() }); Text("b") }
    let app = Application(root)
    app.startHeadless()
    try {
        app.snapshot(4, 1)
        let before = app.stats()
        let reference = render(root, 4, 1)
        check(reference.toPlainText() == "ab  ", "full reference output")
        let after = app.stats()
        check(after.arranges >= before.arranges + 3 && after.measures >= before.measures + 3 &&
            after.paints == before.paints + 3 && after.frames == before.frames + 1,
            "full reference charges every real node and frame")
        check(after.cellWrites >= before.cellWrites + 4 && after.frameAllocatedCells >= before.frameAllocatedCells + 4,
            "reference target initialization/allocation charged")
        check(after.builds == before.builds && after.mountedNodes == before.mountedNodes &&
            after.activeBindings == before.activeBindings && after.subscriptions == before.subscriptions,
            "reference work preserves old stats stocks/builds")
        let savedArranges: Int64 = after.arranges
        let savedWrites: Int64 = after.cellWrites
        let savedAllocation: Int64 = after.frameAllocatedCells
        app.batch({ => state.set("z") })
        check(render(root, 4, 1).toPlainText() == "zb  ", "reference consumes binding invalidation")
        check(app.snapshot(4, 1).toPlainText() == "zb  ", "target consumes reference-stabilized change")
        check(after.arranges == savedArranges && after.cellWrites == savedWrites &&
            after.frameAllocatedCells == savedAllocation, "returned stats are an independent snapshot")
        check(app.stats().arranges > savedArranges && app.stats().cellWrites > savedWrites &&
            app.stats().frameAllocatedCells > savedAllocation, "later reference adds actual work")
    } finally { app.dispose() }
    println("PASS CASE 9 full reference work/public cumulative stats")
}

main(): Int64 {
    allocationOwnership()
    completeReferenceWork()
    println("PASS statistics: 2 cases")
    return 0
}

package incremental_composition

import cjtui.*

func rootVisibility(): Unit {
    let epoch = [Int64(0)]
    let probe = DrawProbe("partially-painted-root",3,1)
    // The explicit box makes only row zero paintable, independently of the
    // larger complete target. The other four rows have always been blank.
    let root = Canvas({_ => Size(3,1)},{p => probe.record(p); p.put(0,0,"X") })
        .width(3).height(1).viewport(ScrollAxes.Off)
    let shown = [row(["X"," "," "," "," "," "," "," "]),row([" "," "," "," "," "," "," "," "]),
        row([" "," "," "," "," "," "," "," "]),row([" "," "," "," "," "," "," "," "]),row([" "," "," "," "," "," "," "," "])]
    let hidden = [row([" "," "," "," "," "," "," "," "]),row([" "," "," "," "," "," "," "," "]),
        row([" "," "," "," "," "," "," "," "]),row([" "," "," "," "," "," "," "," "]),row([" "," "," "," "," "," "," "," "])]
    let app = Application(root,theme:plainTheme()); app.startHeadless()
    try {
        let original = rootVisibilityPair(app,root,epoch,shown,probe,1,false,"root visible initial")
        advance(app,epoch,{ => root.visible(false) })
        let cleared = rootVisibilityPair(app,root,epoch,hidden,probe,0,true,"root hidden clears old row")
        literal(original,shown,"saved root frame remains visible after hide")
        advance(app,epoch,{ => root.visible(true) })
        rootVisibilityPair(app,root,epoch,shown,probe,1,true,"root shown restores only old-new row")
        literal(cleared,hidden,"saved hidden frame remains blank after show")
    } finally { app.dispose() }
}

// Kept local to this added domain so the frozen fifteen cases and their pairing
// helper stay byte-identical. M1 work is measured after the target cutoff.
func rootVisibilityPair(app: Application, root: Component, epoch: Array<Int64>,
    cells: Array<Array<ExpectedCell>>, probe: DrawProbe, expectedDraws: Int64,
    localUpdate: Bool, label: String): Frame {
    let stable = epoch[0]
    probe.reset()
    let before = app.stats()
    let actual = app.snapshot(8,5)
    let after = app.stats()
    let target = probe.saved()
    noCaret(app,"${label}: target has no caret")
    probe.reset()
    let reference = render(root,8,5)
    let full = app.stats()
    noCaret(app,"${label}: M1 preserves no caret")
    Checks.equal(epoch[0] == stable,"${label}: stable business epoch")
    sameCells(actual,reference,"${label}: complete M2/M1")
    literal(actual,cells,"${label}: literal M2")
    literal(reference,cells,"${label}: literal M1")
    Checks.amount(target.size == expectedDraws,"${label}: root target draws=${target.size}, expected=${expectedDraws}")
    Checks.amount(target.size <= 1,"${label}: root callback at most once")
    Checks.equal(probe.observations.size == expectedDraws,"${label}: complete M1 callback count")
    for (observation in target) {
        Checks.equal(observation.agrees(probe.expected),"${label}: literal target 3x1 allocation/clip/style")
    }
    for (observation in probe.observations) {
        Checks.equal(observation.agrees(probe.expected),"${label}: literal M1 3x1 allocation/clip/style")
    }
    let allocated = after.frameAllocatedCells-before.frameAllocatedCells
    let writes = after.cellWrites-before.cellWrites
    let fullAllocated = full.frameAllocatedCells-after.frameAllocatedCells
    let fullWrites = full.cellWrites-after.cellWrites
    println("ROOT_WORK ${label} epoch=${stable} target_draws=${target.size} reference_draws=${probe.observations.size} frame_allocated_cell_slots=${allocated} cell_writes=${writes} reference_slots=${fullAllocated} reference_writes=${fullWrites} affected_rows=1 frame_rows=5 columns=8")
    if (localUpdate) {
        // One damaged row is eight cells; five-row blank initialization is forty.
        // This deliberately broad reduction boundary allows row detachment,
        // clearing and scratch/repaint work. It asserts no exact row identity,
        // exact allocation count, heap-byte size or new performance threshold.
        Checks.amount(allocated < 40,"${label}: one-row update allocates fewer than full-frame 40 Cell slots; actual=${allocated}")
        Checks.amount(writes < 40,"${label}: one-row update writes fewer than full-frame 40 initial cells; actual=${writes}")
    }
    println("PAIR ${label} epoch=${stable} size=8x5")
    actual
}

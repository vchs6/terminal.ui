package incremental_composition

import cjtui.*

func advance(app: Application, epoch: Array<Int64>, action: () -> Unit): Unit {
    app.batch({ => action(); epoch[0]++ })
}

// expectedCalls=-1 skips the exact count but still enforces at-most-once.
// Capture target observations before the full reference can invoke callbacks.
func paired(app: Application, root: Component, epoch: Array<Int64>, width: Int64, height: Int64,
    cells: Array<Array<ExpectedCell>>, probes: Array<DrawProbe>, expectedCalls: Array<Int64>, label: String,
    glyphMode!: GlyphMode = GlyphMode.Unicode): Frame {
    let stable = epoch[0]
    for (probe in probes) { probe.reset() }
    let actual = app.snapshot(width,height,glyphMode:glyphMode)
    let target = Array<Array<DrawObservation>>(probes.size,{ i => probes[i].saved() })
    let beforeCaret = app.caretSnapshot()
    for (probe in probes) { probe.reset() }
    let reference = render(root,width,height,glyphMode:glyphMode)
    let afterCaret = app.caretSnapshot()
    Checks.equal(epoch[0] == stable,"${label}: stable business epoch")
    sameCells(actual,reference,"${label}: M2/M1")
    literal(actual,cells,"${label}: M2")
    literal(reference,cells,"${label}: M1")
    Checks.equal(beforeCaret.visible == afterCaret.visible && beforeCaret.x == afterCaret.x && beforeCaret.y == afterCaret.y,
        "${label}: M1 preserves Application caret geometry")
    Checks.equal(beforeCaret.owner.isSome() == afterCaret.owner.isSome(),"${label}: M1 preserves caret ownership presence")
    if (beforeCaret.owner.isSome() && afterCaret.owner.isSome()) {
        Checks.equal(beforeCaret.owner.getOrThrow().sameNode(afterCaret.owner.getOrThrow()),"${label}: M1 preserves caret owner")
    }
    Checks.equal(probes.size == expectedCalls.size,"${label}: test count specification")
    for (i in 0..probes.size) {
        let probe = probes[i]; let observations = target[i]
        Checks.amount(observations.size <= 1,"${label}: ${probe.name} target callback at most once; actual=${observations.size}")
        if (i < expectedCalls.size && expectedCalls[i] >= 0) {
            Checks.amount(observations.size == expectedCalls[i],"${label}: ${probe.name} target draws=${observations.size}, expected=${expectedCalls[i]}")
        }
        for (observation in observations) {
            Checks.equal(observation.agrees(probe.expected),"${label}: ${probe.name} original target allocation/clip/style")
        }
        for (observation in probe.observations) {
            Checks.equal(observation.agrees(probe.expected),"${label}: ${probe.name} literal M1 allocation/clip/style")
        }
        println("DRAW ${label} ${probe.name} target=${observations.size} reference=${probe.observations.size}")
    }
    println("PAIR ${label} epoch=${stable} size=${width}x${height}")
    actual
}

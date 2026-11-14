package rendering_workloads

import cjtui.*
import std.fs.File

// Builds the complete Cell and independent caret observations. It does not
// create a sample CSV: scene facts and counter availability must be supplied by
// the executable after the session has been disposed.
public func observeCorrectness(options: Options, workload: Workload, diagnostic: Bool): RunResult {
    let app = workload.app
    let period = scenarioPeriod(options.scenario)
    let before = Observation(app)
    var cells = cellCsvHeader()
    var carets = "scenario,seed,epoch,stage,owner,owner_valid,x,y,visible\n"
    for (epoch in 0..(period + 1)) {
        if (epoch > 0) { workload.action(epoch) }
        let narrower = (options.scenario == "resize_pair" && epoch % 2 == 1) ||
            (options.scenario == "viewport_caret" && epoch % 3 == 2)
        let width = if (narrower) { options.width / 2 } else { options.width }
        let height = if (options.scenario == "resize_pair" && narrower) { options.height / 2 } else { options.height }
        let glyph = workload.glyph(epoch)
        let snapshot = app.snapshot(width, height, glyphMode: glyph)
        workload.afterSnapshot(epoch)
        let caret = app.caretSnapshot()
        if (diagnostic) {
            carets += workload.caretRecord(caret, epoch, options.seed, "before_render")
            let reference = render(workload.root, width, height, glyphMode: glyph)
            let afterCaret = app.caretSnapshot()
            let afterRow = workload.caretRecord(afterCaret, epoch, options.seed, "after_render")
            // Compare both complete grids and independently check caret identity.
            assertFramesEqual(snapshot, reference)
            let beforeOwner = caret.owner; let afterOwner = afterCaret.owner
            if (caret.visible != afterCaret.visible || caret.x != afterCaret.x || caret.y != afterCaret.y ||
                beforeOwner.isSome() != afterOwner.isSome()) { throw Exception("reference render changed caret") }
            if (let Some(beforeRef) <- beforeOwner) {
                if (!beforeRef.sameNode(afterOwner.getOrThrow())) { throw Exception("reference render changed caret owner") }
            }
            carets += afterRow
            cells += cellCsv(snapshot, options.scenario, options.seed, epoch, "m2")
            cells += cellCsv(reference, options.scenario, options.seed, epoch, "m1")
        } else {
            carets += workload.caretRecord(caret, epoch, options.seed, "snapshot")
            cells += cellCsv(snapshot, options.scenario, options.seed, epoch, "snapshot")
        }
    }
    let after = Observation(app)
    // Callers must replace scene facts with observations from their fixture;
    // this result is deliberately not sent to sampleCsv directly.
    RunResult(before, after, "correctness", after.stats.mountedNodes, 0, 0,
        0, period, period + 1, if (diagnostic) { period + 1 } else { 0 },
        "not_available", "not_available", cells, carets)
}

// During implementation, preserve raw correctness observations even when the
// full scene-fact sample is unavailable. A caller must still fail the request.
public func captureDraftCorrectness(options: Options, diagnostic: Bool): Unit {
    let workload = Workload(options)
    let app = workload.app
    app.startHeadless()
    let result = try {
        let _ = app.snapshot(options.width, options.height)
        workload.setup()
        observeCorrectness(options, workload, diagnostic)
    } finally { app.dispose() }
    File.writeTo(options.cellsCsv, result.cells.toArray())
    File.writeTo(options.caretCsv, result.carets.toArray())
    throw Exception("scene fact reporting is not yet implemented")
}

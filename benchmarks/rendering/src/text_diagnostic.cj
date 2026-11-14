package rendering_diagnostic

import cjtui.*
import rendering_workloads.*
import std.fs.File
import std.time.MonoTime

func runDiagnosticText(options: Options): Unit {
    if (!supportsTextScene(options.scenario)) { throw Exception("workload ${options.scenario} is unsupported") }
    let scene = TextScene(options.scenario, options.width, options.height)
    let app = scene.app
    app.startHeadless()
    let result = try {
        if (options.mode == "correctness") { diagnosticCorrectness(options, scene) }
        else { diagnosticTiming(options, scene) }
    } finally { app.dispose() }
    let before = result.before.stats; let after = result.after.stats
    let report = sampleCsv(options, result.before, result.after, result.phase, result.total, result.total,
        result.dirty, result.textBytes, result.firstEpoch, result.lastEpoch, result.preparations, result.references,
        1, result.loopTime, result.samplingTime, "${after.arranges-before.arranges}",
        "${after.cellWrites-before.cellWrites}", "${after.frameAllocatedCells-before.frameAllocatedCells}")
    if (options.mode == "correctness") {
        File.writeTo(options.cellsCsv, result.cells.toArray())
        File.writeTo(options.caretCsv, result.carets.toArray())
    }
    File.writeTo(options.csv, report.toArray())
}

private func diagnosticCorrectness(options: Options, scene: TextScene): RunResult {
    let app = scene.app
    let period: Int64 = if (options.scenario == "unicode_cells" || options.scenario == "text_length") { 4 } else { 2 }
    let before = Observation(app)
    var cells = cellCsvHeader()
    var carets = "scenario,seed,epoch,stage,owner,owner_valid,x,y,visible\n"
    for (epoch in 0..(period + 1)) {
        if (epoch > 0) { app.batch({=> scene.action(epoch)}) }
        let snapshot = app.snapshot(options.width, options.height)
        assertLiteralFrame(snapshot, options.scenario, epoch)
        let caret = app.caretSnapshot()
        if (caret.visible || caret.owner.isSome() || caret.x != 0 || caret.y != 0) {
            throw Exception("unexpected caret before reference render at epoch ${epoch}")
        }
        let reference = render(scene.root, options.width, options.height)
        let afterCaret = app.caretSnapshot()
        if (afterCaret.visible || afterCaret.owner.isSome() || afterCaret.x != 0 || afterCaret.y != 0) {
            throw Exception("reference render changed caret at epoch ${epoch}")
        }
        assertFramesEqual(snapshot, reference)
        cells += cellCsv(snapshot, options.scenario, options.seed, epoch, "m2")
        cells += cellCsv(reference, options.scenario, options.seed, epoch, "m1")
        carets += "${options.scenario},${options.seed},${epoch},before_render,none,false,0,0,false\n"
        carets += "${options.scenario},${options.seed},${epoch},after_render,none,false,0,0,false\n"
    }
    let after = Observation(app)
    RunResult(before, after, "correctness", after.stats.mountedNodes, scene.dirtyLeaves(), scene.textBytes(),
        0, period, period + 1, period + 1, "not_available", "not_available", cells, carets)
}

private func diagnosticTiming(options: Options, scene: TextScene): RunResult {
    let app = scene.app
    var retained: ?Frame = Some(app.snapshot(options.width, options.height))
    for (epoch in 1..(options.warmup + 1)) {
        app.batch({=> scene.action(epoch)})
        retained = Some(if (options.mode == "m1-headless") { render(scene.root, options.width, options.height) }
            else { app.snapshot(options.width, options.height) })
    }
    let sampleStart = MonoTime.now()
    let before = Observation(app)
    let sampleBefore = (MonoTime.now() - sampleStart).toMicroseconds()
    let start = MonoTime.now()
    for (index in 1..(options.updates + 1)) {
        let epoch = options.warmup + index
        app.batch({=> scene.action(epoch)})
        retained = Some(if (options.mode == "m1-headless") { render(scene.root, options.width, options.height) }
            else { app.snapshot(options.width, options.height) })
    }
    let loopTime = (MonoTime.now() - start).toMicroseconds()
    let sampleEnd = MonoTime.now()
    let after = Observation(app)
    let samplingTime = sampleBefore + (MonoTime.now() - sampleEnd).toMicroseconds()
    if (retained.isNone()) { throw Exception("missing retained frame") }
    retained = None
    let phase = if (options.scenario == "broad_text") { "broad" } else { "local" }
    RunResult(before, after, phase, after.stats.mountedNodes, scene.dirtyLeaves(), scene.textBytes(),
        options.warmup + 1, options.warmup + options.updates, 1, 0,
        "${loopTime}", "${samplingTime}", "", "")
}

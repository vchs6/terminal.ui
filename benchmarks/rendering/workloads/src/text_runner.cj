package rendering_workloads

import cjtui.*
import std.time.MonoTime

public func supportsTextScene(name: String): Bool {
    ["unicode_cells", "same_width_text", "text_length", "leaf_color", "vertical_panels", "shared_observable", "broad_text"].contains(name)
}

public func runCompatText(options: Options): Unit {
    if (!supportsTextScene(options.scenario) || (options.mode != "correctness" && options.mode != "snapshot-headless")) {
        throw Exception("workload ${options.scenario}/${options.mode} is not implemented")
    }
    let scene = TextScene(options.scenario, options.width, options.height)
    let app = scene.app
    app.startHeadless()
    let result = try {
        if (options.mode == "correctness") { correctnessText(options, scene) }
        else { timingText(options, scene) }
    } finally { app.dispose() }
    result.writeCompat(options)
}

private func correctnessText(options: Options, scene: TextScene): RunResult {
    let app = scene.app
    let period: Int64 = if (options.scenario == "unicode_cells" || options.scenario == "text_length") { 4 } else { 2 }
    let before = Observation(app)
    var cells = cellCsvHeader()
    var carets = "scenario,seed,epoch,stage,owner,owner_valid,x,y,visible\n"
    for (epoch in 0..(period + 1)) {
        if (epoch > 0) { app.batch({=> scene.action(epoch)}) }
        let frame = app.snapshot(options.width, options.height)
        cells += cellCsv(frame, options.scenario, options.seed, epoch, "snapshot")
        let caret = app.caretSnapshot()
        if (caret.visible || caret.owner.isSome() || caret.x != 0 || caret.y != 0) {
            throw Exception("unexpected caret in text scene at epoch ${epoch}")
        }
        carets += "${options.scenario},${options.seed},${epoch},snapshot,none,false,0,0,false\n"
    }
    let after = Observation(app)
    let total = after.stats.mountedNodes
    let sceneTextBytes = scene.textBytes()
    RunResult(before, after, "correctness", total, scene.dirtyLeaves(), sceneTextBytes,
        0, period, period + 1, 0, "not_available", "not_available", cells, carets)
}

private func timingText(options: Options, scene: TextScene): RunResult {
    let app = scene.app
    var retained: ?Frame = Some(app.snapshot(options.width, options.height))
    for (epoch in 1..(options.warmup + 1)) {
        app.batch({=> scene.action(epoch)})
        retained = Some(app.snapshot(options.width, options.height))
    }
    let samplingStart = MonoTime.now()
    let before = Observation(app)
    let samplingBefore = (MonoTime.now() - samplingStart).toMicroseconds()
    let start = MonoTime.now()
    for (index in 1..(options.updates + 1)) {
        let epoch = options.warmup + index
        app.batch({=> scene.action(epoch)})
        retained = Some(app.snapshot(options.width, options.height))
    }
    let loopTime = (MonoTime.now() - start).toMicroseconds()
    let samplingEnd = MonoTime.now()
    let after = Observation(app)
    let samplingTime = samplingBefore + (MonoTime.now() - samplingEnd).toMicroseconds()
    if (retained.isNone()) { throw Exception("missing retained frame") }
    retained = None
    let total = after.stats.mountedNodes
    let sceneTextBytes = scene.textBytes()
    let phase = if (options.scenario == "broad_text") { "broad" } else { "local" }
    RunResult(before, after, phase, total, scene.dirtyLeaves(), sceneTextBytes,
        options.warmup + 1, options.warmup + options.updates, 1, 0,
        "${loopTime}", "${samplingTime}", "", "")
}

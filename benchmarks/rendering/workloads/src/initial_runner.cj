package rendering_workloads

import cjtui.*
import std.fs.File
import std.time.MonoTime

// Each measured update owns a fresh root and Application. The two inner
// brackets omit observations and disposal but retain first target construction.
public func runCompatInitial(options: Options): Unit {
    for (_ in 0..options.warmup) {
        let scene = TextScene("vertical_panels", options.width, options.height)
        scene.app.startHeadless()
        try { let _ = scene.app.snapshot(options.width, options.height) } finally { scene.app.dispose() }
    }
    let totals = InitialTotals()
    for (_ in 0..options.updates) {
        let createStart = MonoTime.now()
        let scene = TextScene("vertical_panels", options.width, options.height)
        let app = scene.app
        totals.loopTime += (MonoTime.now() - createStart).toMicroseconds()
        let sampleStart = MonoTime.now()
        let before = Observation(app)
        totals.samplingTime += (MonoTime.now() - sampleStart).toMicroseconds()
        try {
            let workStart = MonoTime.now()
            app.startHeadless()
            var retained: ?Frame = Some(app.snapshot(options.width, options.height))
            totals.loopTime += (MonoTime.now() - workStart).toMicroseconds()
            let endSample = MonoTime.now()
            let after = Observation(app)
            totals.samplingTime += (MonoTime.now() - endSample).toMicroseconds()
            if (retained.isNone()) { throw Exception("missing first target") }
            retained = None
            totals.textBytes = scene.textBytes()
            totals.add(before, after)
        } finally { app.dispose() }
    }
    let before = totals.before.getOrThrow(); let after = totals.after.getOrThrow()
    let total = after.stats.mountedNodes
    let report = sampleCsv(options, before, after, "initial", total, total, options.height, totals.textBytes,
        0, options.updates - 1, 0, 0, options.updates, "${totals.loopTime}", "${totals.samplingTime}",
        "not_available", "not_available", "not_available", sumBuilds: Some(totals.builds),
        sumMeasures: Some(totals.measures), sumPaints: Some(totals.paints), sumFrames: Some(totals.frames))
    File.writeTo(options.csv, report.toArray())
}

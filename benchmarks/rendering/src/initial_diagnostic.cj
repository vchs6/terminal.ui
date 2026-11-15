package rendering_diagnostic

import cjtui.*
import rendering_workloads.*
import std.fs.File
import std.time.MonoTime

func runDiagnosticInitial(options: Options): Unit {
    for (_ in 0..options.warmup) {
        let scene = TextScene("vertical_panels", options.width, options.height)
        scene.app.startHeadless()
        try { let _ = scene.app.snapshot(options.width, options.height) } finally { scene.app.dispose() }
    }
    let total = DiagnosticInitialTotals()
    let common = total.common
    for (_ in 0..options.updates) {
        let creation = MonoTime.now()
        let scene = TextScene("vertical_panels", options.width, options.height)
        let app = scene.app
        common.loopTime += (MonoTime.now() - creation).toMicroseconds()
        let samplingStart = MonoTime.now()
        let before = Observation(app)
        common.samplingTime += (MonoTime.now() - samplingStart).toMicroseconds()
        try {
            let start = MonoTime.now()
            app.startHeadless()
            var retained: ?Frame = Some(app.snapshot(options.width, options.height))
            common.loopTime += (MonoTime.now() - start).toMicroseconds()
            let samplingEnd = MonoTime.now()
            let after = Observation(app)
            common.samplingTime += (MonoTime.now() - samplingEnd).toMicroseconds()
            if (retained.isNone()) { throw Exception("missing first target") }
            retained = None
            common.textBytes = scene.textBytes()
            total.add(before, after)
        } finally { app.dispose() }
    }
    let before = common.before.getOrThrow(); let after = common.after.getOrThrow()
    let nodes = after.stats.mountedNodes
    let report = sampleCsv(options, before, after, "initial", nodes, nodes, options.height, common.textBytes,
        0, options.updates - 1, 0, 0, options.updates, "${common.loopTime}", "${common.samplingTime}",
        "${total.arranges}", "${total.writes}", "${total.slots}", sumBuilds: Some(common.builds),
        sumMeasures: Some(common.measures), sumPaints: Some(common.paints), sumFrames: Some(common.frames))
    File.writeTo(options.csv, report.toArray())
}

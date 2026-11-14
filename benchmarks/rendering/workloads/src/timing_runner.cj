package rendering_workloads

import cjtui.*
import std.time.MonoTime

// Common timing body. The caller starts the session and performs setup before
// entering; validation/oracle/export are deliberately absent from this path.
public func observeTiming(options: Options, workload: Workload, fullRender: Bool): RunResult {
    let app = workload.app
    var retained: ?Frame = Some(app.snapshot(options.width, options.height, glyphMode: workload.glyph(0)))
    workload.afterSnapshot(0)
    for (epoch in 1..(options.warmup + 1)) {
        workload.action(epoch)
        let frame = requestedFrame(options, workload, epoch, fullRender)
        workload.afterSnapshot(epoch)
        retained = Some(frame)
    }
    let samplingStart = MonoTime.now()
    let before = Observation(app)
    let sampleBefore = (MonoTime.now() - samplingStart).toMicroseconds()
    let start = MonoTime.now()
    for (index in 1..(options.updates + 1)) {
        let epoch = options.warmup + index
        workload.action(epoch)
        let frame = requestedFrame(options, workload, epoch, fullRender)
        workload.afterSnapshot(epoch)
        retained = Some(frame)
    }
    let loopTime = (MonoTime.now() - start).toMicroseconds()
    let samplingEnd = MonoTime.now()
    let after = Observation(app)
    let sampleTime = sampleBefore + (MonoTime.now() - samplingEnd).toMicroseconds()
    if (retained.isNone()) { throw Exception("missing retained frame") }
    retained = None
    // Scene facts are not inferred from counters. This intermediate result is
    // not a public sample until the fixture supplies actual values.
    RunResult(before, after, scenarioPhase(options.scenario), after.stats.mountedNodes, 0, 0,
        options.warmup + 1, options.warmup + options.updates, 1, 0, "${loopTime}", "${sampleTime}", "", "")
}

private func requestedFrame(options: Options, workload: Workload, epoch: Int64, fullRender: Bool): Frame {
    let narrower = (options.scenario == "resize_pair" && epoch % 2 == 1) ||
        (options.scenario == "viewport_caret" && epoch % 3 == 2)
    let width = if (narrower) { options.width / 2 } else { options.width }
    let height = if (options.scenario == "resize_pair" && narrower) { options.height / 2 } else { options.height }
    let glyph = workload.glyph(epoch)
    if (fullRender) { render(workload.root, width, height, glyphMode: glyph) }
    else { workload.app.snapshot(width, height, glyphMode: glyph) }
}

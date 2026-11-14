package rendering_compat

import cjtui.*
import rendering_workloads.*
import std.fs.File
import std.time.MonoTime

// Each input acknowledgement is delivered only after the first ordinary run
// target; every repetition then stops and disposes that Application.
func runTerminalInitial(options: Options): Unit {
    let totals = InitialTotals()
    for (index in 0..(options.warmup + options.updates)) {
        let warmup = index < options.warmup
        let label = if (warmup) { "warmup-${index}" } else { "measured-${index - options.warmup}" }
        let createStart = MonoTime.now()
        let scene = TextScene("vertical_panels", options.width, options.height)
        let app = scene.app
        let creationUs = (MonoTime.now() - createStart).toMicroseconds()
        let samplingStart = MonoTime.now()
        let before = Observation(app)
        let beforeUs = (MonoTime.now() - samplingStart).toMicroseconds()
        let end: Array<?Observation> = [None]
        let runStart = MonoTime.now()
        let runUs: Array<Int64> = [0]
        let samplingUs: Array<Int64> = [0]
        app.onKey({event =>
            if (event.text != "r") { throw Exception("initial lifecycle expects r") }
            runUs[0] = (MonoTime.now() - runStart).toMicroseconds()
            let t = MonoTime.now()
            end[0] = Some(Observation(app))
            samplingUs[0] = (MonoTime.now() - t).toMicroseconds()
            File.writeTo(options.csv + "." + label + ".captured", "captured\n".toArray())
            app.stop()
        })
        File.writeTo(options.csv + "." + label + ".starting", "starting\n".toArray())
        app.run()
        let after = end[0].getOrThrow()
        File.writeTo(options.csv + "." + label + ".closed", "closed\n".toArray())
        if (!warmup) {
            totals.add(before, after)
            totals.loopTime += creationUs + runUs[0]
            totals.samplingTime += beforeUs + samplingUs[0]
            totals.textBytes = scene.textBytes()
        }
    }
    let before = totals.before.getOrThrow(); let after = totals.after.getOrThrow()
    let total = after.stats.mountedNodes
    let report = sampleCsv(options, before, after, "initial", total, total, options.height, totals.textBytes,
        0, options.updates - 1, 0, 0, options.updates, "${totals.loopTime}", "${totals.samplingTime}",
        "not_available", "not_available", "not_available", sumBuilds: Some(totals.builds),
        sumMeasures: Some(totals.measures), sumPaints: Some(totals.paints), sumFrames: Some(totals.frames))
    File.writeTo(options.csv, report.toArray())
}

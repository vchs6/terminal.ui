package rendering_workloads

import std.fs.File

public func runCompatInitialCorrectness(options: Options): Unit {
    let capture = InitialCapture(options, false)
    let totals = capture.totals
    let before = totals.before.getOrThrow(); let after = totals.after.getOrThrow()
    let nodes = after.stats.mountedNodes
    let report = sampleCsv(options, before, after, "correctness", nodes, nodes, options.height, totals.textBytes,
        0, 1, 2, 0, 2, "not_available", "not_available", "not_available", "not_available", "not_available",
        sumBuilds: Some(totals.builds), sumMeasures: Some(totals.measures),
        sumPaints: Some(totals.paints), sumFrames: Some(totals.frames))
    File.writeTo(options.cellsCsv, capture.cells.toArray())
    File.writeTo(options.caretCsv, capture.carets.toArray())
    File.writeTo(options.csv, report.toArray())
}

package rendering_diagnostic

import rendering_workloads.*
import std.fs.File

func runDiagnosticInitialCorrectness(options: Options): Unit {
    let capture = InitialCapture(options, true)
    let totals = capture.totals
    var arranges: Int64 = 0; var writes: Int64 = 0; var slots: Int64 = 0
    for (i in 0..capture.before.size) {
        let a = capture.before[i].stats; let b = capture.after[i].stats
        arranges += b.arranges - a.arranges
        writes += b.cellWrites - a.cellWrites
        slots += b.frameAllocatedCells - a.frameAllocatedCells
    }
    let before = totals.before.getOrThrow(); let after = totals.after.getOrThrow()
    let nodes = after.stats.mountedNodes
    let report = sampleCsv(options, before, after, "correctness", nodes, nodes, options.height, totals.textBytes,
        0, 1, 2, 2, 2, "not_available", "not_available", "${arranges}", "${writes}", "${slots}",
        sumBuilds: Some(totals.builds), sumMeasures: Some(totals.measures),
        sumPaints: Some(totals.paints), sumFrames: Some(totals.frames))
    File.writeTo(options.cellsCsv, capture.cells.toArray())
    File.writeTo(options.caretCsv, capture.carets.toArray())
    File.writeTo(options.csv, report.toArray())
}

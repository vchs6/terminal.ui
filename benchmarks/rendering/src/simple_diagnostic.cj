package rendering_diagnostic

import rendering_workloads.*
import std.fs.File

func runDiagnosticSimple(options: Options): Unit {
    let workload = Workload(options)
    let app = workload.app
    app.startHeadless()
    let result = try {
        workload.setup()
        if (options.mode == "correctness") { observeCorrectness(options, workload, true) }
        else { observeTiming(options, workload, options.mode == "m1-headless") }
    } finally { app.dispose() }
    let before = result.before.stats; let after = result.after.stats
    let report = sampleCsv(options, result.before, result.after, result.phase, result.total, result.visible,
        result.dirty, result.textBytes, result.firstEpoch, result.lastEpoch, result.preparations, result.references,
        1, result.loopTime, result.samplingTime, "${after.arranges-before.arranges}",
        "${after.cellWrites-before.cellWrites}", "${after.frameAllocatedCells-before.frameAllocatedCells}", layers: result.layers)
    if (options.mode == "correctness") {
        File.writeTo(options.cellsCsv, result.cells.toArray())
        File.writeTo(options.caretCsv, result.carets.toArray())
    }
    File.writeTo(options.csv, report.toArray())
}

package rendering_diagnostic

import rendering_workloads.*

class DiagnosticInitialTotals {
    let common = InitialTotals()
    var arranges: Int64 = 0
    var writes: Int64 = 0
    var slots: Int64 = 0
    func add(before: Observation, after: Observation): Unit {
        common.add(before, after)
        arranges += after.stats.arranges - before.stats.arranges
        writes += after.stats.cellWrites - before.stats.cellWrites
        slots += after.stats.frameAllocatedCells - before.stats.frameAllocatedCells
    }
}

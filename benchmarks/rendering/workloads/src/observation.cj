package rendering_workloads

import cjtui.*
import std.runtime.{getAllocatedHeapSize, getGCFreedSize, getGCCount, getGCTime}

// Non-atomic observation in the contract's specified order.
public class Observation {
    public let stats: RuntimeStats
    public let heap: Int64
    public let freed: Int64
    public let gcCount: Int64
    public let gcTime: Int64
    public init(app: Application) {
        stats = app.stats()
        heap = getAllocatedHeapSize()
        freed = getGCFreedSize()
        gcCount = getGCCount()
        gcTime = getGCTime()
    }
}

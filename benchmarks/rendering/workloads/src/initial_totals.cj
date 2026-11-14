package rendering_workloads

public class InitialTotals {
    public var before: ?Observation = None
    public var after: ?Observation = None
    public var builds: Int64 = 0
    public var measures: Int64 = 0
    public var paints: Int64 = 0
    public var frames: Int64 = 0
    public var loopTime: Int64 = 0
    public var samplingTime: Int64 = 0
    public var textBytes: Int64 = 0
    public func add(first: Observation, last: Observation): Unit {
        if (before.isNone()) { before = Some(first) }
        after = Some(last)
        builds += last.stats.builds - first.stats.builds
        measures += last.stats.measures - first.stats.measures
        paints += last.stats.paints - first.stats.paints
        frames += last.stats.frames - first.stats.frames
    }
}

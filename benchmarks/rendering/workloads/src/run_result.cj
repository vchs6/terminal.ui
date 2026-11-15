package rendering_workloads

import std.fs.File

public class RunResult {
    public let before: Observation
    public let after: Observation
    public let phase: String
    public let total: Int64
    public var visible: Int64
    public var layers: Int64
    public let dirty: Int64
    public let textBytes: Int64
    public let firstEpoch: Int64
    public let lastEpoch: Int64
    public let preparations: Int64
    public let references: Int64
    public let loopTime: String
    public let samplingTime: String
    public let cells: String
    public let carets: String

    public init(before: Observation, after: Observation, phase: String, total: Int64, dirty: Int64,
        textBytes: Int64, firstEpoch: Int64, lastEpoch: Int64, preparations: Int64, references: Int64,
        loopTime: String, samplingTime: String, cells: String, carets: String) {
        this.before = before; this.after = after; this.phase = phase; this.total = total; this.visible = total; this.layers = 0; this.dirty = dirty
        this.textBytes = textBytes; this.firstEpoch = firstEpoch; this.lastEpoch = lastEpoch
        this.preparations = preparations; this.references = references; this.loopTime = loopTime
        this.samplingTime = samplingTime; this.cells = cells; this.carets = carets
    }

    public func writeCompat(options: Options): Unit {
        let report = sampleCsv(options, before, after, phase, total, total, dirty, textBytes,
            firstEpoch, lastEpoch, preparations, references, 1, loopTime, samplingTime,
            "not_available", "not_available", "not_available")
        if (options.mode == "correctness") {
            File.writeTo(options.cellsCsv, cells.toArray())
            File.writeTo(options.caretCsv, carets.toArray())
        }
        File.writeTo(options.csv, report.toArray())
    }
}

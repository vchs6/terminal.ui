package cjtui

public class TextEditLimits {
    public let maxTextBytes: Int64
    public let maxUndoEntries: Int64
    public let maxUndoBytes: Int64
    public init(maxTextBytes!: Int64 = 1048576, maxUndoEntries!: Int64 = 128, maxUndoBytes!: Int64 = 2097152) {
        if (maxTextBytes <= 0 || maxTextBytes > 16777216 || maxUndoEntries <= 0 || maxUndoEntries > 65536 ||
            maxUndoBytes <= 0 || maxUndoBytes > 67108864) {
            throw IllegalArgumentException("invalid editing limits")
        }
        this.maxTextBytes = maxTextBytes
        this.maxUndoEntries = maxUndoEntries
        this.maxUndoBytes = maxUndoBytes
    }
}

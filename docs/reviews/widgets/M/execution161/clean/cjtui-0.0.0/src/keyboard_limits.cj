package cjtui

public class KeyboardLimits {
    public let maxPasteBytes: Int64
    public let maxSequenceBytes: Int64
    public init(maxPasteBytes!: Int64 = 1048576, maxSequenceBytes!: Int64 = 64) {
        if (maxPasteBytes <= 0 || maxPasteBytes > 16777216 || maxSequenceBytes <= 0 || maxSequenceBytes > 4096) {
            throw IllegalArgumentException("invalid keyboard limits")
        }
        this.maxPasteBytes = maxPasteBytes
        this.maxSequenceBytes = maxSequenceBytes
    }
}

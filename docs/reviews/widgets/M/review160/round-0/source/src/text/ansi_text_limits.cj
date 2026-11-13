package cjtui.text

public class AnsiTextLimits {
    public let maxSequenceBytes: Int64
    public let maxParameters: Int64
    public init(maxSequenceBytes!: Int64 = 4096, maxParameters!: Int64 = 64) {
        if (maxSequenceBytes <= 0 || maxSequenceBytes > 1048576 || maxParameters <= 0 || maxParameters > 4096) {
            throw IllegalArgumentException("invalid ANSI text limits")
        }
        this.maxSequenceBytes = maxSequenceBytes
        this.maxParameters = maxParameters
    }
}

package cjtui

public struct TerminalGlyphCapabilities {
    public let nativeVt: Bool
    public let mapKnown: Bool
    public let entryCount: Int64
    public let source: String
    public let reason: String
    public let nativeError: Int64
    init(nativeVt: Bool, mapKnown: Bool, entryCount: Int64, source: String, reason: String, nativeError: Int64) {
        this.nativeVt = nativeVt
        this.mapKnown = mapKnown
        this.entryCount = entryCount
        this.source = source
        this.reason = reason
        this.nativeError = nativeError
    }
}

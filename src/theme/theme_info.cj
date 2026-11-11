package cjtui.theme

// Immutable snapshot of one Application's accepted theme.
public class ThemeInfo {
    public let name: String
    public let revision: UInt64
    public let requestId: UInt64
    public let source: ThemeSource
    public init(name: String, revision: UInt64, requestId: UInt64, source: ThemeSource) {
        this.name = name; this.revision = revision; this.requestId = requestId; this.source = source
    }
}

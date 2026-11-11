package cjtui

// The loader orders terminal transitions; notification occurs after its lock.
public class ThemeRequest {
    public let id: UInt64
    private let source = ThemeRequestSource()
    internal init(id: UInt64) { this.id = id }
    public func result(): ?ThemeResult { source.read() }
    func complete(value: ThemeResult): Bool { source.complete(value) }
    func announce(): Unit { source.emit() }
}

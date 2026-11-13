package cjtui

public class OverlayHandle {
    private let record: OverlayRecord
    init(record: OverlayRecord) { this.record = record }
    public func isOpen(): Bool { record.guard(); record.observe(); record.terminal.isNone() }
    public func content(): ?NodeRef { record.guard(); record.observe(); if (record.terminal.isSome()) { None } else { record.root } }
    public func closeReason(): ?OverlayCloseReason { record.guard(); record.observe(); record.terminal }
    public func close(): Unit {
        record.guard()
        if (record.terminal.isSome()) { return }
        let session = record.owner.resolve().session
        session.requireStructure()
        session.closeOverlay(record,OverlayCloseReason.Requested)
    }
}

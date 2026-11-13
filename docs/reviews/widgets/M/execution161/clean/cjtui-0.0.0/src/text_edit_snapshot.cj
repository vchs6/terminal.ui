package cjtui

public class TextEditSnapshot {
    public let text: String
    public let selection: TextSelection
    public let revision: UInt64
    public let selectionRevision: UInt64
    public let canUndo: Bool
    public let canRedo: Bool
    let identity: Int64
    let sourceVersion: Int64
    init(text: String, selection: TextSelection, revision: UInt64, selectionRevision: UInt64, canUndo: Bool,
        canRedo: Bool, identity: Int64, sourceVersion: Int64) {
        this.text = text
        this.selection = selection
        this.revision = revision
        this.selectionRevision = selectionRevision
        this.canUndo = canUndo
        this.canRedo = canRedo
        this.identity = identity
        this.sourceVersion = sourceVersion
    }
}

package cjtui

public struct CaretSnapshot {
    public let owner: ?NodeRef
    public let x: Int64
    public let y: Int64
    public let visible: Bool
    init(owner: ?NodeRef, x: Int64, y: Int64, visible: Bool) {
        this.owner = owner; this.x = x; this.y = y; this.visible = visible
    }
}

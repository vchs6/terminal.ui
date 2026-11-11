package cjtui

class CaretRequest {
    let owner: NodeRef
    let x: Int64
    let y: Int64
    init(owner: NodeRef, x: Int64, y: Int64) { this.owner = owner; this.x = x; this.y = y }
}

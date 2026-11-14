package cjtui

public class RuntimeStats {
    public let mountedNodes: Int64
    public let activeBindings: Int64
    public let subscriptions: Int64
    public let pendingPosts: Int64
    public let builds: Int64
    public let measures: Int64
    public let paints: Int64
    public let frames: Int64
    public let arranges: Int64
    public let cellWrites: Int64
    public let frameAllocatedCells: Int64
    init(mountedNodes: Int64, activeBindings: Int64, subscriptions: Int64, pendingPosts: Int64,
        builds: Int64, measures: Int64, paints: Int64, frames: Int64,
        arranges!: Int64 = 0, cellWrites!: Int64 = 0, frameAllocatedCells!: Int64 = 0) {
        this.mountedNodes = mountedNodes; this.activeBindings = activeBindings; this.subscriptions = subscriptions
        this.pendingPosts = pendingPosts; this.builds = builds; this.measures = measures; this.paints = paints; this.frames = frames
        this.arranges = arranges; this.cellWrites = cellWrites; this.frameAllocatedCells = frameAllocatedCells
    }
}

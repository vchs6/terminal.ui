package cjtui

public class RuntimeLimits {
    let pendingPosts: Int64
    let mountedNodes: Int64
    let bindingsPerNode: Int64
    let dependenciesPerBinding: Int64
    let structuralOpsPerBatch: Int64
    let stabilizationPasses: Int64
    let treeDepth: Int64
    public init(pendingPosts!: Int64 = 4096, mountedNodes!: Int64 = 100000,
        bindingsPerNode!: Int64 = 128, dependenciesPerBinding!: Int64 = 4096,
        structuralOpsPerBatch!: Int64 = 10000, stabilizationPasses!: Int64 = 64, treeDepth!: Int64 = 256) {
        if (pendingPosts <= 0 || mountedNodes <= 0 || bindingsPerNode <= 0 || dependenciesPerBinding <= 0 ||
            structuralOpsPerBatch <= 0 || stabilizationPasses <= 0 || treeDepth <= 0) {
            throw IllegalArgumentException("runtime limits must be positive")
        }
        this.pendingPosts = pendingPosts
        this.mountedNodes = mountedNodes
        this.bindingsPerNode = bindingsPerNode
        this.dependenciesPerBinding = dependenciesPerBinding
        this.structuralOpsPerBatch = structuralOpsPerBatch
        this.stabilizationPasses = stabilizationPasses
        this.treeDepth = treeDepth
    }
}

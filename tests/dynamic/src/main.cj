package dynamic_contract

func runCase(name: String, test: () -> Unit): Unit {
    test()
    println("PASS: ${name}")
}

main(): Int64 {
    runCase("slot-reorder", slotReorder)
    runCase("slot-delete", slotDelete)
    runCase("slot-empty-refill", slotEmptyAndRefill)
    runCase("slot-overflow", slotPrependOverflow)
    runCase("marker-exterior", moveOutsideMarker)
    runCase("manual-remove-rebuild", manualRemoveAndRebuild)
    runCase("deferred-reads-noops", deferredReadsAndNoops)
    runCase("commands-before-reconciliation", commandsPrecedeReconciliation)
    runCase("key-new-value-local-state", retainedKeyGetsNewValue)
    runCase("multiple-groups-manual-order", multipleGroupsAndManualOrder)
    runCase("conditional-lifetimes", conditionalLifetimes)
    runCase("empty-conditional-plain-flow", emptyConditionalAndPlainControlFlow)
    runCase("unmount-group-parent", unmountingGroupParentReleasesDescendants)
    runCase("invalid-keys", invalidKeysBeforeBodies)
    runCase("invalid-update-no-partial-body", invalidUpdateHasNoPartialBodies)
    runCase("root-counts", dynamicRootCounts)
    runCase("stale-anchor", staleAnchorAfterRemove)
    runCase("cross-parent-foreign-anchor", crossParentAndForeignAnchor)
    runCase("duplicate-insert-cycle", duplicateInsertionAndCycles)
    runCase("leaf-parent-removed-move", leafParentAndRemovedMove)
    runCase("structure-limits", structureLimits)
    runCase("owner-post-cancel", ownerPostCancelledOnDynamicUnmount)
    runCase("failed-body-collector", failedBodyReleasesAndRestoresCollector)
    runCase("cleanup-continues", cleanupContinuesAfterFailure)
    runCase("lifecycle-reentry", lifecycleStructureReentry)
    runCase("evaluation-reentry", evaluationStructureReentry)
    runCase("body-reentry", bodyStructureReentry)
    runCase("lifecycle-post-next-turn", lifecycleCanPostNextTurn)
    runCase("dynamic-mount-failure", dynamicMountFailureCleansSession)
    runCase("recursive-structure-boundaries", recursiveStructureBoundaries)
    runCase("observable-write-from-key", observableWriteFromKeyRejected)
    runCase("synchronous-structural-loop", synchronousStructuralLoopIsBounded)
    let manualNested = runNestedCase("manual-nested-duplicate-before-commit", manualNestedDuplicateBeforeCommit)
    let replacementNested = runNestedCase("replacement-nested-duplicate-before-commit", replacementNestedDuplicateBeforeCommit)
    if (manualNested && replacementNested) { 0 } else { 1 }
}

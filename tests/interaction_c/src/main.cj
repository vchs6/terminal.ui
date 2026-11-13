package interaction_c
import std.env.*

// This binary is built and run ONLY after actual accepted A/B/Theme/Session
// admission. Missing those dependencies is BLOCKED, never behavioral RED.
main(): Int64 {
    if(let Some(name)<-getVariable("CJTUI_OVERLAY_REGRESSION")){return exportTurnRegression(name)}
    if(getVariable("CJTUI_OVERLAY_NATIVE").isSome()){return nativeOverlayFixture()}
    publicShapes()
    pendingCancellation()
    sharedTypeAndIdentity()
    modalDomains()
    escapeBarrierAndPrevent()
    emptyLayerReservation()
    dependentClosure()
    savedFocusFallback()
    cleanupAggregation()
    entryValidation()
    foreignAndOldHandles()
    surfacesAndLatestBase()
    sourceBasedCaretOcclusion()
    duplicateReservation();pendingFailure(false);pendingFailure(true);releasedOwnerObservation()
    mixedOrdinaryIdentity();ownerMoveAndPaintLifetime()
    escapeAndLogicalRouting();modalTraversalAndDomainOpen()
    hiddenOrUnmountedSaved(false);hiddenOrUnmountedSaved(true)
    for(branch in 0..4){physicalRestorationFallback(branch)}
    stackedRestoration();ordinaryOwnedClosure();offscreenOwnerAndReason()
    primaryAndCleanup(false);primaryAndCleanup(true)
    threadAndAnchorValidation();for(phase in 0..3){evaluationAndLifecycleGuards(phase)}
    lifecycleLayerCommands();layerDepthBoundary();for(which in 0..3){layerCapacity(which)}
    layerDependencyBudget(false);layerDependencyBudget(true);interactivePassiveRejection()
    ownerThemeSurface();explicitHostClip();directionalAnchors();clippedAndLostAnchors()
    decoratedLayerTargets();caretSpacesShadowAndClip()
    pureExportPreservesCommittedOverlay();overlayOpenRequiresActiveTurn()
    return 0
}

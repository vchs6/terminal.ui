package interaction_b

import std.env.*

main(): Int64 {
    if (getVariable("CJTUI_VIEWPORT_CASE") == Some("pty")) { return ptyFixture() }
    if(let Some(mode)<-getVariable("CJTUI_VIEWPORT_CASE")){
        if(mode=="same-turn" || mode=="caret-resize" || mode=="unicode"){return viewportDeviceSequence(mode)}
        if(mode=="bare-canvas"){bareCanvasImplicitViewport();return 0}
        if(mode=="resource"){finiteExtentResource();return 0}
    }
    rootLongContent()
    rootWeightedCompatibility()
    fixedChromeAndBarriers()
    acceptedCommandsAndClamping()
    axesAndZeroResize()
    horizontalTable()
    nestedEnsure()
    alignmentsAndOversizedTarget()
    defaultActionOrder()
    targetPrevent()
    pageSteps()
    wrappedAndEmptyRoot()
    detachedRootPolicy()
    canvasHorizontalCaret()
    constructorComposition()
    mixedIdentityRetention()
    readonlyPrelayoutAndStale()
    noViewportCapability()
    bareCanvasImplicitViewport()
    caretHistoryInvalidation()
    zeroHundredRoot();rootOverflowBoundaries();finiteExtentResource()
    ensureTwoAxesAndNone();explicitIntentOrdering()
    viewportReadonlyContexts();viewportPureMutationGuards();viewportValidationAndCapacity()
    pendingViewportCancellation();viewportLifecyclePost();unicodeViewportClipping()
    println("PASS: executed interaction B public viewport assertions")
    return 0
}

package interaction_b

import std.env.*

main(): Int64 {
    if(let Some(name)<-getVariable("CJTUI_VIEWPORT_REVIEW")){return reviewRegression(name)}
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
    for(name in ["I01","I02","I03","I04","I05","I06","I07"]){reviewRegression(name)}
    println("PASS: executed interaction B public viewport assertions")
    return 0
}

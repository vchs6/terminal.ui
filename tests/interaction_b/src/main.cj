package interaction_b

import std.env.*

main(): Int64 {
    if (getVariable("CJTUI_VIEWPORT_CASE") == Some("pty")) { return ptyFixture() }
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
    println("PASS: executed interaction B public viewport assertions")
    return 0
}

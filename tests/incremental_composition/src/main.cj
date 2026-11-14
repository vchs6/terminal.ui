package incremental_composition

main(): Int64 {
    let names = ["row replay", "move hide unmount", "surfaces latest background", "descendant shadows", "resize shadow bounds",
        "wide partners", "negative Frame transfer", "scroll anchors", "viewport caret", "cached caret ownership",
        "invalid caret requests", "nested modal close", "layered glyph policy", "implicit root layers", "shadow caret", "root visibility",
        "covered caret across damage rows"]
    let cases: Array<() -> Unit> = [rowReplay,movesAndRemoval,surfacesAndLatest,descendantShadows,movedShadowLayer,
        widePartners,negativeFrameTransfer,scrollAndAnchor,viewportCaret,cachedCaretAndOwnership,
        invalidCaretRequests,nestedModalClose,layeredGlyphPolicy,rootFallbackLayers,shadowCaretOcclusion,rootVisibility,
        coveredCaretAcrossDamageRows]
    for (i in 0..cases.size) {
        let priorCorrectness = Checks.correctness; let priorWork = Checks.work
        try { let action = cases[i]; action() } catch (error: Exception) {
            Checks.correctness++; println("CORRECTNESS_EXCEPTION ${names[i]} ${error.message}")
        }
        println("CASE ${i+1} ${names[i]} correctness_failures=${Checks.correctness-priorCorrectness} work_red=${Checks.work-priorWork}")
    }
    println("RESULT cases=${cases.size} correctness_failed_assertions=${Checks.correctness} work_red_assertions=${Checks.work}")
    if (Checks.correctness == 0 && Checks.work == 0) { 0 } else { 1 }
}

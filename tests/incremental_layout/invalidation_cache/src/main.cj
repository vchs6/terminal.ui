package incremental_invalidation_cache

main(): Int64 {
    let names = ["getter replacement", "typed equality", "explicit notify", "local content", "Row redistribution",
        "Column justification", "wrap insets", "keyed/manual", "hidden/If", "span changes", "theme colors",
        "style sources", "theme geometry", "Canvas dependencies", "Canvas readonly", "reference cache",
        "root fallback", "viewport wrap", "glyph policy"]
    let cases: Array<() -> Unit> = [getterReplacement, typedStyleEquality, explicitNotify, localContent,
        rowRedistribution, columnJustification, wrapInsets, keyedManual, hiddenUpdates, spanChanges,
        themeColors, styleSources, themeGeometry, canvasDependencies, canvasReadonly, referenceCache,
        rootFallback, viewportWrap, glyphPolicy]
    var failures: Int64 = 0
    var workCases: Int64 = 0
    for (i in 0..cases.size) {
        let priorWork = WorkChecks.failures
        try {
            let action = cases[i]
            action()
            println("CORRECT CASE ${i+1} ${names[i]}")
        } catch (error: Exception) {
            failures++
            println("FAIL CASE ${i+1} ${names[i]}: ${error.message}")
        }
        if (WorkChecks.failures > priorWork) { workCases++ }
    }
    println("RESULT cases=${cases.size} correctness_failed=${failures} work_failed_cases=${workCases} work_failed_assertions=${WorkChecks.failures}")
    if (failures == 0 && WorkChecks.failures == 0) { 0 } else { 1 }
}

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
    for (i in 0..cases.size) {
        try {
            let action = cases[i]
            action()
            println("PASS CASE ${i+1} ${names[i]}")
        } catch (error: Exception) {
            failures++
            println("FAIL CASE ${i+1} ${names[i]}: ${error.message}")
        }
    }
    println("RESULT cases=${cases.size} failed=${failures}")
    if (failures == 0) { 0 } else { 1 }
}

package incremental_layout_baseline

func runCase(action: () -> Unit, label: String): Int64 {
    try {
        action()
        return 0
    } catch (error: Exception) {
        println("FAIL CASE ${label}: ${error.message}")
        return 1
    }
}

main(): Int64 {
    var failures = Int64(0)
    failures += runCase(rowAllocation, "1")
    failures += runCase(columnWrap, "2")
    failures += runCase(implicitRootFallback, "3")
    failures += runCase(explicitViewport, "4")
    failures += runCase(referenceLifetime, "5")
    failures += runCase(canvasDependencies, "6")
    failures += runCase(glyphGeneration, "7")
    println("baseline: 7 cases, ${failures} failures")
    return if (failures == 0) { 0 } else { 1 }
}

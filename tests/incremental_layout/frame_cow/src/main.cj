package incremental_frame_cow

func runCase(action: () -> Unit, label: String): Int64 {
    try { action(); println("PASS ${label}"); return 0 }
    catch (error: Exception) { println("FAIL ${label}: ${error.message}"); return 1 }
}
main(args: Array<String>): Int64 {
    let requireCow = args.size > 0 && args[0] == "cow"
    var failures: Int64 = 0
    failures += runCase(aliasBranches, "alias branches")
    failures += runCase(writeEntrances, "public write entrances")
    failures += runCase(opacityAndComposition, "F003 opacity and self composition")
    failures += runCase(unicodeAndResize, "Unicode clipping resize metadata")
    failures += runCase(zeroAxes, "zero area virtual axes")
    failures += runCase(ansiSnapshots, "public full ANSI output")
    failures += runCase({ => allocationObservation(requireCow) }, "App-owned allocation observation")
    println("frame_cow: 7 cases, ${failures} failures; requireCow=${requireCow}")
    return if (failures == 0) { 0 } else { 1 }
}

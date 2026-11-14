package rendering_diagnostic

import rendering_workloads.*

main(args: Array<String>): Int64 {
    if (args.size == 1 && args[0] == "--help") {
        println("--mode correctness|m1-headless|m2-headless")
        return 0
    }
    try {
        let options = Options(args, true)
        if (options.mode == "m2-headless" && options.scenario == "initial") { runDiagnosticInitial(options); return 0 }
        if (!supportsTextScene(options.scenario) && options.mode == "correctness") {
            captureDraftCorrectness(options, true)
        }
        runDiagnosticText(options)
        0
    } catch (error: Exception) {
        println("benchmark: ${error.message}")
        1
    }
}

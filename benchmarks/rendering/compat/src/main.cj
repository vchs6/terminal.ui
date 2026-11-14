package rendering_compat

import rendering_workloads.*

main(args: Array<String>): Int64 {
    if (args.size == 1 && args[0] == "--help") {
        println("--mode correctness|snapshot-headless|tty; compat diagnostics arranges, cell_writes and frame_allocated_cell_slots are not_available")
        return 0
    }
    try {
        let options = Options(args, false)
        if (options.mode == "snapshot-headless" && options.scenario == "initial") { runCompatInitial(options); return 0 }
        if (options.mode == "tty") { runTerminal(options); return 0 }
        if (!supportsTextScene(options.scenario) && options.mode == "correctness") {
            captureDraftCorrectness(options, false)
        }
        runCompatText(options)
        0
    } catch (error: Exception) {
        println("benchmark: ${error.message}")
        1
    }
}

package rendering_compat

import rendering_workloads.*

main(args: Array<String>): Int64 {
    if (args.size == 1 && args[0] == "--help") {
        println("--mode correctness|snapshot-headless|tty; compat diagnostics arranges, cell_writes and frame_allocated_cell_slots are not_available")
        return 0
    }
    try {
        let options = Options(args, false)
        throw Exception("workload ${options.scenario} is not implemented")
    } catch (error: Exception) {
        println("benchmark: ${error.message}")
        1
    }
}

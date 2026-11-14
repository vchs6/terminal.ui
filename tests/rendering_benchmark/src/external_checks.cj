package rendering_benchmark_tests

func validateProcess(path: String, expectedId: String): Unit {
    let table = CsvTable(path)
    table.requireColumns(["run_id","process_pid","executable","scope","instrumentation","cpu_user_us","cpu_system_us","wall_us",
        "peak_rss_kib","exit_code","limitations"])
    demand(table.rows.size == 1, "process report must identify one actual process run")
    let row = table.rows[0]
    demand(table.at(row,"run_id") == expectedId && !expectedId.isEmpty(), "wrong process identity")
    demand(metric(table,row,"process_pid") > 0 && !table.at(row,"executable").isEmpty(), "missing actual pid/executable")
    demand(table.at(row,"scope") == "whole_process", "wait4 cannot claim isolated loop CPU")
    oneOf(table.at(row,"instrumentation"),["none","native_write_trace"],"instrumentation")
    let user = metric(table,row,"cpu_user_us",unavailable:true)
    let system = metric(table,row,"cpu_system_us",unavailable:true)
    let wall = metric(table,row,"wall_us",unavailable:true)
    let rss = metric(table,row,"peak_rss_kib",unavailable:true)
    demand((user >= 0 && system >= 0) || (user < 0 && system < 0), "partial user/system CPU evidence")
    if (wall >= 0) { demand(wall > 0, "empty wall sampling interval") }
    if (rss >= 0) { demand(rss > 0, "empty RSS sampling result") }
    demand(metric(table,row,"exit_code") == 0, "measured command failed")
}

func validateOutput(path: String): Unit {
    let table = CsvTable(path)
    table.requireColumns(["run_id","phase","observer","target_fd","trace_path","host","host_version",
        "width","height","capability_source","output_requested_bytes","output_success_bytes",
        "output_success_calls","output_failed_calls","output_short_calls","limitations"])
    var initial = false; var update = false; var exit = false
    for (row in table.rows) {
        demand(table.at(row,"observer") == "native_write_returns", "PTY reads/requested bytes cannot count native writes")
        for (name in ["run_id","target_fd","trace_path","host","host_version","capability_source","limitations"]) {
            demand(!table.at(row,name).isEmpty() && table.at(row,name) != "not_available", "missing output provenance ${name}")
        }
        let phase = table.at(row,"phase")
        oneOf(phase,["initial","update","exit"],"output phase")
        if (phase == "initial") { initial = true }
        if (phase == "update") { update = true }
        if (phase == "exit") { exit = true }
        demand(metric(table,row,"width") > 0 && metric(table,row,"height") > 0, "invalid terminal dimensions")
        let requested = metric(table,row,"output_requested_bytes")
        let bytes = metric(table,row,"output_success_bytes")
        let calls = metric(table,row,"output_success_calls")
        let shorts = metric(table,row,"output_short_calls")
        let failed = metric(table,row,"output_failed_calls")
        demand(bytes <= requested && shorts <= calls, "inconsistent native output returns")
        demand((bytes == 0) == (calls == 0), "positive successful calls must have positive returned bytes")
        let (traceRequested,traceBytes,traceCalls,traceFailed,traceShorts) = nativeReturns(table.at(row,"trace_path"),table.at(row,"target_fd"))
        demand(requested == traceRequested && bytes == traceBytes && calls == traceCalls && failed == traceFailed && shorts == traceShorts,
            "reported output differs from actual native write returns")
    }
    demand(initial && update && exit, "missing initial/update/exit output evidence")
}

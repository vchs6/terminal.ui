package rendering_benchmark_tests

func validateSamples(path: String, columnsPath: String, metadataPath: String, expectedId: String, scenario: String, mode: String,
    width: Int64, height: Int64, repetition: Int64): Unit {
    let table = attachMetadata(CsvTable(path),CsvTable(metadataPath))
    let columns = CsvTable(columnsPath)
    for (row in columns.rows) { table.requireColumns([columns.at(row,"column")]) }
    let compat = mode == "snapshot-headless" || mode == "compat-correctness" || mode == "tty"
    let correctness = mode == "correctness" || mode == "compat-correctness"
    let expectedPhase = if (correctness) { "correctness" } else { scenarioPhase(scenario) }
    var foundPhase = false
    for (row in table.rows) {
        demand(table.at(row,"schema_version") == "1", "unknown sample schema")
        demand(table.at(row,"run_id") == expectedId && !expectedId.isEmpty(), "benchmark did not echo actual requested run_id")
        demand(table.at(row,"scenario") == scenario, "wrong scenario")
        let reportedMode = if (mode == "compat-correctness") { "correctness" } else { mode }
        demand(table.at(row,"mode") == reportedMode, "wrong mode")
        demand(metric(table,row,"width") == width && metric(table,row,"height") == height, "wrong dimensions")
        demand(metric(table,row,"seed") == 143, "wrong seed")
        demand(metric(table,row,"repetition") == repetition, "wrong repetition")
        for (name in ["run_id","environment_id","os","cpu","locale","gc_config","optimization","capability_source","limitations","counter_scope"]) {
            demand(!table.at(row,name).isEmpty(), "missing metadata ${name}")
        }
        hex(table.at(row,"source_sha"),40,"source_sha")
        for (name in ["artifact_sha256","elf_sha256","workload_sha256","dependency_sha256","sdk_sha256","native_sha256"]) {
            hex(table.at(row,name),64,name)
        }
        demand(table.at(row,"sdk_version") == "1.2.0", "SDK version must identify actual frozen SDK1.2.0")
        oneOf(table.at(row,"glyph_mode"),["Unicode","Ascii","Auto"],"glyph mode")
        oneOf(table.at(row,"phase"),["initial","local","global","broad","idle","correctness","output"],"phase")
        if (table.at(row,"phase") == expectedPhase) { foundPhase = true }
        let first = metric(table,row,"epoch_first"); let last = metric(table,row,"epoch_last")
        demand(last >= first, "reversed epoch range")
        demand(metric(table,row,"updates") > 0, "empty measured updates")
        let preparation = metric(table,row,"preparation_snapshots")
        let references = metric(table,row,"reference_renders")
        if (!correctness) {
            demand(references == 0, "performance window contains oracle/reference render")
            demand(preparation <= 1, "per-update hidden snapshot preparation")
        } else if (!compat) {
            demand(preparation > 0 && references > 0, "correctness must disclose commit preparation and reference calls")
        }
        let total = metric(table,row,"total_nodes")
        demand(metric(table,row,"visible_nodes") <= total, "visible nodes exceed mounted total")
        demand(metric(table,row,"dirty_leaves") <= total, "dirty leaves exceed mounted total")
        for (name in ["warmup","text_utf8_bytes","layers","mounted_nodes_before","mounted_nodes_after",
            "active_bindings_before","active_bindings_after","subscriptions_before","subscriptions_after",
            "pending_posts_before","pending_posts_after","builds","measures","paints","frames"]) {
            metric(table,row,name)
        }
        for (name in ["arranges","cell_writes","frame_allocated_cell_slots"]) {
            if (compat) {
                demand(table.at(row,name) == "not_available", "compat invents new diagnostic ${name}")
                metric(table,row,name,unavailable:true)
            }
            else { metric(table,row,name) }
        }
        if (mode == "m1-headless" && table.at(row,"phase") == expectedPhase) {
            let updates = metric(table,row,"updates")
            demand(metric(table,row,"frames") == updates, "one global full render must be counted per measured update")
            demand(metric(table,row,"measures") > 0 && metric(table,row,"arranges") > 0 && metric(table,row,"paints") > 0,
                "global full render cannot report zero actual stages")
            // Full public render allocates and initializes a new positive-area
            // target. This lower bound does not estimate bytes or copy strategy.
            demand(width <= Int64.Max / height && width * height <= Int64.Max / updates, "metric lower-bound overflow")
            let slots = width * height * updates
            demand(metric(table,row,"frame_allocated_cell_slots") >= slots && metric(table,row,"cell_writes") >= slots,
                "global full-render slots/writes omit initialized target storage")
        }
        for (name in ["cj_heap_used_bytes_before","cj_heap_used_bytes_after","cj_gc_freed_bytes_total_before",
            "cj_gc_freed_bytes_total_after","gc_count_before","gc_count_after","gc_time_us_before","gc_time_us_after"]) {
            metric(table,row,name,unavailable:true)
        }
        for (stem in ["cj_gc_freed_bytes_total","gc_count","gc_time_us"]) {
            let before = metric(table,row,"${stem}_before",unavailable:true)
            let after = metric(table,row,"${stem}_after",unavailable:true)
            demand((before < 0 && after < 0) || (before >= 0 && after >= before), "invalid cumulative ${stem}")
        }
        if (scenario == "idle" && table.at(row,"phase") == "idle" && mode != "m1-headless" && mode != "correctness") {
            for (name in ["builds","measures","paints","frames"]) {
                demand(metric(table,row,name) == 0, "idle did target work: ${name}")
            }
            if (!compat) {
                for (name in ["arranges","cell_writes","frame_allocated_cell_slots"]) {
                    demand(metric(table,row,name) == 0, "idle target allocation/work: ${name}")
                }
            }
        }
    }
    demand(foundPhase, "missing requested workload phase ${expectedPhase}")
}

func scenarioPhase(scenario: String): String {
    if (scenario == "initial" || scenario == "idle") { return scenario }
    if (scenario == "posted_epoch") { return "correctness" }
    if (scenario == "glyph_projection") { return "output" }
    if (scenario == "large_fill_shadows" || scenario == "broad_text") { return "broad" }
    for (name in ["resize_pair","theme_color","theme_spacing","theme_four_sides","theme_wrap"]) {
        if (name == scenario) { return "global" }
    }
    "local"
}

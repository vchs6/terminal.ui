package rendering_workloads

// Provenance columns are bound externally to run_id, not asserted by a CLI label.
public func sampleCsv(options: Options, before: Observation, after: Observation, phase: String,
    totalNodes: Int64, visibleNodes: Int64, dirtyLeaves: Int64, textBytes: Int64,
    firstEpoch: Int64, lastEpoch: Int64, preparations: Int64, references: Int64,
    lifecycles: Int64, loopTime: String, samplingTime: String,
    arranges: String, writes: String, slots: String, sumBuilds!: ?Int64 = None,
    sumMeasures!: ?Int64 = None, sumPaints!: ?Int64 = None, sumFrames!: ?Int64 = None): String {
    let a = before.stats; let b = after.stats
    let builds = sumBuilds ?? (b.builds - a.builds)
    let measures = sumMeasures ?? (b.measures - a.measures)
    let paints = sumPaints ?? (b.paints - a.paints)
    let frames = sumFrames ?? (b.frames - a.frames)
    let glyphMode = if (options.scenario == "glyph_projection") { "Ascii" } else { "Unicode" }
    let scope = if (options.scenario == "initial" && options.mode != "correctness") {
        "sum of fresh lifecycle start and first snapshot deltas"
    } else if (options.mode == "tty") {
        "normal run between begin and end observations including fence work"
    } else if (options.mode == "correctness") {
        "correctness capture across epoch observations"
    } else { "one steady batch between boundary observations" }
    let header = "schema_version,run_id,mode,scenario,glyph_mode,phase,epoch_first,epoch_last,total_nodes,visible_nodes,dirty_leaves,text_utf8_bytes,layers,mounted_nodes_before,mounted_nodes_after,active_bindings_before,active_bindings_after,subscriptions_before,subscriptions_after,pending_posts_before,pending_posts_after,builds,measures,arranges,paints,frames,cell_writes,frame_allocated_cell_slots,cj_heap_used_bytes_before,cj_heap_used_bytes_after,cj_gc_freed_bytes_total_before,cj_gc_freed_bytes_total_after,gc_count_before,gc_count_after,gc_time_us_before,gc_time_us_after,limitations,counter_scope,preparation_snapshots,reference_renders,lifecycles,loop_wall_us,sampling_wall_us\n"
    let row = "1,\"${csvEscape(options.runId)}\",${options.mode},${options.scenario},${glyphMode},${phase},${firstEpoch},${lastEpoch},${totalNodes},${visibleNodes},${dirtyLeaves},${textBytes},0,${a.mountedNodes},${b.mountedNodes},${a.activeBindings},${b.activeBindings},${a.subscriptions},${b.subscriptions},${a.pendingPosts},${b.pendingPosts},${builds},${measures},${arranges},${paints},${frames},${writes},${slots},${before.heap},${after.heap},${before.freed},${after.freed},${before.gcCount},${after.gcCount},${before.gcTime},${after.gcTime},external process and output metrics require independent observation,${scope},${preparations},${references},${lifecycles},${loopTime},${samplingTime}\n"
    header + row
}

private func csvEscape(value: String): String { value.replace("\"", "\"\"") }

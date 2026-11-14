package rendering_workloads

import std.fs.File

// Only scenes with explicit business facts may produce a successful sample.
public func runCompatSimple(options: Options): Unit {
    let workload = Workload(options)
    let app = workload.app
    app.startHeadless()
    let result = try {
        workload.setup()
        if (options.mode == "correctness") { observeCorrectness(options, workload, false) }
        else { observeTiming(options, workload, false) }
    } finally { app.dispose() }
    let report = sampleCsv(options, result.before, result.after, result.phase, result.total, result.visible,
        result.dirty, result.textBytes, result.firstEpoch, result.lastEpoch, result.preparations, result.references,
        1, result.loopTime, result.samplingTime, "not_available", "not_available", "not_available", layers: result.layers)
    if (options.mode == "correctness") {
        File.writeTo(options.cellsCsv, result.cells.toArray())
        File.writeTo(options.caretCsv, result.carets.toArray())
    }
    File.writeTo(options.csv, report.toArray())
}

public func isSimpleScene(name: String): Bool {
    ["caret_only", "ellipsis_policy", "glyph_projection", "same_row_columns", "row_flex_width",
     "column_wrap_height", "batch_properties", "typed_equal", "explicit_notify", "keyed_manual",
     "scroll_step", "scroll_multistep", "large_mounted_viewport", "root_fallback", "viewport_caret", "readonly_focus_caret",
     "posted_epoch", "idle", "resize_pair", "theme_color", "theme_spacing", "theme_four_sides", "theme_wrap", "overlay_holes", "overlay_move",
     "overlay_shrink", "overlay_nested_close", "large_fill_shadows"].contains(name)
}

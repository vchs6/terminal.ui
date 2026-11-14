package rendering_workloads

// Frozen public mode eligibility: a diagnostic M1 pair is only meaningful when
// mounted render does not depend on committed geometry, caret or post pumping.
public func knownScenario(name: String): Bool {
    ["unicode_cells", "ellipsis_policy", "caret_only", "leaf_color", "same_width_text",
     "text_length", "row_flex_width", "column_wrap_height", "resize_pair", "batch_properties",
     "shared_observable", "typed_equal", "explicit_notify", "keyed_manual", "theme_color",
     "theme_spacing", "theme_four_sides", "theme_wrap", "scroll_step", "scroll_multistep",
     "root_fallback", "overlay_holes", "overlay_move", "overlay_shrink", "overlay_nested_close",
     "vertical_panels", "same_row_columns", "large_fill_shadows", "large_mounted_viewport",
     "broad_text", "initial", "idle", "posted_epoch", "readonly_focus_caret", "viewport_caret",
     "glyph_projection"].contains(name)
}

public func pairedScenario(name: String): Bool {
    ["unicode_cells", "ellipsis_policy", "leaf_color", "same_width_text", "shared_observable",
     "typed_equal", "explicit_notify", "theme_color", "vertical_panels", "same_row_columns"].contains(name)
}

public func eligible(mode: String, scenario: String, diagnostic: Bool): Bool {
    if (!knownScenario(scenario)) { return false }
    if (mode == "correctness") { return true }
    if (diagnostic) {
        if (mode == "m1-headless") { return pairedScenario(scenario) }
        if (mode == "m2-headless") { return scenario != "idle" }
    } else {
        if (mode == "snapshot-headless") { return scenario != "idle" }
        if (mode == "tty") { return true }
    }
    false
}

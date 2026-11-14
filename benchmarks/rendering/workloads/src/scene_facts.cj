package rendering_workloads

// Facts are business fixture properties, not inferred allocation or CPU data.
public class SceneFacts {
    public let total: Int64
    public let visible: Int64
    public let dirtyLeaves: Int64
    public let textBytes: Int64
    public let layers: Int64
    public init(total: Int64, visible: Int64, dirtyLeaves: Int64, textBytes: Int64, layers: Int64) {
        this.total = total; this.visible = visible; this.dirtyLeaves = dirtyLeaves
        this.textBytes = textBytes; this.layers = layers
    }
}

public func simpleSceneFacts(options: Options, workload: Workload, observed: Observation, lastEpoch: Int64,
    addedNodes!: Int64 = 0): ?SceneFacts {
    let total = observed.stats.mountedNodes - addedNodes
    if (options.scenario == "caret_only") { return Some(SceneFacts(total, total, 1, 0, 0)) }
    if (options.scenario == "ellipsis_policy") { return Some(SceneFacts(total, total, 0, 6, 0)) }
    if (options.scenario == "glyph_projection") {
        let bytes: Int64 = if (lastEpoch % 3 == 2) { 2 } else { 3 }
        return Some(SceneFacts(total, total, 1, bytes, 0))
    }
    let name = options.scenario
    let width = workload.sceneWidth; let height = workload.sceneHeight
    let mixedBytes = Int64("A中é👩‍💻🇨🇳".toArray().size)
    if (["unicode_cells", "same_width_text", "text_length"].contains(name)) {
        let expected = if (name == "unicode_cells") { 2 } else { height + 1 }
        if (total != expected) { throw Exception("unexpected text scene size") }
        var bytes: Int64 = 3
        if (name == "unicode_cells") { bytes = if (lastEpoch % 4 == 2 || lastEpoch % 4 == 3) { 1 } else { mixedBytes } }
        else if (name == "text_length") {
            bytes = if (lastEpoch % 4 == 2) { 1 } else if (lastEpoch % 4 == 3) { 0 } else { mixedBytes }
        }
        if (name != "unicode_cells") { bytes += (height - 1) * mixedBytes }
        return Some(SceneFacts(total, total, 1, bytes, 0))
    }
    if (["leaf_color", "vertical_panels", "shared_observable", "broad_text"].contains(name) && height >= 2) {
        if (total != height + 1) { throw Exception("unexpected panel scene size") }
        let dirty = if (name == "broad_text") { height } else if (name == "shared_observable") { 2 } else { 1 }
        return Some(SceneFacts(total, total, dirty, height * mixedBytes, 0))
    }
    if ((name == "same_row_columns" || name == "row_flex_width") && width >= 8 && height >= 2) {
        if (total != height + 9) { throw Exception("unexpected mounted column scene size") }
        let dirty: Int64 = if (name == "row_flex_width") { 8 } else { 1 }
        return Some(SceneFacts(total, total, dirty, (height + 7) * mixedBytes, 0))
    }
    if (name == "column_wrap_height" && width >= 10 && height >= 3) {
        if (total != 3) { throw Exception("unexpected mounted wrap scene size") }
        let bytes = if (lastEpoch % 2 == 1) { mixedBytes * 2 } else { mixedBytes }
        return Some(SceneFacts(total, total, 1, bytes + Int64("lower panel".toArray().size), 0))
    }
    if (["batch_properties", "typed_equal", "explicit_notify"].contains(name) && height >= 2) {
        if (total != height + 1) { throw Exception("unexpected mounted reactive scene size") }
        let visible = if (name == "batch_properties" && lastEpoch % 2 == 1) { total - 1 } else { total }
        return Some(SceneFacts(total, visible, 1, height * mixedBytes, 0))
    }
    if ((name == "scroll_step" || name == "scroll_multistep" || name == "large_mounted_viewport") && width >= 8 && height >= 5) {
        let count = if (name == "large_mounted_viewport") { height * 8 } else { height * 2 }
        if (total != count + 3) { throw Exception("unexpected mounted viewport scene size") }
        let viewport = workload.viewportState().getOrThrow()
        if (viewport.width != width || viewport.height != 4 || viewport.contentHeight != count) {
            throw Exception("unexpected committed viewport geometry")
        }
        var bytes = Int64("footer".toArray().size)
        for (i in 0..count) { bytes += Int64("${i} A中é👩‍💻🇨🇳".toArray().size) }
        return Some(SceneFacts(total, 3 + viewport.height, 0, bytes, 0))
    }
    if (name == "root_fallback" && width >= 8 && height >= 2) {
        let viewport = workload.viewportState().getOrThrow()
        if (viewport.width != width || viewport.height != height || total < 3) {
            throw Exception("unexpected root viewport facts")
        }
        let rows = total - 1
        let visibleRows = if (rows < viewport.height) { rows } else { viewport.height }
        let dirty = if (lastEpoch % 3 == 1) { height } else { 0 }
        return Some(SceneFacts(total, 1 + visibleRows, dirty, rows * mixedBytes, 0))
    }
    if (name == "viewport_caret" && width >= 8 && height >= 4) {
        let viewport = workload.viewportState().getOrThrow()
        let expectedWidth = if (lastEpoch % 3 == 2) { width / 2 } else { width }
        if (total != 5 || viewport.width != expectedWidth || viewport.height != 2 || viewport.contentHeight != 4) {
            throw Exception("unexpected caret viewport facts")
        }
        return Some(SceneFacts(total, 5, 1, 4 * mixedBytes + 2, 0))
    }
    if (name == "readonly_focus_caret" && width >= 8 && height >= 3) {
        if (total != 4) { throw Exception("unexpected focus scene size") }
        let dirty: Int64 = if (lastEpoch % 3 == 0) { 0 } else { 2 }
        return Some(SceneFacts(total, total, dirty, mixedBytes, 0))
    }
    if (["theme_color", "theme_spacing", "theme_four_sides", "theme_wrap"].contains(name) && width >= 16 && height >= 8) {
        if (total != height + 1) { throw Exception("unexpected mounted theme scene size") }
        let changed = lastEpoch % 2 == 1
        var visibleRows = height
        if (changed && name == "theme_spacing") { visibleRows = (height + 1) / 2 }
        else if (changed && name == "theme_four_sides") { visibleRows = (height - 4 + 4) / 5 }
        else if (changed && name == "theme_wrap") { visibleRows = (height + 1) / 2 }
        let lineBytes = if (name == "theme_wrap") { (width / 8 + 1) * mixedBytes } else { 2 * mixedBytes + 1 }
        return Some(SceneFacts(total, 1 + visibleRows, height, height * lineBytes, 0))
    }
    if (["overlay_holes", "overlay_move", "overlay_shrink", "overlay_nested_close", "large_fill_shadows"].contains(name) && width >= 16 && height >= 8) {
        let layers = workload.liveLayers()
        let expected = if (name == "overlay_holes") { if (lastEpoch % 2 == 0 && lastEpoch > 0) { 0 } else { 1 } }
            else if (name == "overlay_nested_close") { if (lastEpoch % 3 == 2) { 0 } else { 2 } }
            else if (name == "large_fill_shadows") { 2 } else { 1 }
        if (layers != expected || total != height + 3 + layers) { throw Exception("unexpected live overlay scene size") }
        let layerBytes: Int64 = if (layers == 0) { 0 } else if (name == "overlay_holes") { 8 }
            else if (name == "overlay_nested_close") { 12 }
            else if (name == "large_fill_shadows") { 14 } else { 7 }
        let dirty = if (name == "overlay_holes") { height - 1 }
            else if (name == "overlay_nested_close" && lastEpoch % 3 == 1) { height }
            else if (name == "overlay_nested_close") { 2 } else { 1 }
        return Some(SceneFacts(total, total, dirty, (height - 1) * mixedBytes + 7 + layerBytes, layers))
    }
    if (name == "posted_epoch" && width >= 8 && height >= 2) {
        if (total != height + 1) { throw Exception("unexpected posted scene size") }
        return Some(SceneFacts(total, total, 1, height * mixedBytes, 0))
    }
    if (name == "idle" && width >= 8 && height >= 2) {
        if (total != height + 1) { throw Exception("unexpected idle scene size") }
        return Some(SceneFacts(total, total, 0, height * mixedBytes, 0))
    }
    if (name == "resize_pair" && width >= 8 && height >= 2) {
        if (total != height + 1) { throw Exception("unexpected resize scene size") }
        let visibleRows = if (lastEpoch % 2 == 1) { height / 2 } else { height }
        return Some(SceneFacts(total, 1 + visibleRows, 0, height * mixedBytes, 0))
    }
    if (name == "keyed_manual" && width >= 5 && height >= 1) {
        if (total != 6) { throw Exception("unexpected mounted keyed scene size") }
        return Some(SceneFacts(total, total, 3, 5, 0))
    }
    None
}

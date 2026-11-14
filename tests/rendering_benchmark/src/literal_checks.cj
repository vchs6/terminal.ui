package rendering_benchmark_tests

// Literals are hand-enumerated. No product width/layout/Unicode helper runs here.
func assertManualCell(table: CsvTable, row: Array<String>, scenario: String,
    epoch: Int64, x: Int64, y: Int64): Unit {
    if (scenario != "unicode_cells" && scenario != "ellipsis_policy" && scenario != "caret_only" &&
        scenario != "root_fallback" && scenario != "viewport_caret" && scenario != "readonly_focus_caret") { return }
    var glyph = "20"
    var width = "1"
    var continuation = "false"
    var foreground = "Default"
    if (scenario == "unicode_cells" && y == 0) {
        if (epoch == 0 || epoch == 1 || epoch == 4) {
            let glyphs = ["41","e4b8ad","","65cc81","f09f91a9e2808df09f92bb","","f09f87a8f09f87b3",""]
            let widths = ["1","2","0","1","2","0","2","0"]
            let continuations = ["false","false","true","false","false","true","false","true"]
            if (x < 8) { glyph = glyphs[x]; width = widths[x]; continuation = continuations[x] }
            if (epoch == 1 && x == 1) { glyph = "e69687" }
        } else if ((epoch == 2 || epoch == 3) && x == 0) {
            glyph = "41"
            if (epoch == 3) { foreground = "Red" }
        }
    }
    if (scenario == "ellipsis_policy" && y == 0 && x < 5) {
        let unicode = ["61","62","63","64","e280a6"]
        let ascii = ["61","62","2e","2e","2e"]
        glyph = if (epoch == 1) { ascii[x] } else { unicode[x] }
    }
    var rowTag = ""
    if (scenario == "root_fallback") {
        if (epoch == 0 || epoch == 3) {
            if (y == 0) { rowTag = "41" }
            if (y == 1) { rowTag = "42" }
        } else if (epoch == 1) {
            rowTag = if (y == 0) { "41" } else if (y == 1) { "42" } else { "43" }
        } else if (epoch == 2) { rowTag = "43" }
    }
    if (scenario == "viewport_caret") {
        if (y == 0 && x == 0) { glyph = "48" }
        if (y == 3 && x == 0) { glyph = "46" }
        if (y == 1) { rowTag = if (epoch == 0 || epoch == 3) { "41" } else { "42" } }
        if (y == 2) { rowTag = if (epoch == 0 || epoch == 3) { "42" } else { "43" } }
    }
    if (scenario == "readonly_focus_caret" && y == 2) { rowTag = "41" }
    if (!rowTag.isEmpty() && x < 8) {
        let glyphs = [rowTag,"e4b8ad","","65cc81","f09f91a9e2808df09f92bb","","f09f87a8f09f87b3",""]
        let widths = ["1","2","0","1","2","0","2","0"]
        let continuations = ["false","false","true","false","false","true","false","true"]
        glyph = glyphs[x]; width = widths[x]; continuation = continuations[x]
    }
    let names = cellFields()
    let expected = [glyph,width,continuation,"false",foreground,"Default","false","false","false","false","false","false"]
    for (i in 0..names.size) {
        demand(table.at(row,names[i]) == expected[i],
            "manual ${scenario} epoch=${epoch} (${x},${y}) field=${names[i]} actual=${row} expected=${expected}")
    }
}

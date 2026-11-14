package rendering_benchmark_tests

import std.collection.HashMap

func readCarets(table: CsvTable, scenario: String, width: Int64, height: Int64,
    period: Int64, stages: Array<String>): HashMap<String,Array<String>> {
    table.requireColumns(["scenario","seed","epoch","stage","owner","owner_valid","x","y","visible"])
    let indexed = HashMap<String,Array<String>>()
    for (row in table.rows) {
        demand(table.at(row,"scenario") == scenario && natural(table.at(row,"seed"),"seed") == 143, "wrong caret input")
        let epoch = natural(table.at(row,"epoch"),"epoch")
        demand(epoch <= period, "unexpected caret epoch")
        let stage = table.at(row,"stage"); oneOf(stage,stages,"caret stage")
        let key = "${epoch}/${stage}"; demand(!indexed.contains(key), "duplicate caret ${key}")
        oneOf(table.at(row,"visible"),["true","false"],"caret visible")
        oneOf(table.at(row,"owner_valid"),["true","false"],"caret owner validity")
        let visible = table.at(row,"visible") == "true"
        let x = natural(table.at(row,"x"),"caret x"); let y = natural(table.at(row,"y"),"caret y")
        let (w,h) = frameSize(scenario,epoch,width,height)
        let owner = table.at(row,"owner")
        if (visible) {
            demand(x < w && y < h && !owner.isEmpty() && owner != "none" && table.at(row,"owner_valid") == "true", "invalid visible caret ${key}")
        } else {
            demand(x == 0 && y == 0 && owner == "none" && table.at(row,"owner_valid") == "false", "noncanonical hidden caret ${key}")
        }
        if (scenario == "caret_only") {
            let wantVisible = epoch == 0 || epoch == 1 || epoch == 4
            demand(visible == wantVisible, "manual caret visibility ${key}")
            if (wantVisible) {
                let wantX: Int64 = if (epoch == 1) { 2 } else { 1 }
                demand(x == wantX && y == 0 && owner == "caret", "manual caret position/owner ${key}")
            }
        }
        indexed.add(key,row)
    }
    for (epoch in 0..(period + 1)) { for (stage in stages) {
        demand(indexed.contains("${epoch}/${stage}"), "missing independent caret ${epoch}/${stage}")
    } }
    indexed
}

func validateCarets(path: String, scenario: String, width: Int64, height: Int64, period: Int64, compat: Bool): Unit {
    let table = CsvTable(path)
    let stages = if (compat) { ["snapshot"] } else { ["before_render","after_render"] }
    let indexed = readCarets(table,scenario,width,height,period,stages)
    if (!compat) {
        for (epoch in 0..(period + 1)) {
            let before = indexed.get("${epoch}/before_render").getOrThrow()
            let after = indexed.get("${epoch}/after_render").getOrThrow()
            for (field in ["owner","owner_valid","x","y","visible"]) {
                demand(table.at(before,field) == table.at(after,field), "full render changed independent caret ${epoch}/${field}")
            }
        }
    }
}

func compareCarets(oldPath: String, newPath: String, scenario: String, width: Int64, height: Int64, period: Int64): Unit {
    let oldTable = CsvTable(oldPath); let newTable = CsvTable(newPath)
    let oldRows = readCarets(oldTable,scenario,width,height,period,["snapshot"])
    let newRows = readCarets(newTable,scenario,width,height,period,["snapshot"])
    for (epoch in 0..(period + 1)) {
        let oldRow = oldRows.get("${epoch}/snapshot").getOrThrow()
        let newRow = newRows.get("${epoch}/snapshot").getOrThrow()
        for (field in ["owner","owner_valid","x","y","visible"]) {
            demand(oldTable.at(oldRow,field) == newTable.at(newRow,field), "old/new caret mismatch ${epoch}/${field}")
        }
    }
}

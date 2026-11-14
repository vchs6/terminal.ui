package rendering_benchmark_tests

import std.collection.HashMap

func frameSize(scenario: String, epoch: Int64, width: Int64, height: Int64): (Int64,Int64) {
    if (scenario == "resize_pair" && epoch == 1) { return (width / 2,height / 2) }
    if (scenario == "viewport_caret" && epoch == 2) { return (width / 2,height) }
    (width,height)
}

func cellFields(): Array<String> {
    ["grapheme_utf8_hex","cell_width","continuation","transparent","foreground","background",
        "bold","dim","italic","underline","inverse","strikethrough"]
}

func cellKey(epoch: Int64, path: String, x: Int64, y: Int64): String { "${epoch}/${path}/${x}/${y}" }

func readCells(table: CsvTable, scenario: String, width: Int64, height: Int64, period: Int64,
    paths: Array<String>): HashMap<String,Array<String>> {
    table.requireColumns(["scenario","width","height","seed","epoch","path","x","y"])
    table.requireColumns(cellFields())
    let indexed = HashMap<String,Array<String>>()
    for (row in table.rows) {
        demand(table.at(row,"scenario") == scenario && natural(table.at(row,"seed"),"seed") == 143, "wrong Cell business input")
        let epoch = natural(table.at(row,"epoch"),"epoch")
        demand(epoch <= period, "unexpected Cell epoch ${epoch}")
        let (w,h) = frameSize(scenario,epoch,width,height)
        demand(natural(table.at(row,"width"),"width") == w && natural(table.at(row,"height"),"height") == h, "wrong Cell dimensions")
        let path = table.at(row,"path"); oneOf(path,paths,"Cell path")
        let x = natural(table.at(row,"x"),"x"); let y = natural(table.at(row,"y"),"y")
        demand(x < w && y < h, "Cell outside complete frame")
        let key = cellKey(epoch,path,x,y)
        demand(!indexed.contains(key), "duplicate Cell ${key}")
        let glyph = table.at(row,"grapheme_utf8_hex")
        demand(glyph.size % 2 == 0, "odd UTF8 hex length ${key}"); hex(glyph,glyph.size,key)
        validateUtf8Hex(glyph)
        let columns = natural(table.at(row,"cell_width"),"cell_width")
        demand(columns <= 2, "invalid Cell width ${key}")
        for (name in ["continuation","transparent","bold","dim","italic","underline","inverse","strikethrough"]) {
            oneOf(table.at(row,name),["true","false"],name)
        }
        demand((table.at(row,"continuation") == "true") == (columns == 0), "continuation width mismatch ${key}")
        if (columns == 0) { demand(glyph.isEmpty(), "continuation has grapheme ${key}") }
        else { demand(!glyph.isEmpty(), "leader has empty grapheme ${key}") }
        validateRawColor(table.at(row,"foreground")); validateRawColor(table.at(row,"background"))
        indexed.add(key,row)
    }
    for (epoch in 0..(period + 1)) {
        let (w,h) = frameSize(scenario,epoch,width,height)
        for (path in paths) { for (y in 0..h) { for (x in 0..w) {
            let key = cellKey(epoch,path,x,y)
            demand(indexed.contains(key), "missing complete Cell ${key}")
            let row = indexed.get(key).getOrThrow()
            if (natural(table.at(row,"cell_width"),"cell_width") == 2) {
                demand(x + 1 < w, "right-clipped wide leader ${key}")
                let next = indexed.get(cellKey(epoch,path,x + 1,y)).getOrThrow()
                demand(table.at(next,"continuation") == "true", "missing wide partner ${key}")
                for (field in ["foreground","background","bold","dim","italic","underline","inverse","strikethrough","transparent"]) {
                    demand(table.at(next,field) == table.at(row,field), "wide partner style ${key}/${field}")
                }
            }
            if (table.at(row,"continuation") == "true") {
                demand(x > 0, "orphan continuation ${key}")
                let previous = indexed.get(cellKey(epoch,path,x - 1,y)).getOrThrow()
                demand(table.at(previous,"cell_width") == "2", "orphan continuation ${key}")
            }
            assertManualCell(table,row,scenario,epoch,x,y)
        } } }
    }
    indexed
}

func validateRawColor(value: String): Unit {
    for (name in ["Default","Black","Red","Green","Yellow","Blue","Magenta","Cyan","White",
        "BrightBlack","BrightRed","BrightGreen","BrightYellow","BrightBlue","BrightMagenta","BrightCyan","BrightWhite"]) {
        if (value == name) { return }
    }
    let indexed = value.split("Indexed(",1)
    if (indexed.size == 2 && indexed[0].isEmpty()) {
        let closed = indexed[1].split(")")
        demand(closed.size == 2 && closed[1].isEmpty() && natural(closed[0],"raw Indexed color") <= 255, "invalid raw color ${value}")
        return
    }
    let rgb = value.split("Rgb(",1)
    if (rgb.size == 2 && rgb[0].isEmpty()) {
        let closed = rgb[1].split(")")
        demand(closed.size == 2 && closed[1].isEmpty(), "invalid raw color ${value}")
        let channels = closed[0].split(",")
        demand(channels.size == 3, "raw Rgb requires three channels")
        for (channel in channels) { demand(natural(channel,"raw Rgb channel") <= 255,"raw Rgb channel outside byte range") }
        return
    }
    throw Exception("missing/noncanonical raw Color ${value}")
}

func validateCells(path: String, scenario: String, width: Int64, height: Int64, period: Int64, compat: Bool): Unit {
    let table = CsvTable(path)
    let paths = if (compat) { ["snapshot"] } else { ["m2","m1"] }
    let indexed = readCells(table,scenario,width,height,period,paths)
    if (!compat) {
        for (epoch in 0..(period + 1)) {
            let (w,h) = frameSize(scenario,epoch,width,height)
            for (y in 0..h) { for (x in 0..w) {
                let actual = indexed.get(cellKey(epoch,"m2",x,y)).getOrThrow()
                let expected = indexed.get(cellKey(epoch,"m1",x,y)).getOrThrow()
                for (field in cellFields()) {
                    demand(table.at(actual,field) == table.at(expected,field),
                        "Cell mismatch epoch=${epoch} (${x},${y}) field=${field} m2=${actual} m1=${expected}")
                }
            } }
        }
    }
}

func compareCells(oldPath: String, newPath: String, scenario: String, width: Int64, height: Int64, period: Int64): Unit {
    let oldTable = CsvTable(oldPath); let newTable = CsvTable(newPath)
    let oldRows = readCells(oldTable,scenario,width,height,period,["snapshot"])
    let newRows = readCells(newTable,scenario,width,height,period,["snapshot"])
    for (epoch in 0..(period + 1)) {
        let (w,h) = frameSize(scenario,epoch,width,height)
        for (y in 0..h) { for (x in 0..w) {
            let key = cellKey(epoch,"snapshot",x,y)
            let oldRow = oldRows.get(key).getOrThrow(); let newRow = newRows.get(key).getOrThrow()
            for (field in cellFields()) {
                demand(oldTable.at(oldRow,field) == newTable.at(newRow,field),
                    "old/new Cell mismatch ${key}/${field} old=${oldRow} new=${newRow}")
            }
        } }
    }
}

package rendering_benchmark_tests

func validatorSelftest(fixtures: String): Unit {
    let rows = parseCsv("a,b\r\n\"with,comma\",\"quote\"\"and\nline\"\r\n".toArray())
    demand(rows.size == 2 && rows[1].size == 2 && rows[1][0] == "with,comma" && rows[1][1] == "quote\"and\nline", "RFC4180 literal decode")
    for (invalid in ["a,\"unterminated", "\"closed\"junk,b", "a,un\"quoted", "a\rb"]) {
        var rejected = false
        try { parseCsv(invalid.toArray()) } catch (_: Exception) { rejected = true }
        demand(rejected,"invalid CSV accepted")
    }
    for (invalid in ["", "-1", "1.5", "nan", "18446744073709551615"]) {
        var rejected = false
        try { natural(invalid,"literal invalid integer") } catch (_: Exception) { rejected = true }
        demand(rejected,"invalid metric integer accepted")
    }
    for (valid in ["","41","65cc81","f09f91a9e2808df09f92bb"]) { validateUtf8Hex(valid) }
    for (valid in ["Default","BrightRed","Indexed(255)","Rgb(1,2,3)"]) { validateRawColor(valid) }
    for (invalid in ["ff","c080","eda080"]) {
        var rejected = false
        try { validateUtf8Hex(invalid) } catch (_: Exception) { rejected = true }
        demand(rejected,"invalid Cell UTF8 hex accepted")
    }
    validateCells("${fixtures}/cells-valid.csv","fixture",2,1,0,false)
    validateCarets("${fixtures}/caret-valid.csv","fixture",2,1,0,false)
    var cellsRejected = false; var caretRejected = false
    try { validateCells("${fixtures}/cells-mismatch.csv","fixture",2,1,0,false) } catch (_: Exception) { cellsRejected = true }
    try { validateCarets("${fixtures}/caret-mismatch.csv","fixture",2,1,0,false) } catch (_: Exception) { caretRejected = true }
    demand(cellsRejected && caretRejected,"full Cell mismatch or independent caret change was accepted")
    let (requested,bytes,calls,failed,shorts) = nativeReturns("${fixtures}/native-returns.trace","1</dev/pts/7>")
    demand(requested == 17 && bytes == 11 && calls == 3 && failed == 1 && shorts == 1,
        "native returns expected requested=17 bytes=11 calls=3 failed=1 short=1; actual requested=${requested} bytes=${bytes} calls=${calls} failed=${failed} short=${shorts}")
    var rejected = false
    try { nativeReturns("${fixtures}/incomplete.trace","1</dev/pts/7>") } catch (_: Exception) { rejected = true }
    demand(rejected,"unfinished native trace counted as complete evidence")
}

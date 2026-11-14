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
    let (requested,bytes,calls,failed,shorts) = nativeReturns("${fixtures}/native-returns.trace","1</dev/pts/7>")
    demand(requested == 17 && bytes == 11 && calls == 3 && failed == 1 && shorts == 1,
        "native returns must distinguish success/short/EINTR/writev/other fd/PTY read chunks")
    var rejected = false
    try { nativeReturns("${fixtures}/incomplete.trace","1</dev/pts/7>") } catch (_: Exception) { rejected = true }
    demand(rejected,"unfinished native trace counted as complete evidence")
}

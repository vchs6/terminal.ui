package rendering_benchmark_tests

import std.fs.File

// Deliberately fails closed on unfinished/resumed syscalls. Such a trace needs
// a complete-aware external observer; it cannot yield claimed valid totals.
func nativeReturns(path: String, targetFd: String): (Int64,Int64,Int64,Int64,Int64) {
    let text = String.fromUtf8(File.readFrom(path))
    demand(!text.isEmpty(), "empty native trace ${path}")
    var requested: Int64 = 0; var successful: Int64 = 0
    var calls: Int64 = 0; var failed: Int64 = 0; var shorts: Int64 = 0
    for (line in text.split("\n")) {
        if (line.isEmpty()) { continue }
        demand(line.split("<unfinished ...>").size == 1 && line.split("resumed>").size == 1,
            "incomplete native trace requires complete-aware observer: ${path}")
        var parts = line.split("write(",2)
        var vector = false
        if (parts.size == 1) { parts = line.split("writev(",2); vector = true }
        if (parts.size == 1) { continue }
        let body = parts[1]
        let fdParts = body.split(", ",2)
        demand(fdParts.size == 2, "unparseable native write ${line}")
        if (fdParts[0] != targetFd) { continue }
        let completed = body.split(") = ")
        demand(completed.size >= 2, "missing native return ${line}")
        let result = completed[completed.size - 1].split(" ",removeEmpty:true)
        demand(result.size > 0, "empty native return")
        var amount: Int64 = 0
        if (vector) {
            let vectors = completed[0].split("iov_len=")
            demand(vectors.size > 1, "writev trace omits iov_len; require verbose trace")
            for (i in 1..vectors.size) {
                let lengthParts = vectors[i].split("}",2)
                demand(lengthParts.size == 2, "truncated writev iovec")
                amount += natural(lengthParts[0],"iov_len")
            }
        } else {
            let arguments = completed[0].split(", ")
            amount = natural(arguments[arguments.size - 1],"write requested bytes")
        }
        requested += amount
        if (result[0] == "-1" || result[0] == "0") { failed++ }
        else {
            let returned = natural(result[0],"write returned bytes")
            demand(returned <= amount, "write return exceeds request")
            successful += returned; calls++
            if (returned < amount) { shorts++ }
        }
    }
    (requested,successful,calls,failed,shorts)
}

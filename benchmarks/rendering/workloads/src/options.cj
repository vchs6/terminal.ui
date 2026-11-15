package rendering_workloads

import std.collection.HashSet

// Parsed before starting a session or creating any output file.
public class Options {
    public var mode = ""
    public var scenario = ""
    public var width: Int64 = 0
    public var height: Int64 = 0
    public var seed: Int64 = -1
    public var warmup: Int64 = -1
    public var updates: Int64 = 0
    public var repetition: Int64 = -1
    public var runId = ""
    public var csv = ""
    public var cellsCsv = ""
    public var caretCsv = ""

    public init(args: Array<String>, diagnostic: Bool) {
        let seen = HashSet<String>()
        var i: Int64 = 0
        while (i < args.size) {
            let key = args[i]
            if (seen.contains(key) || i + 1 >= args.size) { throw Exception("duplicate or incomplete option ${key}") }
            seen.add(key)
            let value = args[i + 1]
            if (key == "--mode") { mode = value }
            else if (key == "--scenario") { scenario = value }
            else if (key == "--width") { width = natural(value, key) }
            else if (key == "--height") { height = natural(value, key) }
            else if (key == "--seed") { seed = natural(value, key) }
            else if (key == "--warmup") { warmup = natural(value, key) }
            else if (key == "--updates") { updates = natural(value, key) }
            else if (key == "--repetition") { repetition = natural(value, key) }
            else if (key == "--run-id") { runId = value }
            else if (key == "--csv") { csv = value }
            else if (key == "--cells-csv") { cellsCsv = value }
            else if (key == "--caret-csv") { caretCsv = value }
            else { throw Exception("unknown option ${key}") }
            i += 2
        }
        if (!eligible(mode, scenario, diagnostic)) { throw Exception("unsupported mode/scenario ${mode}/${scenario}") }
        if (width <= 0 || height <= 0 || updates <= 0 || seed < 0 || warmup < 0 || repetition < 0 || runId.isEmpty() || csv.isEmpty()) {
            throw Exception("missing or invalid required option")
        }
        if (mode == "correctness" && (cellsCsv.isEmpty() || caretCsv.isEmpty())) {
            throw Exception("correctness requires --cells-csv and --caret-csv")
        }
    }
}

private func natural(text: String, label: String): Int64 {
    if (text.isEmpty()) { throw Exception("empty integer ${label}") }
    var value: Int64 = 0
    for (byte in text.toArray()) {
        if (byte < 48 || byte > 57) { throw Exception("invalid integer ${label}") }
        let digit = Int64(byte - 48)
        if (value > (Int64.Max - digit) / 10) { throw Exception("integer overflow ${label}") }
        value = value * 10 + digit
    }
    value
}

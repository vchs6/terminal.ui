package rendering_benchmark_tests

import std.collection.ArrayList
import std.fs.File

// Independent report reader; never imports a benchmark or production helper.
class CsvTable {
    let columns: Array<String>
    let rows: Array<Array<String>>
    init(columns: Array<String>, rows: Array<Array<String>>) {
        this.columns = columns; this.rows = rows
    }
    init(path: String) {
        let parsed = parseCsv(File.readFrom(path))
        demand(parsed.size > 1, "empty CSV or header without data: ${path}")
        let headings = parsed[0]
        for (i in 0..headings.size) {
            demand(!headings[i].isEmpty(), "empty CSV heading: ${path}")
            for (j in 0..i) { demand(headings[i] != headings[j], "duplicate heading ${headings[i]}") }
        }
        let body = Array<Array<String>>(parsed.size - 1, {i => parsed[i + 1]})
        for (row in body) { demand(row.size == headings.size, "ragged CSV: ${path}") }
        this.columns = headings; this.rows = body
    }
    func at(row: Array<String>, name: String): String {
        for (i in 0..columns.size) { if (columns[i] == name) { return row[i] } }
        throw Exception("missing CSV column ${name}")
    }
    func hasColumn(name: String): Bool {
        for (column in columns) { if (column == name) { return true } }
        false
    }
    func requireColumns(names: Array<String>): Unit {
        for (name in names) {
            var found = false
            for (column in columns) { if (column == name) { found = true } }
            demand(found, "missing CSV column ${name}")
        }
    }
}

func parseCsv(bytes: Array<UInt8>): Array<Array<String>> {
    let result = ArrayList<Array<String>>()
    let row = ArrayList<String>()
    let field = ArrayList<UInt8>()
    var quoted = false
    var closed = false
    var index: Int64 = 0
    var endedRow = false
    while (index < bytes.size) {
        let value = bytes[index]
        endedRow = false
        if (quoted) {
            if (value == 34) {
                if (index + 1 < bytes.size && bytes[index + 1] == 34) {
                    field.add(34); index++
                } else { quoted = false; closed = true }
            } else { field.add(value) }
        } else if (value == 44) {
            row.add(String.fromUtf8(field.toArray())); field.clear(); closed = false
        } else if (value == 10 || value == 13) {
            if (value == 13) {
                demand(index + 1 < bytes.size && bytes[index + 1] == 10, "CSV bare CR")
                index++
            }
            row.add(String.fromUtf8(field.toArray())); field.clear(); closed = false
            result.add(row.toArray()); row.clear(); endedRow = true
        } else if (value == 34) {
            demand(field.isEmpty() && !closed, "quote inside unquoted CSV field")
            quoted = true
        } else {
            demand(!closed, "data after closed CSV quote")
            field.add(value)
        }
        index++
    }
    demand(!quoted, "unterminated CSV quote")
    if (bytes.size > 0 && !endedRow) {
        row.add(String.fromUtf8(field.toArray())); result.add(row.toArray())
    }
    result.toArray()
}

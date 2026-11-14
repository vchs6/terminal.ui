package rendering_benchmark_tests

func demand(value: Bool, label: String): Unit {
    if (!value) { throw Exception(label) }
}

func natural(text: String, label: String): Int64 {
    demand(!text.isEmpty(), "empty integer: ${label}")
    var value: Int64 = 0
    for (byte in text.toArray()) {
        demand(byte >= 48 && byte <= 57, "nonnegative integer required: ${label}=${text}")
        let digit = Int64(byte - 48)
        demand(value <= (Int64.Max - digit) / 10, "integer overflow: ${label}")
        value = value * 10 + digit
    }
    value
}

func metric(table: CsvTable, row: Array<String>, name: String, unavailable!: Bool = false): Int64 {
    let text = table.at(row, name)
    if (text == "not_available") {
        demand(unavailable, "required metric unavailable: ${name}")
        let reason = table.at(row, "limitations")
        demand(!reason.isEmpty() && reason != "none" && reason != "not_available", "unexplained unavailable ${name}")
        return -1
    }
    natural(text, name)
}

func oneOf(value: String, values: Array<String>, label: String): Unit {
    for (candidate in values) { if (value == candidate) { return } }
    throw Exception("invalid ${label}=${value}")
}

func hex(value: String, length: Int64, label: String): Unit {
    demand(value.size == length, "wrong hex length ${label}")
    for (byte in value.toArray()) {
        demand((byte >= 48 && byte <= 57) || (byte >= 97 && byte <= 102), "lowercase hex required: ${label}")
    }
}

func validateUtf8Hex(value: String): Unit {
    let encoded = value.toArray()
    let bytes = Array<UInt8>(encoded.size / 2, {i =>
        let high = if (encoded[i * 2] <= 57) { encoded[i * 2] - 48 } else { encoded[i * 2] - 87 }
        let low = if (encoded[i * 2 + 1] <= 57) { encoded[i * 2 + 1] - 48 } else { encoded[i * 2 + 1] - 87 }
        high * 16 + low
    })
    let roundTrip = String.fromUtf8(bytes).toArray()
    demand(roundTrip.size == bytes.size, "Cell hex is not lossless UTF8")
    for (i in 0..bytes.size) { demand(bytes[i] == roundTrip[i], "Cell hex contains invalid UTF8") }
}

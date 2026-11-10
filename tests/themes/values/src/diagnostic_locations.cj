package theme_values_contract
import cjtui.theme.*
func diagnosticLocations(): Unit {
    // U+754C before the failing value makes UTF8 offsets differ from Rune offsets.
    let input = "schema_version=1\nname=\"界\"\n[text]\nforeground={ref=\"missing\"}\n"
    let d = failure(input, "UnknownReference", "text.foreground")
    check(d.message.size > 0, "diagnostic carries human context")
    check(d.location.isSome(), "valid ref metadata must not be discarded as unavailable")
    match (d.location) {
        case Some(loc) =>
            let runes = input.toRuneArray()
            check(loc.runeStart >= 0 && loc.runeLength > 0 && loc.runeStart + loc.runeLength <= runes.size, "Rune location is a bounded nonempty range")
            var line: Int64 = 1
            var column: Int64 = 1
            for (i in 0..loc.runeStart) {
                if (runes[i] == r'\n') { line++; column = 1 } else { column++ }
            }
            check(loc.line == line && loc.column == column, "line/column agree with Rune offset, not UTF8 bytes")
            check(d.locationScope == "value" || d.locationScope == "table", "known parser metadata yields value or parent-table scope")
            if (d.locationScope == "value") {
                let selected = String(runes[loc.runeStart..loc.runeStart + loc.runeLength])
                check(selected.contains("missing"), "reference diagnostic locates ref value rather than variable declaration")
            }
        case None => throw Exception("missing available reference source location")
    }
    try { Theme.readFile("../.scratch/not-present") }
    catch (e: ThemeException) {
        check(e.diagnostic.code == "ReadFailed" && e.diagnostic.keyPath == "", "read error is separate from parser errors")
        check(e.diagnostic.location.isNone(), "read error does not invent source coordinates")
        return
    }
    throw Exception("missing file unexpectedly read")
}

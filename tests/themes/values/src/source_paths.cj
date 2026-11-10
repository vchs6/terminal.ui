package theme_values_contract
import cjtui.style.*
import cjtui.theme.*
func sourcePaths(): Unit {
    let memory = Theme.parse("schema_version=1\nname=\"  Label  \"", sourceName: "/looks/like/file.toml")
    check(memory.name == "  Label  " && memory.schemaVersion == 1, "name saved verbatim and schemaVersion read-only value")
    check(memory.sourcePath.isNone() && memory.sourceName == "/looks/like/file.toml", "parse source label never implies file identity")
    check(memory.componentRule(ThemeRole.Button) == StyleRule(), "missing role returns empty immutable rule")
    check(memory.namedStyle("missing").isNone() && memory.namedStyle("bad.name").isNone() && memory.namedStyle("").isNone(), "missing or invalid named lookup returns None")
    for (path in ["../.scratch/~", "../.scratch/" + "$" + "HOME", "../.scratch/" + "$" + "{HOME}", "../.scratch/https:literal", "../.scratch/https://literal.test/theme.toml"]) {
        let value = Theme.readFile(path)
        check(value.name == "Literal", "literal path read ${path}")
        match (value.sourcePath) {
            case Some(absolute) => check(absolute.startsWith("/") && value.sourceName == absolute, "file freezes absolute path and source name")
            case None => throw Exception("readFile discarded file source")
        }
    }
    for (path in ["", "bad\u{0}path"]) {
        var rejected = false
        try { Theme.readFile(path) }
        catch (e: ThemeException) { rejected = e.diagnostic.code == "InvalidPath" && e.diagnostic.location.isNone() }
        check(rejected, "empty/NUL paths rejected without invented location")
    }
    capacityFile("invalid-utf8.toml", "InvalidUtf8")
    let before = Theme.readFile("../.scratch/source.toml")
    let derived = before.textDefaults().withValue(StyleKeys.bold, StyleValue<Bool>.Value(true))
    check(before.textDefaults() == StyleRule() && derived != before.textDefaults(), "read-only bridge cannot mutate Theme through returned rule")
}

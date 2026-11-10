package theme_values_contract
import cjtui.style.*
import cjtui.theme.*
func check(value: Bool, name: String): Unit {
    if (!value) { throw Exception("FAIL: ${name}") }
    println("PASS: ${name}")
}
func parseBody(body: String): Theme {
    Theme.parse("schema_version=1\nname=\"Case\"\n" + body)
}
func named(value: Theme, name: String): StyleRule {
    match (value.namedStyle(name)) {
        case Some(rule) => rule
        case None => throw Exception("missing expected style ${name}")
    }
}
func failure(text: String, code: String, path: String): ThemeDiagnostic {
    try { Theme.parse(text, sourceName: "case:界") }
    catch (e: ThemeException) {
        check(e.diagnostic.code == code, "diagnostic ${path}: ${e.diagnostic.code}, expected ${code}")
        check(e.diagnostic.keyPath == path, "diagnostic keyPath ${path}: ${e.diagnostic.keyPath}")
        check(e.diagnostic.source == "case:界", "diagnostic source survives")
        return e.diagnostic
    }
    throw Exception("expected ${code} at ${path}")
}
func invalid(body: String, code: String, path: String): Unit {
    failure("schema_version=1\nname=\"Case\"\n" + body, code, path)
}
func capacityFile(name: String, expectedCode: String): Unit {
    try { Theme.readFile("../.scratch/" + name) }
    catch (e: ThemeException) {
        check(e.diagnostic.code == expectedCode, "${name}: got ${e.diagnostic.code}, expected ${expectedCode}")
        return
    }
    check(expectedCode == "OK", "${name} was accepted unexpectedly")
}

func malformedRecord(body: String, path: String): Unit {
    try {parseBody(body)}
    catch(e:ThemeException) {
        check(e.diagnostic.code=="InvalidValue" || e.diagnostic.code=="UnknownKey" || e.diagnostic.code=="InvalidType", "malformed declaration record has schema diagnostic")
        check(e.diagnostic.keyPath.startsWith(path), "malformed declaration record identifies property")
        return
    }
    throw Exception("malformed declaration record was accepted ${path}")
}

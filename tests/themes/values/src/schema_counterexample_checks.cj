package theme_values_contract
import cjtui.style.*
import cjtui.theme.*

func schemaCase(label: String, action: () -> Unit): Bool {
    try { action();println("CASE PASS ${label}");return true }
    catch (e: Exception) { println("CASE FAIL ${label}: ${e.message}");return false }
}
func schemaInput(body: String): String { "schema_version=1\nname=\"界 Case\"\n"+body }
func schemaExpectedError(input: String, code: String, path: String, label: String, marker!: String = ""): Unit {
    let source = "caller-label:界/"+label
    println("EXPECT ${label}: ${code} at ${path}; source=${source}")
    try { Theme.parse(input,sourceName:source) }
    catch (e: ThemeException) {
        let d=e.diagnostic
        println("OBSERVED ${label}: ${d.code} at ${d.keyPath}; source=${d.source}; scope=${d.locationScope}")
        check(d.code==code,"${label}: actual code ${d.code}, expected ${code}")
        check(d.keyPath==path,"${label}: actual path ${d.keyPath}, expected ${path}")
        check(d.source==source,"${label}: caller source identity must survive")
        schemaLocation(input,d,label)
        if (!marker.isEmpty() && d.locationScope=="value") {
            let loc=d.location.getOrThrow()
            let selected=String(input.toRuneArray()[loc.runeStart..loc.runeStart+loc.runeLength])
            check(selected.contains(marker),"${label}: value source range contains independently specified literal ${marker}")
        }
        return
    }
    println("OBSERVED ${label}: parse accepted")
    throw Exception("${label}: parse accepted, expected ${code} at ${path}")
}
func schemaLocation(input: String, d: ThemeDiagnostic, label: String): Unit {
    match (d.location) {
        case Some(loc) =>
            let runes=input.toRuneArray()
            check(loc.runeStart>=0 && loc.runeLength>0 && loc.runeStart+loc.runeLength<=runes.size,"${label}: bounded nonempty source Rune range")
            var line: Int64=1
            var column: Int64=1
            for(i in 0..loc.runeStart) {
                if(runes[i]==r'\n') { line++;column=1 } else { column++ }
            }
            check(loc.line==line && loc.column==column,"${label}: line/column agree with source Runes")
            check(d.locationScope=="value" || d.locationScope=="table" || d.locationScope=="document","${label}: available source scope")
        case None => check(d.locationScope=="unavailable","${label}: absent location is explicit, never fabricated")
    }
}
func schemaPositiveControl(): Unit {
    let value=Theme.parse("schema_version=1\nname=\"Public positive\"\ntext.bold=true\n",sourceName:"positive:label")
    check(value.name=="Public positive" && value.schemaVersion==1,"real public Theme value positive")
    check(value.textDefaults()==StyleRule().withValue(StyleKeys.bold,StyleValue<Bool>.Value(true)),"real typed textDefaults positive")
}

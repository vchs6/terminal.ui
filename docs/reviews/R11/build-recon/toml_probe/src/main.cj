package toml_probe
import cangjie_toml.cangjie_toml.*
import cangjie_toml.cangjie_toml.parser.*
import stdx.serialization.serialization.*

func table(dm: DataModel): DataModelStruct { (dm as DataModelStruct).getOrThrow() }
func check(value: Bool, message: String): Unit { if (!value) { throw Exception(message) } }
func negative(name: String, input: String): Unit {
    try {
        let _ = DataModel.fromToml(input)
        throw Exception("unexpected accepted ${name}")
    } catch (e: ParseException) {
        check(e.position.line > 0 && e.position.col > 0, "missing position")
        println("negative ${name}: line=${e.position.line} col=${e.position.col} start=${e.position.start} len=${e.position.len} key=${e.lastKey}; ${e.message}")
    }
}
main(): Unit {
    let input = "schema_version = 1\nname = \"example-dark\"\n[variables]\naccent = { type = \"color\", value = \"#66CCFF\" }\n[text]\nforeground = { ref = \"accent\" }\n[styles.emphasis]\nbold = true\n[components.button.states.disabled]\nforeground = { reset = true }\n"
    let dm = table(DataModel.fromToml(input))
    check(Int64.deserialize(dm.get("schema_version")) == 1, "version")
    let vars = table(dm.get("variables"))
    check(String.deserialize(table(vars.get("accent")).get("type")) == "color", "typed variable")
    check(String.deserialize(table(table(dm.get("text")).get("foreground")).get("ref")) == "accent", "ref")
    check(Bool.deserialize(table(table(dm.get("styles")).get("emphasis")).get("bold")), "style")
    let states = table(table(table(dm.get("components")).get("button")).get("states"))
    check(Bool.deserialize(table(table(states.get("disabled")).get("foreground")).get("reset")), "reset")
    println("positive typed/ref/style/state/reset=true")
    let parser = Parser(input)
    parser.parse()
    let pos = parser.keyInfo.get("styles.emphasis.bold").getOrThrow().pos.withCol(input.toRuneArray())
    println("metadata styles.emphasis.bold: line=${pos.line} col=${pos.col} start=${pos.start} len=${pos.len}")
    negative("duplicate", "[text]\nbold = true\nbold = false\n")
    negative("syntax", "[text]\nforeground = { ref = }\n")
    negative("unterminated", "name = \"oops\n")
}

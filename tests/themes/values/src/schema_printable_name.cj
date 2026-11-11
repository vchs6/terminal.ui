package theme_values_contract
import cjtui.theme.*

func schemaPrintableName(): Unit {
    var failed: Int64=0
    if(!schemaCase("name-U0001",{=>schemaExpectedError("schema_version=1\nname=\"A\\u0001B\"\n","InvalidValue","name","name-U0001")})) { failed++ }
    if(!schemaCase("name-ESC",{=>schemaExpectedError("schema_version=1\nname=\"A\\u001bB\"\n","InvalidValue","name","name-ESC")})) { failed++ }
    if(!schemaCase("name-blank",{=>schemaExpectedError("schema_version=1\nname=\"   \"\n","InvalidValue","name","name-blank")})) { failed++ }
    for (value in ["  Case  ","  主题 é  ","  👩‍💻  ","1979-05-27"]) {
        if(!schemaCase("name-retains-${value}",{=>check(Theme.parse("schema_version=1\nname=\""+value+"\"\n").name==value,"valid printable name retains exact original")})) { failed++ }
    }
    check(failed==0,"printable-name counterexamples: ${failed} failed")
}

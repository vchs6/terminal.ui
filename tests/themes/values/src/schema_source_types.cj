package theme_values_contract
import cjtui.theme.*

func schemaSourceTypes(): Unit {
    var failed: Int64=0
    // These four are native TOML values, not quoted TOML strings.
    let nativeDates=["1979-05-27T07:32:00Z","1979-05-27T07:32:00","1979-05-27","07:32:00"]
    for (literal in nativeDates) {
        if(!schemaCase("name-native-${literal}",{=>schemaExpectedError("schema_version=1\nname="+literal+"\n","InvalidType","name","name-native-${literal}",marker:literal)})) { failed++ }
        for (path in ["text.foreground","text.align","text.wrap","text.overflow","decoration.border","spacing.align_items","spacing.justify_content","spacing.width"]) {
            if(!schemaCase("${path}-native-${literal}",{=>schemaExpectedError(schemaInput(path+"="+literal+"\n"),"InvalidType",path,"${path}-native-${literal}",marker:literal)})) { failed++ }
        }
        for (kind in ["color","wrap","overflow","border","alignment","text_alignment","dimension","cells","offset"]) {
            if(!schemaCase("variable-${kind}-native-${literal}",{=>schemaExpectedError(schemaInput("[variables.v]\ntype=\""+kind+"\"\nvalue="+literal+"\n"),"InvalidType","variables.v.value","variable-${kind}-native-${literal}",marker:literal)})) { failed++ }
        }
        if(!schemaCase("ref-native-${literal}",{=>schemaExpectedError(schemaInput("text.bold={ref="+literal+"}\n"),"InvalidType","text.bold","ref-native-${literal}",marker:literal)})) { failed++ }
    }
    for (path in ["spacing.width","spacing.height","spacing.min_width","spacing.min_height","spacing.weight","spacing.gap","spacing.padding_left","spacing.padding_right","spacing.padding_top","spacing.padding_bottom","decoration.shadow_offset_x","decoration.shadow_offset_y"]) {
        for (literal in ["true","1.0","1979-05-27","07:32:00"]) {
            if(!schemaCase("numeric-${path}-${literal}",{=>schemaExpectedError(schemaInput(path+"="+literal+"\n"),"InvalidType",path,"numeric-${path}-${literal}",marker:literal)})) { failed++ }
        }
        // Dimension accepts the string literal "auto"; a numeric string is a
        // wrong enum value there, but is a wrong type for cells/offset slots.
        let code=if(path=="spacing.width" || path=="spacing.height") { "InvalidValue" } else { "InvalidType" }
        if(!schemaCase("numeric-string-${path}",{=>schemaExpectedError(schemaInput(path+"=\"1\"\n"),code,path,"numeric-string-${path}")})) { failed++ }
    }
    if(!schemaCase("quoted-date-name",{=>check(Theme.parse("schema_version=1\nname=\"1979-05-27\"\n").name=="1979-05-27","quoted date is a legitimate string name")})) { failed++ }
    if(!schemaCase("quoted-date-color",{=>schemaExpectedError(schemaInput("text.foreground=\"1979-05-27\"\n"),"InvalidValue","text.foreground","quoted-date-color")})) { failed++ }
    if(!schemaCase("caller-source-root-variables",{=>schemaExpectedError(schemaInput("variables=true\n"),"InvalidType","variables","caller-source-root-variables",marker:"true")})) { failed++ }
    check(failed==0,"source type counterexamples: ${failed} failed")
}

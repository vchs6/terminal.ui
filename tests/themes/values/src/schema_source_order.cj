package theme_values_contract
import cjtui.style.*
import cjtui.theme.*

func schemaSourceOrder(): Unit {
    var failed: Int64=0
    if(!schemaCase("spacing-before-text",{=>schemaExpectedError(schemaInput("spacing.min_width=\"bad\"\n[text]\nbold=1\n"),"InvalidType","spacing.min_width","spacing-before-text")})) { failed++ }
    if(!schemaCase("text-before-spacing",{=>schemaExpectedError(schemaInput("text.bold=1\n[spacing]\nmin_width=\"bad\"\n"),"InvalidType","text.bold","text-before-spacing")})) { failed++ }
    // An early dotted style prefix must not drag a later nested-table error
    // ahead of spacing. The later header adds a new subtable, not a redefinition.
    if(!schemaCase("implicit-explicit-interleave",{=>schemaExpectedError(schemaInput("styles.x.text.foreground=\"red\"\nspacing.gap=\"bad\"\n[styles.x.states.normal.text]\nbold=1\n"),"InvalidType","spacing.gap","implicit-explicit-interleave")})) { failed++ }
    if(!schemaCase("style-before-variable",{=>schemaExpectedError(schemaInput("[styles.x.text]\nwrap=\"word\"\n[variables.bad]\ntype=\"bool\"\nvalue=1\n"),"InvalidValue","styles.x.text.wrap","style-before-variable")})) { failed++ }
    if(!schemaCase("variable-before-style",{=>schemaExpectedError(schemaInput("[variables.bad]\ntype=\"bool\"\nvalue=1\n[styles.x.text]\nwrap=\"word\"\n"),"InvalidType","variables.bad.value","variable-before-style")})) { failed++ }
    if(!schemaCase("early-ref-before-bad-variable",{=>schemaExpectedError(schemaInput("text.foreground={ref=\"missing\"}\n[variables.bad]\ntype=\"bool\"\nvalue=1\n"),"UnknownReference","text.foreground","early-ref-before-bad-variable")})) { failed++ }
    if(!schemaCase("unknown-before-bad-variable",{=>schemaExpectedError(schemaInput("extra=true\n[variables.bad]\ntype=\"bool\"\nvalue=1\n"),"UnknownKey","extra","unknown-before-bad-variable")})) { failed++ }
    if(!schemaCase("valid-style-prefix-variable-first",{=>schemaExpectedError(schemaInput("[styles.x.text]\nforeground=\"red\"\n[variables.bad]\ntype=\"bool\"\nvalue=1\n[styles.x.states.normal.text]\nbold=1\n"),"InvalidType","variables.bad.value","valid-style-prefix-variable-first")})) { failed++ }
    if(!schemaCase("role-before-style",{=>schemaExpectedError(schemaInput("[components.unknown.text]\nbold=true\n[styles.x.text]\nwrap=\"word\"\n"),"UnknownRole","components.unknown","role-before-style")})) { failed++ }
    if(!schemaCase("style-before-role",{=>schemaExpectedError(schemaInput("[styles.x.text]\nwrap=\"word\"\n[components.unknown.text]\nbold=true\n"),"InvalidValue","styles.x.text.wrap","style-before-role")})) { failed++ }
    if(!schemaCase("early-mismatch-before-style",{=>schemaExpectedError(schemaInput("text.bold={ref=\"color\"}\n[styles.x.text]\nwrap=\"word\"\n[variables.color]\ntype=\"color\"\nvalue=\"red\"\n"),"ReferenceTypeMismatch","text.bold","early-mismatch-before-style")})) { failed++ }
    if(!schemaCase("version-before-unknown",{=>schemaExpectedError("schema_version=2\nname=\"Case\"\nextra=true\n","UnsupportedVersion","schema_version","version-before-unknown")})) { failed++ }
    if(!schemaCase("required-name-before-unknown",{=>schemaExpectedError("schema_version=1\nextra=true\n","MissingRequired","name","required-name-before-unknown")})) { failed++ }
    if(!schemaCase("required-version-before-unknown",{=>schemaExpectedError("name=\"Case\"\nextra=true\n","MissingRequired","schema_version","required-version-before-unknown")})) { failed++ }
    if(!schemaCase("root-name-before-unknown",{=>schemaExpectedError("schema_version=1\nextra=true\nname=\"   \"\n","InvalidValue","name","root-name-before-unknown")})) { failed++ }
    if(!schemaCase("syntax-before-version",{=>
        let source="caller-label:syntax-before-version"
        let input="schema_version=2\nname=\"Case\"\ntext.bold=[\n"
        try { Theme.parse(input,sourceName:source) }
        catch(e:ThemeException) {
            println("OBSERVED syntax-before-version: ${e.diagnostic.code}; source=${e.diagnostic.source}")
            check(e.diagnostic.code=="SyntaxError" && e.diagnostic.source==source,"syntax precedes version/schema")
            schemaLocation(input,e.diagnostic,"syntax-before-version")
            return
        }
        throw Exception("syntax error accepted")
    })) { failed++ }
    if(!schemaCase("valid-forward-ref-across-categories",{=>
        let value=Theme.parse(schemaInput("text.foreground={ref=\"later\"}\n[styles.good.text]\nbold=true\n[variables.later]\ntype=\"color\"\nvalue=\"red\"\n"))
        check(value.textDefaults()==StyleRule().withValue(StyleKeys.foreground,StyleValue<Color>.Value(Color.Red)),"collect all variables for legal forward reference")
        check(named(value,"good")==StyleRule().withValue(StyleKeys.bold,StyleValue<Bool>.Value(true)),"valid style remains independent")
    })) { failed++ }
    if(!schemaCase("valid-implicit-explicit-shape",{=>
        let value=Theme.parse(schemaInput("styles.x.text.foreground=\"red\"\nspacing.gap=0\n[styles.x.states.normal.text]\nbold=true\n"))
        check(named(value,"x")==StyleRule().withValue(StyleKeys.foreground,StyleValue<Color>.Value(Color.Red)).withValue(StyleKeys.bold,StyleValue<Bool>.Value(true)),"new nested table after dotted prefix is legal and disjoint")
    })) { failed++ }
    check(failed==0,"source-order counterexamples: ${failed} failed")
}

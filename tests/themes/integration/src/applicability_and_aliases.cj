package theme_integration_contract
import cjtui.*
func applicabilityAndAliases(): Unit {
    invalidNode({=>Text("x").styles([StyleUse.Named("missing")])},theme(""),"missing named style is not silently dropped")
    invalidNode({=>Text("x").styles([StyleUse.Named("bad.name")])},theme(""),"illegal named style is rejected")
    let gap=StyleRule().withValue(StyleKeys.gap,StyleValue<Int64>.Value(1))
    invalidNode({=>Text("x").styles([StyleUse.Inline(gap)])},theme(""),"named/inline applicability uses actual primitive")
    let wrap=StyleRule().withValue(StyleKeys.textWrap,StyleValue<TextWrap>.Value(TextWrap.Grapheme))
    invalidNode({=>Row {Text("x")}.themeRole(ThemeRole.Text).styles([StyleUse.Inline(wrap)])},theme(""),"changing role cannot give Row text primitive capabilities")
    let defaults=theme("[spacing]\ngap=1\n[text]\nwrap=\"grapheme\"\n")
    check(picture(Row {Text("A");Text("B")},defaults,3,1).toPlainText()=="A B","global defaults are projected only onto capable primitives")
    var uses=[StyleUse.Inline(StyleRule().withValue(StyleKeys.foreground,StyleValue<Color>.Value(Color.Red)))]
    let c=Text("x").styles(uses)
    uses[0]=StyleUse.Inline(StyleRule().withValue(StyleKeys.foreground,StyleValue<Color>.Value(Color.Blue)))
    check(classic(c,1,1).cellAt(0,0).style.foreground==Color.Red,"styles copies input array")
    let d=Text("x").styles([StyleUse.Inline(StyleRule().withValue(StyleKeys.bold,StyleValue<Bool>.Value(true)))]).styles([])
    check(!classic(d,1,1).cellAt(0,0).style.bold,"empty styles list clears all reusable declarations")
    let roleNode=Text("x");let app=Application(roleNode);app.startHeadless()
    try {
        var rejected=false
        try {app.batch({=>roleNode.themeRole(ThemeRole.Button);()})} catch(e:UIException){rejected=e.code=="InvalidProperty"}
        check(rejected,"role mutation after mount is rejected")
    } finally {app.dispose()}
}

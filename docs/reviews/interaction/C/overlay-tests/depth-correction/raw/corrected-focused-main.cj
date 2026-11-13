package interaction_c
import cjtui.*
import std.env.*
func themeFixtureParseControl():Unit {
let first=Theme.parse("schema_version=1\nname='first'\n[styles.host.text]\nbackground='#445566'\n[styles.owner.text]\nbackground='#112233'\n")
let second=Theme.parse("schema_version=1\nname='second'\n[styles.host.text]\nbackground='#445566'\n[styles.owner.text]\nbackground='#778899'\n")
    check(first.name=="first" && second.name=="second" && first.namedStyle("host").isSome() && first.namedStyle("owner").isSome(),"G11 existing Theme.parse accepts corrected .text fixture tables")
}
func anchorBackgroundControl():Unit {
    let anchor=Box<?Component>(Option<Component>.None)
    let root=ScrollView({=>anchor.value=Some(Text("AAAA").height(2));Text("tail").height(6)})
    let app=Application(root);app.startHeadless();app.snapshot(4,2)
    app.batch({=>node(root).scrollTo(0,1);()})
    let frame=app.snapshot(4,2);println("BASE=[${frame.toPlainText()}]")
    picture(frame,"    \ntail","G14 independent no-overlay public B background")
    app.dispose()
}
main():Int64 {
    match(getVariable("CJTUI_OVERLAY_FOCUSED").getOrThrow()) {
        case "boundary"=>layerDepthBoundary()
        case "0"=>layerCapacity(0)
        case "1"=>layerCapacity(1)
        case "2"=>layerCapacity(2)
        case "theme-parse"=>themeFixtureParseControl()
        case "G11"=>ownerThemeSurface()
        case "G13"=>directionalAnchors()
        case "G14-background"=>anchorBackgroundControl()
        case "G14"=>clippedAndLostAnchors()
        case _=>throw Exception("unknown focused case")
    }
    return 0
}

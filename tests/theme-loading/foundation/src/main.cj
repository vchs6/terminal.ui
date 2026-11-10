package theme_loading_foundation
import cjtui.*
main(): Int64 {
    let parsed=Theme.parse("schema_version=1\nname=\"Foundation\"\n[text]\nforeground=\"red\"\n")
    if(parsed.textDefaults().value(StyleKeys.foreground)!=StyleValue<Color>.Value(Color.Red)){throw Exception("foundation bridge missing")}
    let app=Application(Text("x"),theme:parsed)
    app.startHeadless()
    try {if(app.snapshot(1,1).cellAt(0,0).style.foreground!=Color.Red){throw Exception("foundation rendering missing")}}
    finally {app.dispose()}
    println("PASS real foundation gate; async-specific probe is now meaningful")
    0
}

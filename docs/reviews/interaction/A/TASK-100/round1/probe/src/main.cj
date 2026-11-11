package interaction_review_probe
import cjtui.*
main(): Int64 {
    let events=Box<String>("")
    let app=Application(Text("x"),theme:Theme.parse("schema_version=1\nname=\"probe\"\n"))
    app.onKey({e=>events.value+="${e.code}:${e.text}|";if(e.text=="q"){app.stop()}})
    app.run()
    println("EVENTS="+events.value)
    println("STATUS="+app.terminalCapabilities().getOrThrow().cursorVisibilityStatus)
    0
}

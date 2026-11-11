package theme_load_review_probe
import cjtui.*
import std.collection.ArrayList
func describe(request: ThemeRequest): String {
    match (request.result()) {
        case Some(ThemeResult.Applied(revision)) => "Applied(${revision})"
        case Some(ThemeResult.Failed(d)) => "Failed(${d.code})"
        case Some(ThemeResult.Superseded(id)) => "Superseded(${id})"
        case Some(ThemeResult.SessionClosed) => "SessionClosed"
        case None => "pending"
    }
}
func scenario(horizontal: Bool, subtree: Bool): Unit {
    let children = ArrayList<Component>()
    let root = if (horizontal) { Row { children.add(Text("a")); Text("b") } }
        else { Column { children.add(Text("a")); Text("b") } }
    let axis = if (horizontal) { "Row" } else { "Column" }
    let initial = Theme.parse("schema_version=1\nname=\"initial\"\n")
    let key = if (horizontal) { "min_width" } else { "min_height" }
    let candidate = Theme.parse("schema_version=1\nname=\"candidate\"\n[components.text.spacing]\nweight=1\n"+key+"=9223372036854775807\n")
    let app = Application(root,theme:initial); app.startHeadless()
    let width = if (horizontal) { Int64.Max } else { 0 }
    let height = if (horizontal) { 0 } else { Int64.Max }
    app.snapshot(width,height)
    println("INITIAL ${axis} subtree=${subtree}")
    let request = app.loadTheme(ThemeSource.Prepared(candidate))
    try {
        if (subtree) {
            render(children[0],1,1)
            println("AFTER_SUBTREE ${describe(request)} info=${app.themeInfo().name}")
        }
        app.snapshot(width,height)
        println("ROOT_SNAPSHOT_OK")
    } catch (error: Exception) { println("ROOT_SNAPSHOT_ERROR ${error.message}") }
    println("FINAL ${axis} subtree=${subtree} result=${describe(request)} info=${app.themeInfo().name}/${app.themeInfo().revision} post=${app.post({=>})}")
    app.dispose()
}
func paintControl(): Unit {
    let app = Application(Row {Text("a");Text("b")}); app.startHeadless(); app.snapshot(4,1)
    let before = app.stats().measures
    let request = app.loadTheme(ThemeSource.Prepared(Theme.parse("schema_version=1\nname=\"paint\"\n[text]\nforeground=\"blue\"\n")))
    app.snapshot(4,1)
    println("PAINT_ONLY result=${describe(request)} measures=${before}/${app.stats().measures}")
    app.dispose()
}
main(): Int64 {
    scenario(true,false); scenario(false,false)
    scenario(true,true); scenario(false,true)
    paintControl()
    0
}

package theme_load_review_probe
import cjtui.*
main(): Int64 {
    let root = Row { Text("a"); Text("b") }
    let initial = Theme.parse("schema_version=1\nname=\"initial\"\n")
    let candidate = Theme.parse("schema_version=1\nname=\"candidate\"\n[components.text.spacing]\nweight=1\nmin_width=9223372036854775807\n")
    let app = Application(root,theme:initial)
    app.startHeadless()
    let before = app.snapshot(Int64.Max,0)
    println("INITIAL width=${before.width} height=${before.height} theme=${app.themeInfo().name}")
    let request = app.loadTheme(ThemeSource.Prepared(candidate))
    try {
        let after = app.snapshot(Int64.Max,0)
        println("SNAPSHOT_OK width=${after.width} height=${after.height}")
    } catch (error: Exception) { println("SNAPSHOT_ERROR ${error.message}") }
    match (request.result()) {
        case Some(ThemeResult.Applied(revision)) => println("RESULT Applied(${revision})")
        case Some(ThemeResult.Failed(diagnostic)) => println("RESULT Failed(${diagnostic.code})")
        case Some(ThemeResult.Superseded(id)) => println("RESULT Superseded(${id})")
        case Some(ThemeResult.SessionClosed) => println("RESULT SessionClosed")
        case None => println("RESULT pending")
    }
    println("INFO ${app.themeInfo().name} revision=${app.themeInfo().revision}")
    println("POST_ACCEPTED ${app.post({=>})}")
    app.dispose()
    0
}

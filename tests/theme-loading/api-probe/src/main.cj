package theme_loading_api_probe
import cjtui.*
// Build only after foundation executes against a real product. Keeping this
// consumer separate makes async API diagnostics independent of suite syntax.
main():Int64 {
    let app=Application(Text("x"),theme:Theme.preset(ThemePreset.Classic))
    let request:ThemeRequest=app.loadTheme(ThemeSource.Prepared(Theme.parse("schema_version=1\nname=\"Probe\"\n")))
    let reload:ThemeRequest=app.reloadTheme()
    let info:ThemeInfo=app.themeInfo()
    let result:?ThemeResult=request.result()
    println("${request.id}/${reload.id}/${info.name}/${info.revision}/${info.requestId}")
    match(info.source){case ThemeSource.File(path)=>println(path);case _=>()}
    match(result){
        case Some(ThemeResult.Applied(revision))=>println(revision)
        case Some(ThemeResult.Failed(diagnostic))=>println(diagnostic.code)
        case Some(ThemeResult.Superseded(id))=>println(id)
        case Some(ThemeResult.SessionClosed)=>println("closed")
        case None=>println("pending")
    }
    0
}

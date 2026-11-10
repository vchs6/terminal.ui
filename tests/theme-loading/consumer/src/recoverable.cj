package theme_loading_contract
import cjtui.*
func recoverableFailuresKeepAcceptedTheme(env:TestEnvironment):Unit {
    let app=Application(Text("x"),theme:prepared("A","red"));app.startHeadless()
    try {
        let accepted=app.loadTheme(ThemeSource.Prepared(prepared("B","blue")))
        pump(app,accepted,env);applied(accepted,1)
        for(name in ["invalid.toml","syntax.toml","invalid-utf8.toml","missing.toml","unknown-ref.toml","oversize.toml","deep.toml"]){
            let request=app.loadTheme(ThemeSource.File(env.path(name)))
            let frame=pump(app,request,env)
            let expected=match(name){
                case "invalid.toml"=>"InvalidType"
                case "syntax.toml"=>"SyntaxError"
                case "invalid-utf8.toml"=>"InvalidUtf8"
                case "missing.toml"=>"ReadFailed"
                case "unknown-ref.toml"=>"UnknownReference"
                case _=>"CapacityExceeded"
            }
            failed(request,expected);unchanged(app,"B",1,accepted.id);applied(accepted,1)
            check(frame.cellAt(0,0).style.foreground==Color.Blue,"recoverable load failure retains accepted pixels")
        }
        for(path in ["", "bad\u{0}path"]){let bad=app.loadTheme(ThemeSource.File(path));pump(app,bad,env);failed(bad,"InvalidPath");unchanged(app,"B",1,accepted.id)}
        let equal=app.loadTheme(ThemeSource.Prepared(prepared("B","blue")))
        pump(app,equal,env);applied(equal,2)
        unchanged(app,"B",2,equal.id)
        check(equal.id>accepted.id,"successful equal theme still increments revision and request id")
    } finally {app.dispose()}
}
